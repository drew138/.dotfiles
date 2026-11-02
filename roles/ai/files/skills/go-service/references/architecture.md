# Architecture

## Layers and dependencies

```mermaid
flowchart TB
    subgraph cmd["cmd/service"]
        main["main.go<br/>wiring only"]
    end
    subgraph infra["internal/infrastructure — adapters"]
        direction LR
        subgraph inbound["inbound (driving)"]
            rest["api/rest"]
            grpc["api/grpc"]
            consumer["api/rabbitmq<br/>queue consumer"]
        end
        subgraph outbound["outbound (driven)"]
            repo["repository/postgres · mysql"]
            cache["cache/redis"]
            client["client/&lt;name&gt;"]
            publisher["publisher/rabbitmq"]
        end
    end
    subgraph app["internal/application — use cases"]
        appgo["application.go<br/>Service · New · ports"]
        methods["create_user.go · get_user.go · …"]
    end
    subgraph dom["internal/domain"]
        domgo["domain.go — models"]
        errs["errors.go — error vocabulary"]
    end
    config["internal/config"]

    main --> config
    main -->|"New(...)"| rest & grpc & consumer & repo & cache & client & publisher & appgo
    rest & grpc & consumer -->|"call through their own Service interface"| methods
    methods --> appgo
    repo & cache & client & publisher -.->|"implement a port"| appgo
    cache -.->|"decorates"| repo
    appgo & methods --> dom
    rest & grpc & consumer & repo & cache & client & publisher --> dom
```

Arrows are imports. Every arrow points inward or sideways into `domain`; nothing in
`domain` or `application` imports an adapter. `scripts/check` enforces this.

## Request flow

```mermaid
sequenceDiagram
    participant C as Client
    participant H as rest handler
    participant S as application.Service
    participant R as repository adapter
    participant DB as Database

    C->>H: POST /users {json}
    H->>H: decode + validate CreateUserRequest
    H->>S: CreateUser(ctx, req.toDomain())
    S->>R: Save(ctx, domain.User) via Repository port
    R->>R: mapUserRow(user)
    R->>DB: INSERT … RETURNING id
    DB-->>R: row / driver error
    R-->>S: domain.User, or a domain error
    S-->>H: domain.User, or a wrapped domain error
    H->>H: mapUserResponse(user) or mapErrorResponse(err)
    H-->>C: 201 {json} / 4xx-5xx {"error": …}
```

Data changes shape at each boundary: JSON → request DTO → domain → row → SQL, and back.
Errors change shape the same way: driver error → domain error → status code + JSON body.

## Full tree

```
my-service/
├── cmd/service/main.go                      wiring: config, connections, New, serve, shutdown
├── internal/
│   ├── config/config.go                     the only config package
│   ├── domain/
│   │   ├── domain.go                        models, no tags
│   │   └── errors.go                        ErrNotFound, ErrConflict, ErrInvalid, ErrUnavailable, ViolationError
│   ├── application/
│   │   ├── application.go                   Service, New, ports (consumed interfaces)
│   │   ├── create_user.go                   one public method + its private helpers
│   │   └── get_user.go
│   └── infrastructure/
│       ├── api/
│       │   ├── rest/
│       │   │   ├── rest.go                  Handler, New, Register, handlers, Service interface
│       │   │   ├── dto.go                   request/response/error structs, toDomain()
│       │   │   ├── mappers.go               map<Target> functions, error → response
│       │   │   └── validation.go            decoding, validator setup, violation mapping
│       │   ├── grpc/
│       │   │   ├── grpc.go                  Server, New, Register, RPCs, error → status
│       │   │   ├── mappers.go               proto ↔ domain, violations → BadRequest
│       │   │   ├── validation.go            request shape checks
│       │   │   └── pb/                      generated, never edited
│       │   └── rabbitmq/                    queue consumer: Consumer, Run, ack/nack by error kind
│       ├── repository/
│       │   └── postgres/                    or mysql/
│       │       ├── postgres.go              Repository, New, port methods, error translation
│       │       ├── dto.go                   row structs, toDomain()
│       │       └── mappers.go               map<Entity>Row
│       ├── cache/redis/                     decorator over a repository port
│       ├── client/<name>/                   outbound calls to other services
│       └── publisher/rabbitmq/              Publisher port: one method per domain event
├── api/proto/<service>/v1/*.proto           contracts (OpenAPI specs live in api/ too)
├── migration/000001_<name>.{up,down}.sql    golang-migrate files
├── Dockerfile
└── go.mod
```

## What goes where

| Question | Answer |
|---|---|
| A new entity or field | `domain.go` |
| A new kind of failure | a sentinel in `errors.go`, only if a caller must react differently to it |
| A rule that needs no I/O | a method on the domain entity |
| A rule that needs state (exists, unique, limits) | the application method |
| Request shape (required, format, length) | the inbound adapter's DTO tags or validation.go |
| Anything with SQL, JSON, HTTP, Redis, proto | an adapter |
| Building and connecting things | `main.go` |
| Code another repository imports | `pkg/`, and only then |

Banned anywhere: `func init()`, `utils`/`helpers`/`common` packages, a second config
package. See `go-review` for the reasons.
