# Wiring

## Entry points

Each way of running the service is its own entry point, `cmd/<entrypoint>/`, named
like the inbound adapter it runs:

```
cmd/rest/main.go       cmd/rest/config.go       serves the REST API
cmd/grpc/main.go       cmd/grpc/config.go       serves the gRPC API
cmd/consumer/main.go   cmd/consumer/config.go   consumes the queue
cmd/cli/main.go        cmd/cli/config.go        a command-line tool
```

Each `main.go` builds only what its entry point uses: it is the only place that
knows those concrete types. Each builds into its own binary
(`go build ./cmd/rest`) and is deployed on its own.

## Shape of main.go

```go
func main() {
	if err := run(); err != nil {
		slog.Error("service stopped", "error", err)
		os.Exit(1)
	}
}

func run() error { … }
```

`main` only reports `run`'s error. `run` returns errors instead of calling
`os.Exit`, so its `defer`s (closing the database, the broker connection) actually
run. This is the only place the program stops on purpose: invalid config or a
connection that cannot be made at startup ends here, with a log line and exit code 1.
Nothing anywhere calls `panic`. How the logger is built and handed to adapters is
part of the logging design, which is not settled yet.

## Order inside run

1. Signal context: `signal.NotifyContext(ctx, os.Interrupt, syscall.SIGTERM)`.
2. `loadConfig()`. Fail on any missing or invalid value.
3. Connections: open, `defer Close`, ping. An entry point that cannot reach its
   database fails at start, not at its first request.
4. Outbound adapters: `postgres.New(db)`, `adyen.New(httpClient, cfg.adyenURL, cfg.adyenAPIKey)`.
5. Decorators around them: `redis.New(rdb, repo, cfg.cacheTTL, log)`.
6. `application.New(...)` with every port.
7. The inbound adapter: `rest.New(router, app)` builds it and registers its routes.
8. Serve in a goroutine, sending its error to a channel.
9. Wait for that error or the signal, then shut down with a timeout.

## Rules

- Plain constructor calls. No DI container, no reflection, no globals.
- Only `New` functions and arguments here: no business logic, no `if` on domain
  values. A branch on config (`if cfg.cacheTTL > 0` to enable the cache) is wiring
  and is fine.
- Every value is built once and passed down. Nothing reaches for a package variable.
- `init` and `panic` are forbidden here as everywhere: startup work belongs in
  `run`, and startup failures return to `main`.

## Config

Each entry point reads its own configuration in `cmd/<entrypoint>/config.go`: a
private `config` struct and `loadConfig()`, using only the standard library.

**An entry point reads only what it uses.** `cmd/cli/config.go` has no `HTTP_ADDR`
because `cmd/rest` needs one; each struct lists exactly the values its `main.go`
passes on.

```go
// cmd/rest/config.go
type config struct {
	httpAddr    string
	databaseURL string
	cacheTTL    time.Duration
}

func loadConfig() (config, error) {
	var errs []error
	cfg := config{
		httpAddr:    envOr("HTTP_ADDR", ":8080"),
		databaseURL: required("DATABASE_URL", &errs),
		cacheTTL:    durationOr("CACHE_TTL", 5*time.Minute, &errs),
	}
	return cfg, errors.Join(errs...)
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func required(key string, errs *[]error) string {
	v := os.Getenv(key)
	if v == "" {
		*errs = append(*errs, fmt.Errorf("%s is required", key))
	}
	return v
}

func durationOr(key string, fallback time.Duration, errs *[]error) time.Duration {
	v := os.Getenv(key)
	if v == "" {
		return fallback
	}
	d, err := time.ParseDuration(v)
	if err != nil {
		*errs = append(*errs, fmt.Errorf("%s is not a valid duration", key))
		return fallback
	}
	return d
}
```

- **Every problem at once.** Each helper records its problem and `loadConfig`
  joins them, so a misconfigured deploy shows every missing or broken variable in
  one log line.
- **Errors name the variable, never its value.** A malformed `DATABASE_URL` still
  carries a password.
- **Each entry point carries its own helpers.** They are a few lines, and only the
  ones its config uses: `durationOr` exists where a duration is read.
- **Adapters receive plain values** (`cfg.cacheTTL`), never the `config` struct.

Common variables:

| Variable | Default | Used by |
|---|---|---|
| `HTTP_ADDR` | `:8080` | `cmd/rest` |
| `GRPC_ADDR` | `:9090` | `cmd/grpc` |
| `DATABASE_URL` | required | any entry point with a repository. Postgres: `postgres://user:pass@host:5432/db?sslmode=disable`. MySQL: `user:pass@tcp(host:3306)/db?parseTime=true` |
| `REDIS_ADDR` | `localhost:6379` | any entry point with a cache |
| `CACHE_TTL` | `5m` | any entry point with a cache |

MySQL needs `parseTime=true` to scan `DATETIME` into `time.Time`.

## Adding a dependency

When a step adds a port, the compiler shows where wiring is missing:
`application.New` gains a parameter, and every `main.go` that builds the application
fails until the adapter is constructed and passed. Build after the wiring step; a
green build means nothing was forgotten.
