# REST adapter

The inbound adapter for HTTP + JSON, at `internal/infrastructure/api/rest/`.

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
translates. Shared ones live in `handler.go`, next to the struct that carries them:
`validateRequest` and the validator setup (`validation.md`), and the two writers:

```go
func (h *Handler) writeError(w http.ResponseWriter, err error) {
	if errors.Is(err, context.Canceled) {
		return
	}
	status, body := mapErrorResponse(err)
	h.writeJSON(w, status, body)
}

func (h *Handler) writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}
```

## DTOs

- **Request**: what the client may send. `json` and `validate` tags and a
  `toDomain()` method. Fields the client must not set (`ID`, `CreatedAt`) are not
  in it. Domain enums are plain `string` fields validated with `enum=<name>` and
  converted in `toDomain()`.
- **Response**: what the client may see. `json` tags only. **No secret fields**:
  leave `Password` out of the struct entirely, so no later change can leak it.
- Exported names (`CreateUserRequest`, `UserResponse`), so they can be documented.
  `toDomain` and the mappers stay unexported.

## Mappers

`map` + the type produced: `mapUserResponse(user domain.User) UserResponse`.
Several domain values in is fine: `mapOrderResponse(order, customer) OrderResponse`.

`mappers.go` also holds the error tables and `mapErrorResponse`, the only place a
status is chosen (`errors.md` explains the order):

```go
var domainErrors = []struct {
	err    error
	status int
	field  string
	rule   string
}{
	{domain.ErrUsernameTaken, http.StatusConflict, "username", "taken"},
	{domain.ErrSignupsClosed, http.StatusUnprocessableEntity, "", "signups_closed"},
}

var errorKinds = []struct {
	err     error
	status  int
	code    string
	message string
}{
	{domain.ErrNotFound, http.StatusNotFound, "not_found", "The resource does not exist."},
	{domain.ErrConflict, http.StatusConflict, "conflict", "The request conflicts with existing data."},
	{domain.ErrInvalid, http.StatusUnprocessableEntity, "invalid_argument", "The request has invalid fields."},
	{domain.ErrUnavailable, http.StatusServiceUnavailable, "unavailable", "The service is temporarily unavailable."},
	{context.DeadlineExceeded, http.StatusServiceUnavailable, "unavailable", "The service is temporarily unavailable."},
}

var valueParams = map[string]bool{
	"min": true, "max": true, "len": true, "eq": true, "ne": true,
	"gt": true, "gte": true, "lt": true, "lte": true, "oneof": true,
}

func mapErrorResponse(err error) (int, ErrorResponse) {
	var tooLarge *http.MaxBytesError
	var wrongType *json.UnmarshalTypeError
	var failed validator.ValidationErrors
	switch {
	case errors.As(err, &tooLarge):
		return http.StatusRequestEntityTooLarge, ErrorResponse{Error: ErrorBody{Code: "body_too_large", Message: "The request body is too large."}}
	case errors.As(err, &wrongType):
		return http.StatusUnprocessableEntity, mapInvalidParamResponse(wrongType.Field, jsonType(wrongType.Type))
	case errors.Is(err, errMalformedBody):
		return http.StatusBadRequest, ErrorResponse{Error: ErrorBody{Code: "malformed_request", Message: "The request body is not valid JSON."}}
	case errors.As(err, &failed):
		return http.StatusUnprocessableEntity, ErrorResponse{Error: ErrorBody{Code: "invalid_argument", Message: "The request has invalid fields.", Fields: mapFieldResponses(failed)}}
	}

	var fields []FieldResponse
	status := 0
	for _, d := range domainErrors {
		if errors.Is(err, d.err) {
			if status == 0 {
				status = d.status
			}
			fields = append(fields, FieldResponse{Field: d.field, Rule: d.rule})
		}
	}
	for _, k := range errorKinds {
		if errors.Is(err, k.err) {
			if status == 0 {
				status = k.status
			}
			return status, ErrorResponse{Error: ErrorBody{Code: k.code, Message: k.message, Fields: fields}}
		}
	}
	return http.StatusInternalServerError, ErrorResponse{Error: ErrorBody{Code: "internal", Message: "Something went wrong."}}
}

func mapFieldResponses(failed validator.ValidationErrors) []FieldResponse {
	fields := make([]FieldResponse, 0, len(failed))
	for _, fe := range failed {
		field := fe.Field()
		if _, path, ok := strings.Cut(fe.Namespace(), "."); ok {
			field = path
		}
		param := ""
		if valueParams[fe.Tag()] {
			param = fe.Param()
		}
		fields = append(fields, FieldResponse{Field: field, Rule: fe.Tag(), Param: param})
	}
	return fields
}
```

`jsonType` (in `handler.go`) turns a Go type into a JSON one (`integer`, `string`,
`boolean`, `number`, `array`, `object`), so a wrong-type error never names a Go type.
`mapInvalidParamResponse` builds the same body for a bad path or query parameter:

```go
func mapInvalidParamResponse(field, expected string) ErrorResponse {
	return ErrorResponse{Error: ErrorBody{Code: "invalid_argument", Message: "The request has invalid fields.",
		Fields: []FieldResponse{{Field: field, Rule: "type", Param: expected}}}}
}
```

The error DTOs in `dto.go`:

```go
type ErrorResponse struct {
	Error ErrorBody `json:"error"`
}

type ErrorBody struct {
	Code    string          `json:"code"`
	Message string          `json:"message"`
	Fields  []FieldResponse `json:"fields,omitempty"`
}

type FieldResponse struct {
	Field string `json:"field,omitempty"`
	Rule  string `json:"rule"`
	Param string `json:"param,omitempty"`
}
```

## Pending

How 5xx errors are logged is not decided; `New` takes no logger yet. The error
body's shape and 422 versus 400 are also open. See `errors.md`.
