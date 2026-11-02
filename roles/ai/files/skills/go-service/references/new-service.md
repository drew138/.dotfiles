# Starting a new service

There is no generator. A new service is built by hand in a fixed order, so each step
compiles before the next and nothing is created that the first endpoint does not
need.

## Ask first

Collect what the request does not say, in one message: module path, the first
entity and its fields, which fields are secret or unique, the store, and whether it
needs anything beyond REST (gRPC, a queue, a cache, calls to other services). Do not
guess a module path.

## Steps

1. **Module.** `go mod init <module>`. Create only the folders the first endpoint
   needs (`architecture.md`). Add `pkg/` only for code another repository will
   import.
2. **Domain** (`domain.md`). `domain.go` with the first model, `enums.go` if it has a
   fixed set of values, and `errors.go` with the five generic kinds. Templates:
   `assets/templates/domain/`.
3. **Application** (`application.md`). `application.go` with `Application`, `New`
   and the first port. Template: `assets/templates/application/`.
4. **Config** (`wiring.md`). `internal/config/config.go` with `Load()`. Template:
   `assets/templates/config/`.
5. **First endpoint.** Follow **Adding an endpoint** in `SKILL.md`: the outbound
   adapter, the use case, the REST adapter (`handler.go`, the route file, `dto.go`,
   `mappers.go`), then wiring.
6. **main.go** (`wiring.md`). Load config, connect, build each adapter with `New`,
   serve, shut down on SIGTERM. Template: `assets/templates/cmd/`.
7. **Infra config at the root.** `migration/` with the first migration (constraints
   named, every column described), and a folder per other piece of infra the
   service uses (`rabbitmq/`, `redis/`).
8. **Dockerfile.** Multi-stage: build a static binary (`CGO_ENABLED=0`, `-trimpath`)
   in the Go image, run it from a minimal non-root image such as
   `gcr.io/distroless/static-debian12:nonroot`.
9. **Check.** `go build ./...`, `go vet ./...`, `go test ./...`, then
   `go -C <skill>/scripts run ./check "$PWD"`.
