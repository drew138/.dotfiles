# Logging

These conventions hold whatever logging library the service uses, unless the
service says otherwise. With no library chosen, use the standard `log/slog`.

## The logger

The logger is set **once, in `main`, as the default**, and code logs through it
directly:

```go
func main() {
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, nil)))
	if err := run(); err != nil {
		slog.Error("service stopped", "error", err)
		os.Exit(1)
	}
}
```

It is the one accepted global: logging has no side effects on the service's
behaviour, so passing a logger through every constructor buys nothing. Nothing
takes a logger parameter.

**Always the context variants**: `slog.InfoContext(ctx, …)`, never `slog.Info(…)`
inside a request or message. If the logging library adds correlation IDs or trace
IDs from the context, this is all it needs. Correlation IDs belong to the
infrastructure (gateway, mesh, platform); the code reads, sets and forwards no
correlation headers.

## Structured, named fields

Every log line is a message plus named fields: `slog.WarnContext(ctx, "writing
cache", "key", key, "error", err)`.

- The message says what was happening, in a few lowercase words.
- Fields are chosen one by one. A whole struct, request, body, header set or DTO is
  never a field, because what it contains changes with the code around it.
- IDs identify things (`"order_id", order.ID`). PII and PCI are never logged; a
  masked value is allowed when an ID is not enough.

## Where to log

**An error is logged once, where it stops**, never where it passes through. A
function that logs an error and returns it puts the same failure in the logs at
every layer. Errors travel up by wrapping (`errors.md`), so the one line that logs
them shows the whole path:

```
placing order 981: charging payment 4410: unavailable: dial tcp 10.0.3.7:443: connection refused
```

| Where | Logs |
|---|---|
| inbound adapter | **one line per request, when it finishes** (below) |
| queue consumer | one line per message it cannot process, with its fate |
| cache | a warning when it falls through to the repository |
| use case | a warning for a best-effort side effect it swallows |
| `main` | startup, shutdown, and the error that stopped it |
| everywhere else | nothing; errors are returned |

## One line per request

Every request produces exactly one log line, written by the inbound adapter when
the request finishes:

```json
{"level":"INFO","msg":"request handled","route":"GET /users/{id}","status":404,"duration_ms":3}
{"level":"ERROR","msg":"request failed","route":"GET /users/{id}","status":503,"duration_ms":2,
 "error":"finding user 42: selecting user 42: unavailable: dial tcp 10.0.0.5:5432: connect: connection refused"}
```

- `route` is the route **pattern**, not the requested path, so an ID or email in a
  URL never reaches the logs.
- A 5xx carries the error: it is a failure of ours.
- A 4xx carries no error text: it is a normal client mistake, answered in the
  response.

The REST adapter does this with a wrapper registered on every route (`rest.md`).

## Levels

| Level | When |
|---|---|
| `ERROR` | a request that ended in 5xx; a message requeued or dead-lettered after an unexpected error |
| `WARN` | something degraded but handled: a cache failure, a swallowed best-effort side effect, a malformed message dead-lettered |
| `INFO` | the line for each request; startup and shutdown |
| `DEBUG` | not used in production code |
