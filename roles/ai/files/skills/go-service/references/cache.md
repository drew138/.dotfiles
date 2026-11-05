# Cache adapters

A cache is a **decorator**: it implements the same port as the repository, wraps one,
and `main.go` hands the wrapped value to `application.New`. The application never
knows a cache exists. It lives at `internal/infrastructure/cache/<tech>/`, and its
files follow the same shape as every outbound adapter (`repository.md`). Any server
config the cache needs (a `redis.conf`) lives at the repository root in `redis/`.

```go
repo := postgres.New(db)
app := application.New(redis.New(rdb, repo, cfg.cacheTTL))
```

## Files

| File | Holds |
|---|---|
| `redis.go` | `Cache`, `New(client, repo, ttl)`, `read`, `write`, key builders |
| `<method>.go` | one port method per file, in snake_case: `FindUser` lives in `find_user.go` |
| `<method>_dao.go` | that method's own entry structs |
| `dao.go` | entry structs (DAOs) several methods share, with `json` tags and `toDomain()` |
| `mappers.go` | `map<Entity>Entry` |

The decorator takes the port type (`application.Repository`), not the concrete
repository, so it can wrap anything that implements it, including another decorator.

## Method by method

The decorator must implement **every** method of the port, or `main.go` stops
compiling. Each one is one of three kinds:

| Kind | Behaviour |
|---|---|
| read (`GetUser`) | read the key; on a miss, call the repository, then write the key |
| write that changes a cached entity (`Update`, `Delete`) | call the repository first, then delete the key |
| anything else (`CreateUser`, queries not cached) | pass straight through |

Delete on write instead of updating the cached value. A delete cannot leave a stale
value behind if two writes race; an update can.

## Failure

**A cache never fails a request.** Redis down, a timeout, an entry that no longer
decodes: log a warning (`slog.WarnContext`) and fall through to the repository. The cache makes things
faster; it is not a source of truth.

Repository errors pass through unwrapped (`return err`). The repository already
wrapped them, and the cache adds nothing worth saying.

## Keys and TTL

- `<entity>:<id>`, built by one function per entity (`userKey(id)`).
- Bump a version into the key (`user:v2:42`) when the entry's shape changes, so old
  entries are ignored instead of failing to decode.
- TTL comes from config (`CACHE_TTL`), never a literal.

## Secrets

Entries include every field, secrets too, since Redis is as trusted as the database
here. If it is not (shared instance, no auth), leave secret fields out of the entry
and do not cache reads that need them.
