# REST adapter

The inbound adapter for HTTP + JSON. Template: `assets/templates/base/internal/infrastructure/api/rest/`.

## Files

| File | Holds |
|---|---|
| `rest.go` | `Application` interface, `Handler`, `New`, `Register`, one unexported handler per route, `writeError`, `writeJSON` |
| `dto.go` | request DTOs (`json` + `validate` tags, `toDomain()`), response DTOs, `ErrorResponse` |
| `mappers.go` | `map<Response>(domain…)`, `mapErrorResponse`, `mapFieldResponses` |
| `validation.go` | `decode`, `newValidator`, `mapViolations`, `ruleMessages` |

When `rest.go` holds more than one resource, split handlers by resource
(`users.go`, `orders.go`) and keep `rest.go` for `Handler`, `New`, `Register` and the
writers.

## The Application interface

The handler declares the methods it calls, in its own package:

```go
type Application interface {
	CreateUser(ctx context.Context, user domain.User) (domain.User, error)
	GetUser(ctx context.Context, id int64) (domain.User, error)
}
```

`*application.Application` satisfies it without importing this package. Tests pass a
fake. Add each new use case here as you add its route.

## A handler, step by step

```go
func (h *Handler) createUser(w http.ResponseWriter, r *http.Request) {
	var req CreateUserRequest
	if err := h.decode(w, r, &req); err != nil {
		h.writeError(w, r, err)
		return
	}

	user, err := h.app.CreateUser(r.Context(), req.toDomain())
	if err != nil {
		h.writeError(w, r, err)
		return
	}
	h.writeJSON(w, r, http.StatusCreated, mapUserResponse(user))
}
```

1. Decode and validate with `h.decode`. Path and query parameters are parsed here;
   a bad one is `domain.Invalid(Violation{Field: "id", Rule: "type", Param: "integer"})`.
2. Call the use case with `r.Context()` and domain values.
3. Map the result with a `map<Response>` function, write it.

Every error goes to `h.writeError`. A handler never picks a status code for an error
itself. That is `mapErrorResponse`'s job, so every route answers the same way.

## DTOs

- **Request**: what the client may send. `json` and `validate` tags. A `toDomain()`
  method. Fields the client must not set (`ID`, `CreatedAt`) are not in it.
- **Response**: what the client may see. `json` tags only. **No secret fields**:
  leave `Password` out of the struct, rather than blanking it in the mapper, so no
  future change can leak it. `scripts/check` flags response fields named like
  secrets.
- Exported names (`CreateUserRequest`, `UserResponse`) so they can be documented in
  OpenAPI; the `toDomain` method and the mappers stay unexported.

## Mappers

`map` + the type produced: `mapUserResponse(user domain.User) UserResponse`. One
mapper per response type. Several domain values in, one response out, is fine:
`mapOrderResponse(order domain.Order, customer domain.Customer) OrderResponse`.

## Routing

Go 1.22+ patterns on `http.ServeMux`: `"POST /users"`, `"GET /users/{id}"`, read with
`r.PathValue("id")`. If the service already uses a router, use that; the file layout
is the same.

`GET /healthz` returns 204 and is registered first.

## Errors

The status table and response shape are in `errors.md`. `writeError` skips
`context.Canceled` and logs only 5xx.
