---
name: go-service
description: |
  Build Go microservices in the house hexagonal layout, step by step: scaffold a
  new service, or add an endpoint or use case to an existing one, from domain to
  port, adapters, service method, handler and wiring in main. Tag-free domain,
  package-scoped New constructors, one file per service method, adapter-local
  DTOs with toDomain() and map-prefixed mapper functions.
  Triggers: "new service", "scaffold a microservice", "add an endpoint", "add a
  use case", "add a repository", "add a handler", "wire this up", or any Go work
  adding code under internal/domain, internal/application or
  internal/infrastructure.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Building a Go service

Interfaces, naming, logging, config and `init` follow `go-review`. Tests follow
`go-tests`. Read both; this skill does not restate them.

A complete, compiling example of one endpoint across every layer is in
`references/example.md`. Read it before writing the first file.

## Layout

```
cmd/service/main.go                  wiring only
internal/config/config.go            the one config package
internal/domain/domain.go            models and sentinel errors
internal/application/service.go      Service, New, and the ports it consumes
internal/application/<method>.go     one public method per file
internal/infrastructure/
  repository/<store>/                mysql/, postgres/
  cache/<store>/                     redis/, a decorator over a repository
  api/<protocol>/                    rest/, grpc/
api/                                 OpenAPI or proto contracts
```

Dependencies point inward: infrastructure → application → domain. Domain imports
nothing from the service; application imports only domain.

## Rules

- **Domain structs carry no tags.** No `json`, `db` or `validate`. Serialisation
  belongs to whichever adapter needs it.
- **`service.go` holds only** the `Service` struct, `New`, and the interfaces it
  consumes.
- **One public method per file**, named in snake_case: `CreateUser` lives in
  `create_user.go`, with its private helpers.
- **Never share a private helper between method files.** If two need the same
  logic, duplicate it under a name specific to each (`normalizeCreateUserUsername`).
  A shared helper couples two use cases: changing one silently changes the other.
- **Every package exposes `New`**: `mysql.New(db)`, `redis.New(client, repo)`,
  `application.New(repo)`. Never `NewMySQLRepository`.
- **Every adapter owns its structs.** Each adapter folder has `dto.go` with
  tagged structs and a `toDomain()` method, and `mappers.go` with
  `map<Target>(domain) Target` functions: `mapUserResponse(u domain.User) UserResponse`.
- **Sensitive fields never reach output.** Leave them out of the response DTO
  entirely; don't blank them in the mapper. A repository returning a saved
  entity clears secrets like `Password` before returning it.
- **`ctx context.Context` is the first parameter** of every port and service
  method.
- **Errors are translated at each boundary.** Outbound adapters turn driver
  errors into domain sentinels (`sql.ErrNoRows` → `domain.ErrNotFound`). Inbound
  adapters turn sentinels into status codes. The application never sees a driver
  error or a status code.

## Adding an endpoint

Work through these steps in order. Run `go build ./...` at the end of each one;
the next step starts from code that compiles. After each step, say in one line
what was added. Stop and ask only when a step needs a decision the request did
not make, such as a field name, a status code or which store to use.

1. **Domain.** Add or extend the model and any new sentinel error in
   `domain.go`.
2. **Port.** Add the method the use case needs to the consumed interface in
   `service.go`. Add a new interface only for a new kind of dependency.
3. **Outbound adapter.** Implement the port in
   `infrastructure/repository/<store>/`: structs in `dto.go`, `mappers.go`, the
   method, and error translation. If a cache decorator wraps that port,
   implement the method there too, or wiring will not compile.
4. **Use case.** Create `application/<method_name>.go` with the public method
   and its own private helpers.
5. **Inbound adapter.** In `infrastructure/api/<protocol>/`: request DTO with
   `toDomain()`, response DTO and its `map<Response>` in `mappers.go`, the
   handler, the method added to the handler's consumed `Service` interface, the
   route, and error to status mapping.
6. **Wiring.** In `cmd/service/main.go`, construct each new adapter with `New`
   and pass it to whatever consumes it. Plain calls, no DI container.
7. **Tests.** Follow `go-tests`: unit tests for the use case and handler,
   integration tests for the repository.
8. **Check.** Run `go build ./...`, `go vet ./...` and `go test ./...`, then
   check the diff against `go-review`.

## Scaffolding a new service

1. `go mod init`, then create only the folders the first endpoint needs.
   Add `pkg/` only for code another repository will import.
2. Write `internal/config/config.go` and `cmd/service/main.go`: load config,
   open connections, construct with `New`, serve, shut down on SIGTERM. Use the
   `main.go` in the example as the template.
3. Add a multi-stage `Dockerfile` that builds a static binary
   (`CGO_ENABLED=0`) into a minimal runtime image.
4. Build the first endpoint with **Adding an endpoint** above.
