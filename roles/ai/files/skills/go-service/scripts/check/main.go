// Command check reports where a Go service breaks the go-service conventions.
//
//	go -C <skill>/scripts run ./check "$PWD"
//
// Exit status: 0 when clean, 1 when there are findings, 2 when the check could not run.
package main

import (
	"bufio"
	"flag"
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"unicode"
)

type sourceFile struct {
	rel  string
	node *ast.File
}

type checker struct {
	root     string
	module   string
	fset     *token.FileSet
	findings []string
}

var (
	descriptiveNew = regexp.MustCompile(`^New[A-Z0-9]`)
	mapperName     = regexp.MustCompile(`^map[A-Z]`)
	sensitiveName  = regexp.MustCompile(`(?i)password|secret|token|hash`)
)

func main() {
	flag.Usage = func() {
		fmt.Fprintln(os.Stderr, "usage: go -C <skill>/scripts run ./check <absolute service root>")
	}
	flag.Parse()
	root := flag.Arg(0)
	if root == "" || !filepath.IsAbs(root) {
		flag.Usage()
		os.Exit(2)
	}

	c := &checker{root: root, fset: token.NewFileSet()}
	files, err := c.load()
	if err != nil {
		fmt.Fprintln(os.Stderr, "check:", err)
		os.Exit(2)
	}
	c.inspect(files)
	c.migrations()

	sort.Strings(c.findings)
	for _, f := range c.findings {
		fmt.Println(f)
	}
	if len(c.findings) > 0 {
		fmt.Printf("\n%d finding(s)\n", len(c.findings))
		os.Exit(1)
	}
	fmt.Printf("ok: %d files follow the go-service conventions\n", len(files))
}

func (c *checker) load() ([]sourceFile, error) {
	mod, err := modulePath(filepath.Join(c.root, "go.mod"))
	if err != nil {
		return nil, err
	}
	c.module = mod

	var files []sourceFile
	err = filepath.WalkDir(c.root, func(path string, entry fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		name := entry.Name()
		if entry.IsDir() {
			if path != c.root && (strings.HasPrefix(name, ".") || name == "vendor" || name == "testdata") {
				return filepath.SkipDir
			}
			return nil
		}
		if !strings.HasSuffix(name, ".go") || strings.HasSuffix(name, "_test.go") {
			return nil
		}
		node, err := parser.ParseFile(c.fset, path, nil, parser.ParseComments)
		if err != nil {
			return err
		}
		if ast.IsGenerated(node) {
			return nil
		}
		rel, _ := filepath.Rel(c.root, path)
		files = append(files, sourceFile{rel: filepath.ToSlash(rel), node: node})
		return nil
	})
	return files, err
}

func (c *checker) inspect(files []sourceFile) {
	var application []sourceFile
	for _, f := range files {
		dir := filepath.ToSlash(filepath.Dir(f.rel))
		base := filepath.Base(f.rel)

		switch {
		case dir == "internal/domain" || strings.HasPrefix(dir, "internal/domain/"):
			c.domain(f)
		case dir == "internal/application":
			application = append(application, f)
			c.forbidImport(f, "/internal/infrastructure", "the application layer must not import infrastructure")
		case strings.HasPrefix(dir, "internal/infrastructure/"):
			if base == "dto.go" {
				c.dto(f, outgoingStruct(dir))
			}
			if base == "mappers.go" {
				c.mappers(f)
			}
		}
		c.constructors(f)
	}
	if len(application) > 0 {
		c.application(application)
	}
}

func (c *checker) domain(f sourceFile) {
	c.forbidImport(f, "/internal/application", "the domain must not import the application layer")
	c.forbidImport(f, "/internal/infrastructure", "the domain must not import infrastructure")
	ast.Inspect(f.node, func(n ast.Node) bool {
		if field, ok := n.(*ast.Field); ok && field.Tag != nil {
			c.report(field.Pos(), "domain structs carry no tags; put %s on the adapter's DTO", field.Tag.Value)
		}
		return true
	})
}

func (c *checker) application(files []sourceFile) {
	helpers := map[string]string{}
	for _, f := range files {
		for _, decl := range f.node.Decls {
			if fn, ok := decl.(*ast.FuncDecl); ok && !fn.Name.IsExported() {
				helpers[fn.Name.Name] = f.rel
			}
		}
	}

	hasApplicationFile := false
	for _, f := range files {
		base := filepath.Base(f.rel)
		switch base {
		case "service.go":
			c.report(f.node.Package, "rename service.go to application.go")
			c.applicationFile(f)
			hasApplicationFile = true
		case "application.go":
			c.applicationFile(f)
			hasApplicationFile = true
		default:
			c.methodFile(f, base)
		}

		ast.Inspect(f.node, func(n ast.Node) bool {
			var ident *ast.Ident
			switch x := n.(type) {
			case *ast.CallExpr:
				switch fn := x.Fun.(type) {
				case *ast.Ident:
					ident = fn
				case *ast.SelectorExpr:
					ident = fn.Sel
				}
			}
			if ident != nil {
				if owner, ok := helpers[ident.Name]; ok && owner != f.rel {
					c.report(ident.Pos(), "calls %s from %s; duplicate it in this file under a name specific to this method", ident.Name, owner)
				}
			}
			return true
		})
	}
	if !hasApplicationFile {
		c.findings = append(c.findings, "internal/application: missing application.go with the Application struct, New and the ports")
	}
}

func (c *checker) applicationFile(f sourceFile) {
	var hasApplication, hasNew bool
	for _, decl := range f.node.Decls {
		switch d := decl.(type) {
		case *ast.GenDecl:
			for _, spec := range d.Specs {
				ts, ok := spec.(*ast.TypeSpec)
				if !ok {
					continue
				}
				if ts.Name.Name == "Application" {
					hasApplication = true
				}
				if iface, ok := ts.Type.(*ast.InterfaceType); ok {
					for _, m := range iface.Methods.List {
						if fn, ok := m.Type.(*ast.FuncType); ok && !firstParamIsContext(fn) {
							c.report(m.Pos(), "port method %s must take context.Context first", fieldName(m))
						}
					}
				}
			}
		case *ast.FuncDecl:
			if d.Recv == nil && d.Name.Name == "New" {
				hasNew = true
			}
			if d.Recv != nil && d.Name.IsExported() && receiverName(d) == "Application" {
				c.report(d.Pos(), "move %s to %s.go; application.go holds only Application, New and the ports", d.Name.Name, snake(d.Name.Name))
			}
		}
	}
	if !hasApplication {
		c.report(f.node.Package, "application.go must declare the Application struct")
	}
	if !hasNew {
		c.report(f.node.Package, "application.go must declare func New")
	}
}

func (c *checker) methodFile(f sourceFile, base string) {
	var methods []*ast.FuncDecl
	for _, decl := range f.node.Decls {
		switch d := decl.(type) {
		case *ast.FuncDecl:
			if d.Recv != nil && d.Name.IsExported() && receiverName(d) == "Application" {
				methods = append(methods, d)
			} else if d.Recv == nil && d.Name.IsExported() {
				c.report(d.Pos(), "exported function %s belongs in application.go or a method of Application", d.Name.Name)
			}
		case *ast.GenDecl:
			for _, spec := range d.Specs {
				if ts, ok := spec.(*ast.TypeSpec); ok {
					c.report(ts.Pos(), "declare type %s in application.go (ports) or domain.go (models)", ts.Name.Name)
				}
			}
		}
	}
	if len(methods) != 1 {
		c.report(f.node.Package, "%s must hold exactly one public Application method, found %d", base, len(methods))
	}
	for _, m := range methods {
		if want := snake(m.Name.Name) + ".go"; want != base {
			c.report(m.Pos(), "%s belongs in %s", m.Name.Name, want)
		}
		if !firstParamIsContext(m.Type) {
			c.report(m.Pos(), "%s must take context.Context first", m.Name.Name)
		}
	}
}

// outgoingStruct reports which dto.go structs leave the service and so must not carry
// secrets: response DTOs of an API, and every message a publisher sends.
func outgoingStruct(dir string) func(name string) bool {
	switch {
	case strings.HasPrefix(dir, "internal/infrastructure/api/"):
		return func(name string) bool { return strings.HasSuffix(name, "Response") }
	case strings.HasPrefix(dir, "internal/infrastructure/publisher/"):
		return func(string) bool { return true }
	default:
		return func(string) bool { return false }
	}
}

func (c *checker) dto(f sourceFile, outgoing func(name string) bool) {
	for _, decl := range f.node.Decls {
		switch d := decl.(type) {
		case *ast.FuncDecl:
			if d.Recv == nil {
				c.report(d.Pos(), "function %s belongs in mappers.go; dto.go holds structs and their toDomain methods", d.Name.Name)
			} else if d.Name.Name == "ToDomain" {
				c.report(d.Pos(), "name it toDomain; conversions are not part of the adapter's API")
			}
		case *ast.GenDecl:
			for _, spec := range d.Specs {
				ts, ok := spec.(*ast.TypeSpec)
				if !ok || !outgoing(ts.Name.Name) {
					continue
				}
				st, ok := ts.Type.(*ast.StructType)
				if !ok {
					continue
				}
				for _, field := range st.Fields.List {
					for _, name := range field.Names {
						if sensitiveName.MatchString(name.Name) {
							c.report(name.Pos(), "%s.%s looks sensitive; leave it out of anything that leaves the service", ts.Name.Name, name.Name)
						}
					}
				}
			}
		}
	}
}

func (c *checker) mappers(f sourceFile) {
	for _, decl := range f.node.Decls {
		if fn, ok := decl.(*ast.FuncDecl); ok && fn.Recv == nil && !mapperName.MatchString(fn.Name.Name) {
			c.report(fn.Pos(), "mapper %s must be named map<Target>, e.g. mapUserResponse", fn.Name.Name)
		}
	}
}

func (c *checker) constructors(f sourceFile) {
	for _, decl := range f.node.Decls {
		fn, ok := decl.(*ast.FuncDecl)
		if !ok || fn.Recv != nil {
			continue
		}
		if fn.Name.Name == "init" {
			c.report(fn.Pos(), "init is forbidden; do the work in New or in main, where the caller decides when it runs")
		}
		if descriptiveNew.MatchString(fn.Name.Name) {
			c.report(fn.Pos(), "rename %s to New; the package name already says what it builds", fn.Name.Name)
		}
	}
}

func (c *checker) forbidImport(f sourceFile, suffix, msg string) {
	for _, imp := range f.node.Imports {
		path := strings.Trim(imp.Path.Value, `"`)
		if strings.HasPrefix(path, c.module+suffix) {
			c.report(imp.Pos(), "%s (%s)", msg, path)
		}
	}
}

func (c *checker) migrations() {
	paths, _ := filepath.Glob(filepath.Join(c.root, "migration", "*.sql"))
	for _, path := range paths {
		file, err := os.Open(path)
		if err != nil {
			continue
		}
		rel, _ := filepath.Rel(c.root, path)
		scanner := bufio.NewScanner(file)
		for line := 1; scanner.Scan(); line++ {
			if strings.Contains(scanner.Text(), "TODO") {
				c.findings = append(c.findings, fmt.Sprintf("%s:%d: replace the TODO with what the table or column holds", filepath.ToSlash(rel), line))
			}
		}
		file.Close()
	}
}

func (c *checker) report(pos token.Pos, format string, args ...any) {
	p := c.fset.Position(pos)
	rel, _ := filepath.Rel(c.root, p.Filename)
	c.findings = append(c.findings, fmt.Sprintf("%s:%d: %s", filepath.ToSlash(rel), p.Line, fmt.Sprintf(format, args...)))
}

func firstParamIsContext(fn *ast.FuncType) bool {
	if fn.Params == nil || len(fn.Params.List) == 0 {
		return false
	}
	sel, ok := fn.Params.List[0].Type.(*ast.SelectorExpr)
	if !ok {
		return false
	}
	pkg, ok := sel.X.(*ast.Ident)
	return ok && pkg.Name == "context" && sel.Sel.Name == "Context"
}

func receiverName(fn *ast.FuncDecl) string {
	if fn.Recv == nil || len(fn.Recv.List) == 0 {
		return ""
	}
	t := fn.Recv.List[0].Type
	if star, ok := t.(*ast.StarExpr); ok {
		t = star.X
	}
	if ident, ok := t.(*ast.Ident); ok {
		return ident.Name
	}
	return ""
}

func fieldName(f *ast.Field) string {
	if len(f.Names) > 0 {
		return f.Names[0].Name
	}
	return "?"
}

func modulePath(gomod string) (string, error) {
	data, err := os.ReadFile(gomod)
	if err != nil {
		return "", fmt.Errorf("reading go.mod: %w", err)
	}
	for _, line := range strings.Split(string(data), "\n") {
		if rest, ok := strings.CutPrefix(strings.TrimSpace(line), "module "); ok {
			return strings.Trim(strings.TrimSpace(rest), `"`), nil
		}
	}
	return "", fmt.Errorf("no module line in %s", gomod)
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
