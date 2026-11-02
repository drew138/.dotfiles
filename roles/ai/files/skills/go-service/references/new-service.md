# Starting a new service

A new service is built by hand, in a fixed order, so each step compiles before the
next and every file exists because the first endpoint needs it.

## Ask first

Collect what the request does not say, in one message: module path, the first
entity and its fields, which fields are secret or unique, the store, and whether it
needs anything beyond REST (gRPC, a queue, a cache, calls to other services). Do not
guess a module path.

## Steps

1. **Module.** `go mod init <module>`, with `go 1.27` in `go.mod`. Create only the folders the first endpoint
   needs (`architecture.md`). Add a `pkg/` package when the service needs
   library-like code (`architecture.md`).
2. **Domain** (`domain.md`). `domain.go` with the first model, `enums.go` if it has a
   fixed set of values, and `errors.go` with the five generic kinds.
3. **Application** (`application.md`). `application.go` with `Application`, `New`
   and the first port.
4. **Entry point** (`wiring.md`). `cmd/rest/config.go` with a private `config` and
   `loadConfig()`.
5. **First endpoint.** Follow **Adding an endpoint** in `SKILL.md`: the outbound
   adapter, the use case, the REST adapter (`handler.go`, the route file, `dto.go`,
   `mappers.go`), then wiring.
6. **`cmd/rest/main.go`** (`wiring.md`). Load config, connect, build each adapter with `New`,
   serve, shut down on SIGTERM.
7. **Infra config at the root.** `migration/` with the first migration (constraints
   named, every column described), and a folder per other piece of infra the
   service uses (`rabbitmq/`, `redis/`).
8. **Dockerfile.** Multi-stage: build the entry point as a static binary
   (`go build ./cmd/rest` with `CGO_ENABLED=0`, `-trimpath`)
   in `golang:1.27`, run it from a minimal non-root image such as
   `gcr.io/distroless/static-debian12:nonroot`.
9. **Check.** `go build ./...`, `go vet ./...`, `go test ./...`, then
   the checklist in `SKILL.md`.
