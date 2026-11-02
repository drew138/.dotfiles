// Command scaffold renders a new Go service in the go-service layout from the skill's templates.
//
//	go -C <skill>/scripts run ./scaffold -module github.com/acme/users -dir "$PWD/users" \
//	  -entity User -fields "Username:string:unique,Password:string:secret" -store postgres
package main

import (
	"bytes"
	"errors"
	"flag"
	"fmt"
	"go/format"
	"go/token"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"runtime"
	"strings"
	"text/template"
	"unicode"
)

type field struct {
	Name        string
	Type        string
	JSON        string
	Column      string
	SQLType     string
	ProtoType   string
	ProtoGoName string
	ToProto     string
	FromProto   string
	MsgNum      int
	ReqNum      int
	Secret      bool
	Unique      bool
}

type data struct {
	Module       string
	Service      string
	ProtoPackage string
	Entity       string
	Var          string
	Snake        string
	Table        string
	Store        string
	GoVersion    string
	Fields       []field
	Cache        bool
	GRPC         bool
	HasTime      bool
	Columns      string
	Placeholders string
	InsertArgs   string
	ScanArgs     string
}

var (
	pascalCase = regexp.MustCompile(`^[A-Z][A-Za-z0-9]*$`)
	goTypes    = map[string]bool{"string": true, "int": true, "int64": true, "bool": true, "float64": true, "time.Time": true}
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, "scaffold:", err)
		os.Exit(1)
	}
}

func run() error {
	var d data
	var dir, fieldSpec, templates string
	flag.StringVar(&d.Module, "module", "", "Go module path, e.g. github.com/acme/users (required)")
	flag.StringVar(&dir, "dir", "", "absolute path of the directory to create; must not exist or must be empty (required)")
	flag.StringVar(&d.Entity, "entity", "", "first domain entity in PascalCase, e.g. User (required)")
	flag.StringVar(&fieldSpec, "fields", "Name:string", "entity fields as Name:type[:secret][:unique], comma separated. Types: string, int, int64, bool, float64, time.Time. ID is added automatically")
	flag.StringVar(&d.Store, "store", "postgres", "repository adapter: postgres or mysql")
	flag.StringVar(&d.Table, "table", "", "table name and REST path (default: snake_case entity + s)")
	flag.BoolVar(&d.Cache, "cache", false, "add a Redis cache decorator over the repository")
	flag.BoolVar(&d.GRPC, "grpc", false, "add a gRPC adapter next to REST")
	flag.StringVar(&templates, "templates", defaultTemplates(), "templates directory")
	flag.Parse()

	if err := d.complete(dir, fieldSpec); err != nil {
		return err
	}
	if err := ensureEmpty(dir); err != nil {
		return err
	}

	roots := []string{"base", d.Store}
	if d.Cache {
		roots = append(roots, "cache-redis")
	}
	if d.GRPC {
		roots = append(roots, "grpc")
	}

	var written []string
	for _, root := range roots {
		files, err := render(filepath.Join(templates, root), dir, d)
		if err != nil {
			return err
		}
		written = append(written, files...)
	}

	fmt.Printf("created %s (%d files)\n\nnext:\n  cd %s\n", dir, len(written), dir)
	if d.GRPC {
		fmt.Println("  go generate ./internal/infrastructure/api/grpc/   # needs protoc, protoc-gen-go, protoc-gen-go-grpc")
	}
	fmt.Println("  go mod tidy")
	fmt.Println("  replace every 'TODO: describe' in migration/ with what the table or column holds")
	fmt.Println("  go build ./... && go vet ./...")
	return nil
}

func (d *data) complete(dir, fieldSpec string) error {
	switch {
	case d.Module == "":
		return errors.New("-module is required")
	case dir == "" || !filepath.IsAbs(dir):
		return errors.New("-dir is required and must be absolute, e.g. -dir \"$PWD/users\"")
	case !pascalCase.MatchString(d.Entity):
		return errors.New("-entity is required and must be PascalCase, e.g. User")
	case d.Store != "postgres" && d.Store != "mysql":
		return fmt.Errorf("-store must be postgres or mysql, got %q", d.Store)
	}

	d.Service = strings.ToLower(filepath.Base(d.Module))
	d.ProtoPackage = protoIdent(d.Service)
	d.Snake = snake(d.Entity)
	d.Var = lowerFirst(d.Entity)
	if token.IsKeyword(d.Var) {
		d.Var += "Value"
	}
	if d.Table == "" {
		d.Table = d.Snake + "s"
	}
	d.GoVersion = goVersion()

	fields, err := parseFields(fieldSpec, d.Store)
	if err != nil {
		return err
	}
	d.Fields = fields

	var cols, holders, inserts []string
	scans := []string{"&row.ID"}
	for i, f := range fields {
		if f.Type == "time.Time" {
			d.HasTime = true
		}
		cols = append(cols, f.Column)
		if d.Store == "postgres" {
			holders = append(holders, fmt.Sprintf("$%d", i+1))
		} else {
			holders = append(holders, "?")
		}
		inserts = append(inserts, "row."+f.Name)
		scans = append(scans, "&row."+f.Name)
	}
	d.Columns = strings.Join(cols, ", ")
	d.Placeholders = strings.Join(holders, ", ")
	d.InsertArgs = strings.Join(inserts, ", ")
	d.ScanArgs = strings.Join(scans, ", ")
	return nil
}

func parseFields(spec, store string) ([]field, error) {
	var fields []field
	seen := map[string]bool{}
	for i, raw := range strings.Split(spec, ",") {
		parts := strings.Split(strings.TrimSpace(raw), ":")
		if len(parts) < 2 {
			return nil, fmt.Errorf("field %q: want Name:type[:secret][:unique]", raw)
		}
		f := field{Name: parts[0], Type: parts[1], MsgNum: i + 2, ReqNum: i + 1}
		switch {
		case !pascalCase.MatchString(f.Name):
			return nil, fmt.Errorf("field %q: name must be PascalCase", f.Name)
		case f.Name == "ID":
			return nil, errors.New("field ID is added automatically")
		case seen[f.Name]:
			return nil, fmt.Errorf("field %q appears twice", f.Name)
		case !goTypes[f.Type]:
			return nil, fmt.Errorf("field %q: unsupported type %q", f.Name, f.Type)
		}
		seen[f.Name] = true
		for _, mod := range parts[2:] {
			switch mod {
			case "secret":
				f.Secret = true
			case "unique":
				f.Unique = true
			default:
				return nil, fmt.Errorf("field %q: unknown modifier %q", f.Name, mod)
			}
		}
		if f.Secret && f.Type != "string" {
			return nil, fmt.Errorf("field %q: only string fields can be secret", f.Name)
		}
		f.JSON = snake(f.Name)
		f.Column = f.JSON
		f.ProtoGoName = protoGoName(f.Column)
		f.SQLType = sqlType(f.Type, store)
		f.ProtoType, f.ToProto, f.FromProto = protoMapping(f)
		fields = append(fields, f)
	}
	if len(fields) == 0 {
		return nil, errors.New("-fields needs at least one field")
	}
	return fields, nil
}

func sqlType(goType, store string) string {
	postgres := map[string]string{
		"string": "TEXT NOT NULL", "int": "BIGINT NOT NULL", "int64": "BIGINT NOT NULL",
		"bool": "BOOLEAN NOT NULL", "float64": "DOUBLE PRECISION NOT NULL", "time.Time": "TIMESTAMPTZ NOT NULL",
	}
	mysql := map[string]string{
		"string": "VARCHAR(255) NOT NULL", "int": "BIGINT NOT NULL", "int64": "BIGINT NOT NULL",
		"bool": "BOOLEAN NOT NULL", "float64": "DOUBLE NOT NULL", "time.Time": "DATETIME(6) NOT NULL",
	}
	if store == "mysql" {
		return mysql[goType]
	}
	return postgres[goType]
}

func protoMapping(f field) (protoType, toProto, fromProto string) {
	get := "req.Get" + f.ProtoGoName + "()"
	switch f.Type {
	case "int":
		return "int64", "int64(e." + f.Name + ")", "int(" + get + ")"
	case "float64":
		return "double", "e." + f.Name, get
	case "time.Time":
		return "google.protobuf.Timestamp", "timestamppb.New(e." + f.Name + ")", get + ".AsTime()"
	default:
		return f.Type, "e." + f.Name, get
	}
}

func render(root, dir string, d data) ([]string, error) {
	var written []string
	err := fs.WalkDir(os.DirFS(root), ".", func(rel string, entry fs.DirEntry, err error) error {
		if err != nil || entry.IsDir() || !strings.HasSuffix(rel, ".tmpl") {
			return err
		}
		outRel, err := execute("path", rel, d)
		if err != nil {
			return fmt.Errorf("rendering path %s: %w", rel, err)
		}
		outRel = strings.TrimSuffix(outRel, ".tmpl")

		src, err := os.ReadFile(filepath.Join(root, rel))
		if err != nil {
			return err
		}
		content, err := execute(rel, string(src), d)
		if err != nil {
			return fmt.Errorf("rendering %s: %w", rel, err)
		}
		out := []byte(content)
		if strings.HasSuffix(outRel, ".go") {
			if out, err = format.Source(out); err != nil {
				return fmt.Errorf("formatting %s: %w", outRel, err)
			}
		}

		path := filepath.Join(dir, filepath.FromSlash(outRel))
		if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
			return err
		}
		if err := os.WriteFile(path, out, 0o644); err != nil {
			return err
		}
		written = append(written, outRel)
		return nil
	})
	if errors.Is(err, fs.ErrNotExist) {
		return nil, fmt.Errorf("templates not found under %s", root)
	}
	return written, err
}

func execute(name, text string, d data) (string, error) {
	tmpl, err := template.New(name).Option("missingkey=error").Parse(text)
	if err != nil {
		return "", err
	}
	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, d); err != nil {
		return "", err
	}
	return buf.String(), nil
}

func ensureEmpty(dir string) error {
	entries, err := os.ReadDir(dir)
	if errors.Is(err, fs.ErrNotExist) {
		return nil
	}
	if err != nil {
		return err
	}
	if len(entries) > 0 {
		return fmt.Errorf("%s is not empty", dir)
	}
	return nil
}

func defaultTemplates() string {
	_, file, _, ok := runtime.Caller(0)
	if !ok {
		return ""
	}
	return filepath.Join(filepath.Dir(file), "..", "..", "assets", "templates")
}

func goVersion() string {
	v := strings.TrimPrefix(runtime.Version(), "go")
	parts := strings.SplitN(v, ".", 3)
	if len(parts) < 2 || !unicode.IsDigit(rune(parts[0][0])) {
		return "1.24"
	}
	return parts[0] + "." + parts[1]
}

func snake(s string) string {
	runes := []rune(s)
	var b strings.Builder
	for i, r := range runes {
		if unicode.IsUpper(r) && i > 0 {
			prevLower := unicode.IsLower(runes[i-1]) || unicode.IsDigit(runes[i-1])
			nextLower := i+1 < len(runes) && unicode.IsLower(runes[i+1])
			if prevLower || (nextLower && unicode.IsUpper(runes[i-1])) {
				b.WriteByte('_')
			}
		}
		b.WriteRune(unicode.ToLower(r))
	}
	return b.String()
}

func lowerFirst(s string) string {
	runes := []rune(s)
	n := 1
	for n < len(runes) && unicode.IsUpper(runes[n]) && (n+1 == len(runes) || unicode.IsUpper(runes[n+1])) {
		n++
	}
	return strings.ToLower(string(runes[:n])) + string(runes[n:])
}

func protoGoName(column string) string {
	var b strings.Builder
	for _, part := range strings.Split(column, "_") {
		if part == "" {
			continue
		}
		b.WriteString(strings.ToUpper(part[:1]) + part[1:])
	}
	return b.String()
}

func protoIdent(s string) string {
	var b strings.Builder
	for _, r := range s {
		if unicode.IsLetter(r) || unicode.IsDigit(r) {
			b.WriteRune(r)
		} else {
			b.WriteByte('_')
		}
	}
	out := b.String()
	if out == "" || unicode.IsDigit(rune(out[0])) {
		out = "svc_" + out
	}
	return out
}
