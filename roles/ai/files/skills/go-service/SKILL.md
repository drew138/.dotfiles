---
name: go-service
description: |
  Build Go microservices with ports-and-adapters (hexagonal) architecture,
  following our team's folder layout and conventions, step by step: start a new
  service, or add an endpoint, use case, repository, cache, queue publisher or
  consumer, provider (psp, auth, …) or gRPC adapter to an existing one. Covers how application
  methods orchestrate ports, where each kind of validation lives (go-playground
  validator in the API, stateful business rules in the application), string
  enums, and translating driver and upstream errors into domain errors and a
  client-safe error body.
  Triggers: "new service", "start a microservice", "add an endpoint", "add a
  use case", "add a repository", "add a cache", "publish an event", "consume a
  queue", "call another service", "add gRPC", "wire this up", "how should this
  error be returned", or any Go work under internal/domain, internal/application
  or internal/infrastructure.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Building a Go service

Interfaces, naming, logging and migrations follow `go-review`; read it, this skill
does not restate it. Tests are the `go-tests` skill's job: this skill builds the
code and hands the tests to it.

## Structure

A request travels left to right (solid arrows, 1–4) and the response comes back right
to left (dashed arrows, 5–8):

```mermaid
flowchart LR
    caller(["HTTP client<br/>gRPC client<br/>queue message"])

    subgraph inbound["Inbound adapters<br/>internal/infrastructure/"]
        direction TB
        rest["api/rest/"]
        grpc["api/grpc/"]
        consumer["queue/rabbitmq/"]
    end

    subgraph core["Core"]
        direction TB
        app["Application<br/>internal/application/<br/>use cases + ports"]
        domain["Domain<br/>internal/domain/<br/>models + enums + errors"]
        app --- domain
    end

    subgraph outbound["Outbound adapters<br/>internal/infrastructure/"]
        direction TB
        repo["repository/postgres/"]
        cache["cache/redis/"]
        psp["psp/adyen/"]
        pub["publisher/rabbitmq/"]
    end

    world[("database<br/>redis<br/>providers<br/>broker")]

    caller -->|"1. JSON / proto / message"| inbound
    inbound -->|"2. domain values"| app
    app -->|"3. calls a port"| outbound
    outbound -->|"4. SQL / commands / HTTP"| world

    world -.->|"5. rows / replies / driver errors"| outbound
    outbound -.->|"6. domain values / domain errors"| app
    app -.->|"7. result / wrapped domain error"| inbound
    inbound -.->|"8. response DTO / status + error JSON / ack"| caller
```

**Request**

1. An **inbound adapter** receives the request, validates its format with the
   validator, and converts it into domain values with the request DTO's
   `toDomain()`.
2. It calls a use case on the **Application**.
3. The use case loads what it needs and checks its stateful business rules by
   calling **ports**: interfaces it declares in `application.go`. It never knows
   which adapter is behind one.
4. An **outbound adapter** implements the port: it maps domain values into its own
   struct (`mapUserRow`) and talks to the database, cache, provider or broker.

**Response**

5. The outside world answers: rows, a cached entry, an upstream reply, or a driver
   error such as `sql.ErrNoRows` or a unique violation.
6. The outbound adapter converts the answer back into domain values (`toDomain()`),
   and any error into a domain error (`domain.ErrNotFound`,
   `domain.ErrUsernameTaken`). The core never sees a driver type.
7. The use case returns the domain result, or the domain error wrapped with what it
   was doing (`fmt.Errorf("saving user: %w", err)`), or re-translated when it knows
   better.
8. The inbound adapter maps the result into its response DTO (`mapUserResponse`),
   or maps the error into a status and a client-safe error body
   (`mapErrorResponse`); a queue consumer acks, dead-letters or requeues instead.

**Imports point the other way: always toward the core.** Adapters import `domain`;
the core imports no adapter. So any adapter can be replaced without touching the
core. Each entry point's `cmd/<entrypoint>/main.go` is the one place that knows the
pieces it uses, and it plugs
them together.

```
cmd/<entrypoint>/main.go                wiring for one entry point: rest, grpc, consumer, cli
cmd/<entrypoint>/config.go              its private config
internal/domain/{domain,enums,errors}.go  models; string enums; error values
internal/application/application.go     Application, New, ports
internal/application/<method>.go        one public method per file
internal/infrastructure/<kind>/<tech>/  adapters to things outside the process, inbound and outbound:
    inbound:  api/rest (every HTTP route, pages included), api/grpc, queue/rabbitmq
    outbound: repository/postgres, cache/redis, publisher/rabbitmq, psp/adyen, auth/cognito
pkg/<name>/                             in-process library code: clocks, hashing, tokens, retries; one package per purpose
migration/                              database migrations, at the root
api/  rabbitmq/  redis/  …               other infra config, one root folder each
```

The full tree, the request flow and a "what goes where" table are in
`references/architecture.md`.

## Rules

- **`internal/infrastructure/` holds adapters to things outside the process, and only
  those.** Inbound, what calls the service (`api/rest`, `api/grpc`, `queue/rabbitmq`);
  outbound, what the service reaches over I/O (a database, a cache, a broker, another
  service or provider). Code that runs inside the process (the clock, password hashing,
  token or ID generation) is library code in `pkg/`, which the application calls
  directly.
- **Ports are the outbound adapters the application uses**, declared in
  `application.go`, one port per adapter. A service with only a database has one
  `Repository` port holding every method the use cases need from it, and
  `application.New(repo)` takes it once.
- **The application imports `pkg/` where it needs it** and holds nothing but its ports:
  `Application{repo}`, built with `application.New(repo)`. Values that are random or
  time-based (IDs, tokens, timestamps, salted hashes) are made where they are stored:
  the repository generates them, the way a database generates an ID, so use cases stay
  deterministic. See "Library code" in `references/application.md`.
- **Adapters live at `internal/infrastructure/<kind>/<tech>/`.** The **kind** is the
  role the adapter plays, named for what it does for us (`repository`, `cache`,
  `publisher`, `psp`, `auth`, `api`, `queue`). The **tech** is the concrete
  technology or provider (`postgres`, `redis`, `rabbitmq`, `adyen`, `stripe`,
  `cognito`, `rest`, `grpc`). Outbound, the kind names the port and the
  struct: `psp/adyen` implements the `PSP` port with `adyen.PSP`. Full definitions
  and examples: "Kinds and techs" in `references/architecture.md`.
- **Dependencies point inward.** Infrastructure → application → domain. The domain
  imports nothing from the service; the application imports only the domain and `pkg/`.
- **`pkg/` holds library-like code**: logic the service needs that stands on its
  own and could be exported, small libraries we write ourselves, and everything
  that would otherwise be a "utility". Each lives in its own package named for what
  it does (`pkg/retry`, `pkg/money`), never `pkg/utils`. A `pkg/` package imports
  nothing from `internal/`, so any layer may import it; most often it is the
  application that does.
- **Domain structs carry no tags.** Serialisation belongs to the adapter that needs it.
- **The domain holds the app's core business entities only**, the things the whole
  service is about (a `Movement`, a `User`, an `Order`), with their methods, enums
  and errors. Read models, view shapes, filters, query results and technical records
  such as sessions live where they are used: in the adapter that builds them, or as
  plain values (counts, maps, IDs) crossing a port. An adapter's DAOs and DTOs convert
  to a domain entity when they carry one, and to plain values otherwise.
- **Request bodies are read with Go's defaults.** Handlers decode `r.Body` directly.
- **Enums are strings, never `iota`**, in `domain/enums.go`, each with a `Valid()`
  method that is the only list of its values. Values that matter to one adapter
  only stay in that adapter as plain strings.
- **Logic that depends only on an entity's own data is a method on it** in the
  domain: transitions, derived values, eligibility.
- **`application.go` holds only** the `Application` struct, `New` and the ports it consumes. Use cases are methods on `*Application`.
- **One method per file, in the application and in every adapter**, in snake_case:
  `CreateUser` lives in `create_user.go` with its private helpers. In an adapter this
  is every route handler, RPC and message handler, and every method that implements a
  port (`GetUser` in `repository/postgres/get_user.go`, `ChargePayment` in `psp/adyen/charge_payment.go`). The
  adapter's main file (`postgres.go`, `handler.go`) keeps the struct, `New` and the
  helpers its methods share (`domainError`, `writeError`).
- **Never share a private helper between method files.** Duplicate it under a name
  specific to each method. Example: `CreateUser` and `UpdateUser` both use a shared
  `normalizeEmail` that trims and lowercases. Signup then has to strip `+alias` parts
  to stop people opening duplicate accounts, so someone edits `normalizeEmail`, and
  `UpdateUser` now silently rewrites the address of every user who saves
  `me+work@x.com`. Nothing in `update_user.go` changed, so no reviewer looks there.
  With `normalizeCreateUserEmail` and `normalizeUpdateUserEmail`, the change stays
  in the one file it was meant for. Full code in `references/application.md`.
- **Databases are queried with plain SQL. Never GORM or any other ORM.** Each
  repository method writes its SQL directly through `database/sql` or the driver
  (`pgx`). With AI writing the code, SQL costs nothing extra, and every query stays
  visible, reviewable and tunable in the repository that runs it.
- **Methods are named `<verb><Entity>`**: use cases, adapter methods and route handlers
  alike. `CreateUser`, `GetUser`, `ListUsers`, `UpdateUser`, `DeleteUser`,
  `ListCategoryTotals`, `RegisterUser`; a route handler is the same in lower camel case
  (`createUser`, `getUserPage`). The file carries the same name in snake_case
  (`list_category_totals.go`).
- **`New` and `new` are for constructors only.** A method or route that makes something
  starts with `Create` (`CreateSession`, `getCreateUserForm`), and a library function that
  produces a value is named for what it does (`token.Create`).
- **Every package exposes `New`**: `postgres.New(db)`, `redis.New(client, repo)`,
  `application.New(repo)`. Never `NewPostgresRepository`.
- **`init` is forbidden, always.** It runs at import time, in an order nobody chose,
  and cannot be tested or skipped. The work goes in `New` or in `main`.
- **`panic` is forbidden, always.** Every failure is returned as an error. The one
  place the program may stop is `main`, at startup: when config is invalid or a
  connection cannot be made, `run` returns the error and `main` logs it and exits
  (`os.Exit(1)`, or `log.Fatal`).
- **Every adapter owns its structs.** An adapter that stores data (a repository or a
  cache) calls them DAOs; every other adapter calls them DTOs. A method's own structs
  live beside it: `find_user.go` has `find_user_dao.go`, `create_user.go` (a route) has
  `create_user_dto.go`. Structs several methods share stay in the adapter's `dao.go` or
  `dto.go`. Each struct has a `toDomain()` method when it carries a domain entity;
  `mappers.go` has the shared `map<Target>(domain…) Target` functions for the other
  direction, and a mapper only one method uses goes in that method's `_dao.go` or
  `_dto.go`. **Target** is the adapter struct being built: the DTO the adapter sends or
  the DAO it stores.
- **One HTTP adapter, `api/rest`, serves every HTTP route**: JSON endpoints and
  server-rendered pages (htmx or plain HTML) alike, under one `Handler`. Templates and
  static files live in `api/rest/web/`, embedded with `//go:embed web`. The tech names
  the protocol, and htmx is HTTP.
- **Secrets never reach output.** Leave them out of response DTOs and messages
  entirely; clear them from what a repository returns after a write.
- **Logging PII or PCI data is absolutely forbidden.** No names, emails, phone
  numbers, addresses, national IDs, card numbers, CVVs, passwords or tokens, in any
  log line, at any level; a masked value is allowed. This includes **error messages**, because
  errors end up in logs: wrap with IDs (`fmt.Errorf("saving user %d: %w", id, err)`),
  never with the value (`"saving user ana@x.com"`). Never log a request body, a DTO
  or a domain struct whole. If a value is needed to debug, log its ID.
- **Logging** (`references/logging.md`): the logger is set once in `main` as the
  default, and code calls the context variants (`slog.InfoContext(ctx, …)`).
  Structured lines with named fields. Every error is logged once, where it stops;
  never logged and returned. Every request produces one line when it finishes.
- **Each entry point loads its config in `cmd/<entrypoint>/config.go`**: a private
  `config` struct read from environment variables with the standard library and
  small helpers. Defaults where they make sense, required otherwise, and startup
  stops at the first missing or invalid value. There
  is one `Application`, and every entry point builds all of it, so each reads the
  settings the application needs plus its own server settings.
- **Go 1.27 by default** (`go 1.27` in `go.mod`, `golang:1.27` to build), and
  **`chi`** (`github.com/go-chi/chi/v5`) as the HTTP router.
- **No comments.** Code carries no comments at all: no doc comments, no section
  labels, no explanations of what a line does. Two exceptions only:
  - compiler directives (`//go:build`, `//go:generate`, `//go:embed`);
  - a piece of logic that deliberately goes against how it would normally be done,
    for a very specific reason the reader could not work out from the code.
  This holds everywhere: domain, application, adapters, `pkg/`.
- **Timeouts and concurrency limits are set by the user, never by this skill.** Add
  a server or client timeout, a deadline, a semaphore or any other limit on time or
  concurrent work only when the request asks for it, with the value it gives. When one seems needed, mention it in
  the summary instead.
- **`ctx context.Context` comes first** in every port and service method.
- **Every layer validates what only it can know.** The API checks the request's
  format with go-playground/validator tags on its DTO (types, required, lengths,
  enums, rules between fields). The application checks **stateful business
  rules** in a private, pure `validate<Method>`. The store enforces relational
  rules (unique, foreign keys), which the repository translates.
- **Errors are plain values in `domain/errors.go`:** five generic kinds
  (`ErrNotFound`, `ErrConflict`, `ErrInvalid`, `ErrUnavailable`, `ErrInternal`) and
  specific errors that wrap one (`ErrUsernameTaken` wraps `ErrConflict`). Every
  error leaving an outbound adapter is a domain error; inbound adapters turn them
  into a status and a fixed message. `err.Error()` never reaches a client.

## What are you doing?

| Task | Read |
|---|---|
| a new service | `references/new-service.md` |
| an endpoint or use case | the steps below |
| a model, enum, entity method or error | `references/domain.md` |
| how a use case should orchestrate ports | `references/application.md` |
| a validation rule, anywhere | `references/validation.md` |
| how an error should travel or be returned | `references/errors.md` |
| a database store | `references/repository.md` |
| a cache | `references/cache.md` |
| publishing or consuming messages | `references/queue.md` |
| calling another service or provider (payments, auth, …) | `references/providers.md` |
| a REST handler | `references/rest.md` |
| a gRPC service | `references/grpc.md` |
| an entry point, `main.go` or config | `references/wiring.md` |
| what to log, where, at which level | `references/logging.md` |

## Adding an endpoint

Work through the steps in order. **Read each step's reference when you reach it**,
not before. The code in each reference shows the shape every file takes; write the
real code for the service's tech following that shape. Run `go build ./...` at the end of every step; the next
step starts from code that compiles. After each step, say in one line what was added.
Stop and ask only when a step needs a decision the request did not make: a field
name, a rule, a status, which store.

1. **Domain** (`domain.md`). Add or extend the model in `domain.go`, any enum in
   `enums.go`, and entity methods for logic on its own data. Add a specific error to
   `errors.go`, wrapping a kind, for each failure a caller must be told precisely.
2. **Port** (`application.md`). Add the method the use case needs to the consumed
   interface in `application.go`, in domain types, `ctx` first. Add a new interface
   only for a new kind of dependency.
3. **Outbound adapter** (`repository.md`, `cache.md`, `providers.md` or `queue.md`).
   Implement the port: the method in `<method>.go`, its structs in `<method>_dao.go` (repository, cache) or `<method>_dto.go`, `mappers.go`, and error
   translation into domain errors. Add each new named constraint to
   `constraintErrors`. If a decorator wraps the port, implement the method there
   too.
4. **Use case** (`application.md`, `validation.md`). Create
   `application/<method_name>.go`: load, check stateful rules with
   `validate<Method>`, decide, persist, side effects, in that order. Wrap,
   re-translate or deliberately swallow every port error.
5. **Inbound adapter** (`rest.md`, `grpc.md` or `queue.md`; `validation.md`,
   `errors.md`). Request DTO with validator tags and `toDomain()`; response DTO
   without secrets and its `map<Response>`; the route in its own file; the route
   registered in `New` and the use case added to the `Application` interface in
   `handler.go`; a row in the error table for each new specific error.
6. **Wiring** (`wiring.md`). Construct each new adapter in `main.go` with `New` and
   pass it to whatever consumes it. A new setting for the application goes in every
   entry point's `config.go`.
7. **Tests.** Use the `go-tests` skill to write them; it owns every testing rule.
8. **Check.** `go build ./...`, `go vet ./...`, `go test ./...`, then the
   checklist below, then the diff against `go-review`.

## Checklist before reporting done

Walk through every item against the changed code. Fix what fails; do not report
the work done with an item failing.

- [ ] No struct tags on anything in `internal/domain`.
- [ ] Enums are string types in `domain/enums.go`, no `iota`, each with `Valid()`.
- [ ] `domain` imports nothing from the service but `pkg/`; `application` imports only
      `domain` and `pkg/`.
- [ ] Every timeout and concurrency limit was asked for, with the value asked for.
- [ ] `application.go` holds only `Application`, `New` and the ports.
- [ ] `internal/infrastructure/` holds only adapters to things outside the process; clocks,
      hashing, token and ID generation live in `pkg/`, and the application's ports are
      outbound adapters only.
- [ ] Each method file holds exactly one public method on `*Application`, and its
      snake_case name matches the method.
- [ ] No private helper is called from a method file other than its own.
- [ ] Stateful rules are in a pure `validate<Method>`, joined with `errors.Join`.
- [ ] No `func init()` anywhere, `cmd/` included.
- [ ] No `panic` anywhere; startup failures return to `main`, which logs and exits.
- [ ] No comments, except compiler directives and logic that deliberately breaks the
      usual way for a specific reason.
- [ ] Constructors are `New`, never `NewSomething`; nothing else starts with `New`/`new`.
- [ ] Use cases, adapter methods and route handlers are named `<verb><Entity>`.
- [ ] Every field of every DTO in the REST layer has a `json` tag.
- [ ] A method's own structs are in `<method>_dao.go` (repository, cache) or
      `<method>_dto.go` (every other adapter); shared ones in `dao.go` or `dto.go`; they
      hold structs, their `toDomain()` and that method's mappers only.
- [ ] Every HTTP route, pages included, is in `api/rest`, with templates and static
      files in `api/rest/web/`.
- [ ] No secret fields in response DTOs or published messages.
- [ ] `ctx context.Context` first in every port and use case method.
- [ ] Every error leaving an outbound adapter is a domain error; new named
      constraints are in `constraintErrors`; new specific errors have a row in the
      inbound adapter's error table.
- [ ] No PII or PCI in any log line or error message (masked values allowed).
- [ ] Log calls use the context variants; no error is both logged and returned.
- [ ] Queries are plain SQL; no ORM in `go.mod`.
- [ ] Every new migration column is described; nothing left as `TODO`.
