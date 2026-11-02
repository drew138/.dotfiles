# Scaffolding a service

`scripts/scaffold` renders a complete, compiling service from `assets/templates/`:
domain, application with create and get use cases, REST with validation and error
mapping, a repository with error translation, migrations, config, `main.go` and a
`Dockerfile`. Optionally a Redis cache and a gRPC adapter.

## Run it

```bash
go -C <skill>/scripts run ./scaffold \
  -module github.com/acme/users \
  -dir "$PWD/users" \
  -entity User \
  -fields "Username:string:unique,Email:string:unique,Password:string:secret,BornAt:time.Time" \
  -store postgres \
  -cache -grpc
```

`go -C` runs the script in its own module, so `-dir` must be absolute. The target
must not exist or must be empty.

| Flag | Default | Meaning |
|---|---|---|
| `-module` | required | module path; its last element names the service |
| `-dir` | required | absolute path to create |
| `-entity` | required | first entity, PascalCase |
| `-fields` | `Name:string` | `Name:type[:secret][:unique]`, comma separated. Types: `string`, `int`, `int64`, `bool`, `float64`, `time.Time`. `ID int64` is added |
| `-store` | `postgres` | `postgres` or `mysql` |
| `-table` | snake entity + `s` | table name and REST path |
| `-cache` | off | Redis decorator over the repository |
| `-grpc` | off | gRPC adapter, proto and generation directive |

Modifiers:

- `secret` keeps the field out of every response DTO and proto response message,
  and clears it from what `Save` returns.
- `unique` adds a `UNIQUE` constraint and its `uniqueFields` entry, so a duplicate
  comes back as `409` with `{"field": "<name>", "rule": "taken"}`.

## Ask before running

The flags need decisions the request may not contain. Ask for whatever is missing
in one message: module path, entity and fields (which are secret, which unique),
store, and whether it needs a cache or gRPC. Do not guess a module path.

## After it runs

```bash
cd users
go generate ./internal/infrastructure/api/grpc/   # only with -grpc
go mod tidy
go build ./... && go vet ./...
```

Then:

1. Replace every `TODO: describe` in `migration/` with what the table or column
   holds. `scripts/check` fails until you do.
2. Adjust `validate` tags in `rest/dto.go` beyond `required`: lengths, formats,
   `email`, `oneof`.
3. Add business rules to the generated use cases (`references/application.md`).
4. Write tests per `go-tests`.
5. Run `go -C <skill>/scripts run ./check "$PWD"`.

For the second and later endpoints, follow **Adding an endpoint** in `SKILL.md`;
the scaffold is for the first one only.

## Templates as reference

When writing a file by hand, open its template first: it is the canonical shape.
Placeholders are Go `text/template` fields: `{{.Entity}}` (`User`), `{{.Var}}`
(`user`), `{{.Snake}}` (`user`), `{{.Table}}` (`users`), `{{.Module}}`, and
`{{range .Fields}}` loops.

| Directory | Rendered when |
|---|---|
| `base/` | always |
| `postgres/`, `mysql/` | `-store` |
| `cache-redis/` | `-cache` |
| `grpc/` | `-grpc` |

## Dockerfile

Multi-stage: `golang:<version>-alpine` builds a static binary (`CGO_ENABLED=0`,
`-trimpath`), and `gcr.io/distroless/static-debian12:nonroot` runs it. No shell, no
package manager, not root.
