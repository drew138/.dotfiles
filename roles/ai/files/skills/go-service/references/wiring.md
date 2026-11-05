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

Every entry point builds the one `Application`, with all its ports, and then its own
inbound adapter. Its `main.go` is the only place that knows those concrete types.
Each builds into its own binary (`go build ./cmd/rest`) and is deployed on its own.

## main.go

```go
func main() {
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, nil)))
	if err := run(); err != nil {
		slog.Error("service stopped", "error", err)
		os.Exit(1)
	}
}

func run() error {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	cfg, err := loadConfig()
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}

	db, err := sql.Open("pgx", cfg.databaseURL)
	if err != nil {
		return fmt.Errorf("opening database: %w", err)
	}
	defer db.Close()
	if err := db.PingContext(ctx); err != nil {
		return fmt.Errorf("reaching database: %w", err)
	}

	app := application.New(postgres.New(db))
	router := chi.NewRouter()
	rest.New(router, app)
	server := &http.Server{Addr: cfg.httpAddr, Handler: router}

	shutdownErr := make(chan error, 1)
	go func() {
		<-ctx.Done()
		shutdownErr <- server.Shutdown(context.Background())
	}()

	slog.InfoContext(ctx, "service started", "addr", cfg.httpAddr)
	if err := server.ListenAndServe(); !errors.Is(err, http.ErrServerClosed) {
		return fmt.Errorf("serving http: %w", err)
	}
	if err := <-shutdownErr; err != nil {
		return fmt.Errorf("shutting down http: %w", err)
	}
	return nil
}
```

**`main` only sets the default logger and reports `run`'s error.** `run` returns
errors instead of calling `os.Exit`, so its `defer`s (closing the database, the
broker connection) actually run. This is the only place the program stops on
purpose: invalid config or a connection that cannot be made at startup ends here,
with a log line and exit code 1. Nothing anywhere calls `panic`.

**The server runs on the main path; one goroutine waits for the stop signal.** This
is graceful shutdown, and it exists for planned stops: every deploy and every
scale-down sends SIGTERM and waits before killing the process. On SIGTERM the
goroutine calls `server.Shutdown`, which stops accepting connections and lets the
requests in flight finish, so a deploy never cuts a client off mid-response. A crash
skips all of this; it is for planned stops only.

`ListenAndServe` returns as soon as `Shutdown` starts, so `run` then **waits for
`Shutdown` to finish** (`<-shutdownErr`) before returning. Returning straight after
`ListenAndServe` would exit while requests are still being answered.

The router is **`chi`** (`github.com/go-chi/chi/v5`).

## Order inside run

1. Signal context: `signal.NotifyContext(ctx, os.Interrupt, syscall.SIGTERM)`.
2. `loadConfig()`. Stop at the first missing or invalid value.
3. Connections: open, `defer Close`, ping. An entry point that cannot reach its
   database fails at start, not at its first request.
4. Outbound adapters: `postgres.New(db)`, `adyen.New(httpClient, cfg.adyenURL, cfg.adyenAPIKey)`.
5. Decorators around them: `redis.New(rdb, repo, cfg.cacheTTL)`.
6. `application.New(...)` with every port.
7. The inbound adapter: `rest.New(router, app)` builds it and registers its routes.
8. Start the shutdown goroutine, then serve on the main path.
9. After the server stops, wait for the shutdown to finish.

## Rules

- Plain constructor calls. No DI container, no reflection, no globals besides the
  default logger.
- Only `New` functions and arguments here: no business logic, no `if` on domain
  values. A branch on config (`if cfg.cacheTTL > 0` to enable the cache) is wiring
  and is fine.
- Every value is built once and passed down. Nothing reaches for a package variable.
- `init` and `panic` are forbidden here as everywhere: startup work belongs in
  `run`, and startup failures return to `main`.

## Config

Each entry point reads its configuration in `cmd/<entrypoint>/config.go`: a private
`config` struct and `loadConfig()`, with the standard library.

Every entry point reads the settings the application's ports need (the database,
providers, the cache), since each builds the whole application, plus the settings of
its own inbound adapter: `HTTP_ADDR` in `cmd/rest`, `GRPC_ADDR` in `cmd/grpc`.

```go
type config struct {
	httpAddr    string
	databaseURL string
}

func loadConfig() (config, error) {
	databaseURL, err := required("DATABASE_URL")
	if err != nil {
		return config{}, err
	}
	return config{
		httpAddr:    envOr("HTTP_ADDR", ":8080"),
		databaseURL: databaseURL,
	}, nil
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func required(key string) (string, error) {
	v := os.Getenv(key)
	if v == "" {
		return "", fmt.Errorf("%s is required", key)
	}
	return v, nil
}

```

- **Stop at the first problem.** Each helper returns an error, and `loadConfig`
  returns the first one, so the entry point never starts with a missing or invalid
  value; the same as a connection that cannot be made at startup.
- **Defaults where they make sense, required otherwise.** A listen address can have a
  default (`envOr`); a database URL, a provider key or anything without a sensible
  default is `required`.
- **Only what changes between deployments is configuration.** Everything else is a
  constant in the code, or Go's own default: request bodies, for one, are read with
  Go's defaults.
- **Small helpers, in the entry point's `config.go`.** Each returns its value and
  an error, and only the helpers the config uses exist.
- **Errors name the variable, never its value.** A malformed `DATABASE_URL` still
  carries a password.
- **Adapters receive plain values** (`cfg.databaseURL`), never the `config` struct.

Common variables:

| Variable | Default | Used by |
|---|---|---|
| `HTTP_ADDR` | `:8080` | `cmd/rest` |
| `GRPC_ADDR` | `:9090` | `cmd/grpc` |
| `DATABASE_URL` | required | any entry point with a repository. Postgres: `postgres://user:pass@host:5432/db?sslmode=disable`. MySQL: `user:pass@tcp(host:3306)/db?parseTime=true` |
| `REDIS_ADDR` | required | any entry point with a cache |
| `CACHE_TTL` | `5m` | any entry point with a cache |

MySQL needs `parseTime=true` to scan `DATETIME` into `time.Time`.

## Adding a dependency

When a step adds a port, the compiler shows where wiring is missing:
`application.New` gains a parameter, and every `main.go` that builds the application
fails until the adapter is constructed and passed. Build after the wiring step; a
green build means nothing was forgotten.
