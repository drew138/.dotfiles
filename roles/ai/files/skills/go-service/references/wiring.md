# Wiring

`cmd/service/main.go` builds the service: it is the only place that knows every
concrete type.

## Shape

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
run. How the logger is built and handed to adapters is part of the logging design,
which is not settled yet.

## Order inside run

1. Signal context: `signal.NotifyContext(ctx, os.Interrupt, syscall.SIGTERM)`.
2. `config.Load()`. Fail fast on a missing required value.
3. Connections: open, `defer Close`, ping. A service that cannot reach its database
   should fail at start, not at its first request.
4. Outbound adapters: `postgres.New(db)`, `catalog.New(httpClient, cfg.CatalogURL)`.
5. Decorators around them: `redis.New(rdb, repo, cfg.CacheTTL, log)`.
6. `application.New(...)` with every port.
7. Inbound adapters: `rest.New(router, app)` and `grpcapi.New(grpcServer, app)` build
   each adapter and register its routes or services.
8. Serve each server in a goroutine, sending its error to one channel.
9. Wait for a server error or the signal, then shut down with a timeout.

## Rules

- Plain constructor calls. No DI container, no reflection, no globals.
- Only `New` functions and arguments here: no business logic, no `if` on domain
  values. A branch on config (`if cfg.CacheTTL > 0` to enable the cache) is wiring
  and is fine.
- Every value is built once and passed down. Nothing reaches for a package variable.
- `init` is forbidden here as everywhere: anything it would do belongs in `run`.

## Config

`internal/config` is the only config package. `Load() (Config, error)` reads
environment variables, applies defaults, validates required values and parses
durations. Adapters receive plain values (`cfg.CacheTTL`), never the `Config` struct,
so they do not depend on the config package.

```go
type Config struct {
	HTTPAddr    string
	DatabaseURL string
}

func Load() (Config, error) {
	cfg := Config{
		HTTPAddr:    env("HTTP_ADDR", ":8080"),
		DatabaseURL: os.Getenv("DATABASE_URL"),
	}
	if cfg.DatabaseURL == "" {
		return Config{}, errors.New("DATABASE_URL is required")
	}
	return cfg, nil
}

func env(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
```

| Variable | Default | Used by |
|---|---|---|
| `HTTP_ADDR` | `:8080` | REST server |
| `GRPC_ADDR` | `:9090` | gRPC server |
| `DATABASE_URL` | required | repository. Postgres: `postgres://user:pass@host:5432/db?sslmode=disable`. MySQL: `user:pass@tcp(host:3306)/db?parseTime=true` |
| `REDIS_ADDR` | `localhost:6379` | cache |
| `CACHE_TTL` | `5m` | cache |

MySQL needs `parseTime=true` to scan `DATETIME` into `time.Time`.

## Adding a dependency

When a step adds a port, the compiler shows where wiring is missing:
`application.New` gains a parameter, and `main.go` fails to build until the adapter
is constructed and passed. Build after the wiring step; a green build means nothing
was forgotten.
