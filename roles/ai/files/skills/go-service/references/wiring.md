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
const shutdownTimeout = 30 * time.Second

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
	server := &http.Server{Addr: cfg.httpAddr, Handler: router, ReadHeaderTimeout: 10 * time.Second}

	shutdownErr := make(chan error, 1)
	go func() {
		<-ctx.Done()
		shutdownCtx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
		defer cancel()
		shutdownErr <- server.Shutdown(shutdownCtx)
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
	httpAddr     string
	databaseURL  string
	maxBodyBytes int64
}

func loadConfig() (config, error) {
	httpAddr := os.Getenv("HTTP_ADDR")
	if httpAddr == "" {
		return config{}, errors.New("HTTP_ADDR is required")
	}
	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		return config{}, errors.New("DATABASE_URL is required")
	}
	maxBodyBytes, err := strconv.ParseInt(os.Getenv("MAX_BODY_BYTES"), 10, 64)
	if err != nil || maxBodyBytes <= 0 {
		return config{}, errors.New("MAX_BODY_BYTES must be a positive integer")
	}
	return config{httpAddr: httpAddr, databaseURL: databaseURL, maxBodyBytes: maxBodyBytes}, nil
}
```

- **Read inline, one value after another.** Each value is read and checked where
  it is declared; there are no helper wrappers around `os.Getenv`.
- **Stop at the first problem.** The first missing or invalid value returns its
  error, and the entry point does not start.
- **Every variable is required.** Values come from the deploy (or a local `.env`);
  the code holds no defaults.
- **Errors name the variable, never its value.** A malformed `DATABASE_URL` still
  carries a password.
- **Adapters receive plain values** (`cfg.maxBodyBytes`), never the `config` struct.

Common variables:

| Variable | Used by |
|---|---|
| `HTTP_ADDR` | `cmd/rest` |
| `GRPC_ADDR` | `cmd/grpc` |
| `DATABASE_URL` | any entry point with a repository. Postgres: `postgres://user:pass@host:5432/db?sslmode=disable`. MySQL: `user:pass@tcp(host:3306)/db?parseTime=true` |
| `REDIS_ADDR`, `CACHE_TTL` | any entry point with a cache |

MySQL needs `parseTime=true` to scan `DATETIME` into `time.Time`.

## Adding a dependency

When a step adds a port, the compiler shows where wiring is missing:
`application.New` gains a parameter, and every `main.go` that builds the application
fails until the adapter is constructed and passed. Build after the wiring step; a
green build means nothing was forgotten.
