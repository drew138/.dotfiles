# REST adapter

The inbound adapter for HTTP, at `internal/infrastructure/api/rest/`. Every HTTP route
the service exposes lives here, under one `Handler`: JSON endpoints, and server-rendered
pages (htmx or plain HTML) when the service has a web interface.

## Files

| File | Holds |
|---|---|
| `handler.go` | the `Application` interface, the `Handler` struct, `New`, and the private methods every route shares: `validateRequest`, `logged`, `writeError`, `writeJSON`; the validator setup |
| `<route_name>.go` | one route method per file, in snake_case: `createUser` lives in `create_user.go`, with the private helpers only that route uses (reading a multipart body, for example) |
| `<route_name>_dto.go` | that route's own request and response DTOs (`json` + `validate` tags, `toDomain()`) and the mappers only it uses |
| `dto.go` | DTOs several routes share, such as the error response DTOs |
| `mappers.go` | shared `map<Target>` functions, the error tables and `mapErrorResponse` |
| `web/` | templates and static files for server-rendered pages, embedded with `//go:embed web` |

The struct is `Handler`: it says what it is.

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

func New(router chi.Router, app Application) *Handler {
	h := &Handler{app: app, validate: newValidator()}
	router.Post("/users", h.logged(h.createUser))
	router.Get("/users/{id}", h.logged(h.getUser))
	return h
}
```

`New` takes the router and the application, builds the handler, and registers every
route. `main.go` only calls `rest.New(router, app)`. The routes are listed in one
place, so the whole API surface reads at a glance.

The router is `chi` (`github.com/go-chi/chi/v5`): `router.Post`, `router.Get`, and
path parameters read with `chi.URLParam(r, "id")`.

## A route

`create_user.go`:

```go
func (h *Handler) createUser(w http.ResponseWriter, r *http.Request) {
	var req CreateUserRequest
	if err := h.validateRequest(r, &req); err != nil {
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
	rr, recorded := w.(*responseRecorder)
	if errors.Is(err, context.Canceled) {
		if recorded {
			rr.status = statusClientClosedRequest
		}
		return
	}
	if recorded {
		rr.err = err
	}
	body := mapErrorResponse(err)
	h.writeJSON(w, body.Status, body)
}

func (h *Handler) writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}
```

### The line for each request

Every route is registered through `h.logged`, which writes the one log line per
request when it finishes (`logging.md`). `writeError` hands it the error, so a 5xx
line carries it:

```go
const statusClientClosedRequest = 499

type responseRecorder struct {
	http.ResponseWriter
	status int
	err    error
}

func (rr *responseRecorder) WriteHeader(status int) {
	rr.status = status
	rr.ResponseWriter.WriteHeader(status)
}

func (h *Handler) logged(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		rr := &responseRecorder{ResponseWriter: w, status: http.StatusOK}
		next(rr, r)

		attrs := []any{"method", r.Method, "route", chi.RouteContext(r.Context()).RoutePattern(), "status", rr.status, "duration_ms", time.Since(start).Milliseconds()}
		switch {
		case rr.status == statusClientClosedRequest:
			slog.InfoContext(r.Context(), "request cancelled", attrs...)
			return
		case rr.status >= http.StatusInternalServerError:
			slog.ErrorContext(r.Context(), "request failed", append(attrs, "error", rr.err)...)
			return
		}
		slog.InfoContext(r.Context(), "request handled", attrs...)
	}
}
```

The line logs the method and the route **pattern** (`/users/{id}`), so values in the
URL never reach the logs. A request whose client went away is recorded as `499`
("client closed request") and logged as `request cancelled`, so it never shows up
as a success.

## DTOs

- **Every DTO field carries a `json` tag**, in snake_case, including the view structs a
  route renders into a template and the form requests (which carry `form` tags too). The
  tag is the field's name on the wire; a DTO without one is not finished.
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

`mappers.go` also holds the error tables and `mapErrorResponse`, which builds the
error body and is the only place a status is chosen (`errors.md` explains the body
and the order):

```go
var domainErrors = []struct {
	err    error
	status int
	code   string
	field  string
}{
	{domain.ErrUsernameTaken, http.StatusConflict, "value_taken", "username"},
	{domain.ErrOrderAlreadyShipped, http.StatusBadRequest, "invalid_state", "status"},
	{domain.ErrCreditLimitExceeded, http.StatusBadRequest, "limit_exceeded", ""},
}

var errorKinds = []struct {
	err    error
	status int
	typ    string
	title  string
}{
	{domain.ErrNotFound, http.StatusNotFound, "not_found", "The resource does not exist."},
	{domain.ErrConflict, http.StatusConflict, "resource_conflict", "The request conflicts with existing data."},
	{domain.ErrInvalid, http.StatusBadRequest, "invalid_argument", "The request is invalid."},
	{domain.ErrUnavailable, http.StatusServiceUnavailable, "service_unavailable", "The service is temporarily unavailable."},
	{context.DeadlineExceeded, http.StatusServiceUnavailable, "service_unavailable", "The service is temporarily unavailable."},
}

var tagCodes = map[string]string{
	"required":         "value_required",
	"required_if":      "value_required",
	"required_unless":  "value_required",
	"required_with":    "value_required",
	"required_without": "value_required",
	"oneof":            "invalid_option",
	"enum":             "invalid_option",
	"email":            "invalid_email",
	"url":              "invalid_url",
	"uri":              "invalid_url",
	"uuid":             "invalid_uuid",
	"e164":             "invalid_phone",
	"datetime":         "invalid_date",
	"eqfield":          "field_mismatch",
	"unique":           "duplicate_value",
}

var lengthCodes = map[string]string{
	"max": "max_length",
	"lte": "max_length",
	"min": "min_length",
	"gte": "min_length",
	"len": "length_mismatch",
}

var numberCodes = map[string]string{
	"max": "less_than_or_equal",
	"lte": "less_than_or_equal",
	"lt":  "less_than",
	"min": "greater_than_or_equal",
	"gte": "greater_than_or_equal",
	"gt":  "greater_than",
}

func mapErrorResponse(err error) ErrorResponse {
	var wrongType *json.UnmarshalTypeError
	var failed validator.ValidationErrors
	switch {
	case errors.As(err, &wrongType):
		return mapInvalidParamResponse(wrongType.Field, jsonType(wrongType.Type))
	case errors.Is(err, errMalformedBody):
		return ErrorResponse{Type: "malformed_request", Title: "The request body is not valid JSON.", Status: http.StatusBadRequest}
	case errors.As(err, &failed):
		return ErrorResponse{Type: "invalid_argument", Title: "The request has invalid fields.", Status: http.StatusBadRequest, Errors: mapErrorDetails(failed)}
	}

	var details []ErrorDetail
	status := 0
	for _, d := range domainErrors {
		if errors.Is(err, d.err) {
			if status == 0 {
				status = d.status
			}
			details = append(details, ErrorDetail{Code: d.code, Field: d.field})
		}
	}
	for _, k := range errorKinds {
		if errors.Is(err, k.err) {
			if status == 0 {
				status = k.status
			}
			return ErrorResponse{Type: k.typ, Title: k.title, Status: status, Errors: details}
		}
	}
	return ErrorResponse{Type: "internal_error", Title: "Something went wrong.", Status: http.StatusInternalServerError}
}

func mapErrorDetails(failed validator.ValidationErrors) []ErrorDetail {
	details := make([]ErrorDetail, 0, len(failed))
	for _, fe := range failed {
		field := fe.Field()
		if _, path, ok := strings.Cut(fe.Namespace(), "."); ok {
			field = path
		}
		details = append(details, mapErrorDetail(fe, field))
	}
	return details
}

func mapErrorDetail(fe validator.FieldError, field string) ErrorDetail {
	switch fe.Kind() {
	case reflect.String, reflect.Slice, reflect.Array, reflect.Map:
		if code, ok := lengthCodes[fe.Tag()]; ok {
			return ErrorDetail{Code: code, Field: field, Param: fe.Param()}
		}
	case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64,
		reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64,
		reflect.Float32, reflect.Float64:
		if code, ok := numberCodes[fe.Tag()]; ok {
			return ErrorDetail{Code: code, Field: field, Param: fe.Param()}
		}
	}
	if code, ok := tagCodes[fe.Tag()]; ok {
		return ErrorDetail{Code: code, Field: field}
	}
	return ErrorDetail{Code: "invalid_value", Field: field}
}
```

`jsonType` (in `handler.go`) turns a Go type into a JSON one (`integer`, `string`,
`boolean`, `number`, `array`, `object`), so a wrong-type error never names a Go type.
`mapInvalidParamResponse` builds the body for a bad path or query parameter:

```go
func mapInvalidParamResponse(field, expected string) ErrorResponse {
	return ErrorResponse{Type: "invalid_argument", Title: "The request has invalid fields.", Status: http.StatusBadRequest,
		Errors: []ErrorDetail{{Code: "invalid_type", Field: field, Param: expected}}}
}
```

The error DTOs in `dto.go`:

```go
type ErrorResponse struct {
	Type   string        `json:"type"`
	Title  string        `json:"title"`
	Status int           `json:"status"`
	Errors []ErrorDetail `json:"errors,omitempty"`
}

type ErrorDetail struct {
	Code  string `json:"code"`
	Field string `json:"field,omitempty"`
	Param string `json:"param,omitempty"`
}
```

## Pages

When the service has a web interface, its pages are routes of this same `Handler`:
`getMonth` in `get_month.go` renders a template instead of writing JSON. Templates
(`web/*.html`) are parsed once in `New`; static files are served from `web/static/`.
Shared plumbing (`logged`, the session and same-origin checks, `render`) lives in
`handler.go` beside `writeJSON`, and errors are answered in the form the route
speaks: JSON for an API route, HTML for a page.
