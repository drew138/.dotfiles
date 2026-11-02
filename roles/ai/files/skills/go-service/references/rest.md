# REST adapter

The inbound adapter for HTTP + JSON, at `internal/infrastructure/api/rest/`.
Templates: `assets/templates/inbound/`.

## Files

| File | Holds |
|---|---|
| `handler.go` | the `Application` interface, the `Handler` struct, `New`, and the private methods every route shares: `validateRequest`, `writeError`, `writeJSON`; the validator setup |
| `<route_name>.go` | one route method per file, in snake_case: `createUser` lives in `create_user.go` |
| `dto.go` | request DTOs (`json` + `validate` tags, `toDomain()`), response DTOs, error response DTOs |
| `mappers.go` | `map<Target>` functions, the error tables and `mapErrorResponse` |

The struct is `Handler`, not `Rest`. A `rest.Rest` would follow the "name the type
after the package" habit, but `Handler` says what it is.

## The Application interface

`handler.go` declares the use cases the routes call, in this package:

```go
type Application interface {
	CreateUser(ctx context.Context, user domain.User) (domain.User, error)
	GetUser(ctx context.Context, id int64) (domain.User, error)
}
```

`*application.Application` satisfies it without this package importing the
application layer. Tests pass a fake. Add each new use case here with its route.

## Handler and New

```go
type Handler struct {
	app      Application
	validate *validator.Validate
}

func New(router *http.ServeMux, app Application) *Handler {
	h := &Handler{app: app, validate: newValidator()}
	router.HandleFunc("POST /users", h.createUser)
	router.HandleFunc("GET /users/{id}", h.getUser)
	return h
}
```

`New` takes the router and the application, builds the handler, and registers every
route. `main.go` only calls `rest.New(router, app)`. The routes are listed in one
place, so the whole API surface reads at a glance.

Go 1.22+ patterns on `http.ServeMux` (`"GET /users/{id}"`, read with
`r.PathValue("id")`). If the service already uses another router, keep it; the files
are the same.

## A route

```go
// create_user.go
func (h *Handler) createUser(w http.ResponseWriter, r *http.Request) {
	var req CreateUserRequest
	if err := h.validateRequest(w, r, &req); err != nil {
		h.writeError(w, err)
		return
	}

	user, err := h.app.CreateUser(r.Context(), req.toDomain())
	if err != nil {
		h.writeError(w, err)
		return
	}
	h.writeJSON(w, http.StatusCreated, mapUserResponse(user))
}
```

1. **Validate** with `h.validateRequest`: read, decode and validate the body in one
   call (`validation.md`).
2. **Call** the use case with `r.Context()` and domain values from `toDomain()`.
3. **Map** the result with its `map<Target>` and write it.

A path or query parameter that fails to parse is answered with
`mapInvalidParamResponse("id", "integer")`.

Every error goes to `h.writeError`. A route never picks a status for an error
itself; `mapErrorResponse` does, so every route answers the same way
(`errors.md`).

## Shared private methods

Helpers shared by routes are fine here: the rule against shared helpers is for
application use cases, which are separate business decisions. An adapter only
translates. Shared ones live in `handler.go`, next to the struct that carries them.

## DTOs

- **Request**: what the client may send. `json` and `validate` tags and a
  `toDomain()` method. Fields the client must not set (`ID`, `CreatedAt`) are not
  in it. Domain enums are plain `string` fields validated with `enum=<name>` and
  converted in `toDomain()`.
- **Response**: what the client may see. `json` tags only. **No secret fields**:
  leave `Password` out of the struct entirely, so no later change can leak it.
  `scripts/check` flags response fields named like secrets.
- Exported names (`CreateUserRequest`, `UserResponse`), so they can be documented.
  `toDomain` and the mappers stay unexported.

## Mappers

`map` + the type produced: `mapUserResponse(user domain.User) UserResponse`.
Several domain values in is fine: `mapOrderResponse(order, customer) OrderResponse`.
`mappers.go` also holds the two error tables (`domainErrors`, `errorKinds`) and
`mapErrorResponse`.

## Pending

How 5xx errors are logged is not decided; `New` takes no logger yet. The error
body's shape and 422 versus 400 are also open. See `errors.md`.
