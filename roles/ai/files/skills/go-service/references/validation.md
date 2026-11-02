# Validation

Three layers, each checking what only it can check. Every layer reports problems as
`domain.Violation`s, so the client gets one format whatever layer caught them.

| Layer | Checks | Example | Produces |
|---|---|---|---|
| Inbound adapter | request shape | missing field, bad email, wrong JSON type, body too large | `domain.Invalid(...)` or a transport error |
| Application | rules needing state | username taken, customer exists, credit limit | `domain.Invalid(...)` / `domain.Conflict(...)` |
| Domain | invariants needing no I/O | a shipped order cannot be cancelled | `domain.Invalid(...)` |

Do not repeat a check in a lower layer "to be safe". Each rule lives in one place, so
changing it means changing one place.

## Request shape: go-playground/validator

Tags go on the **request DTO** in `dto.go`, never on the domain:

```go
type CreateUserRequest struct {
	Username string `json:"username" validate:"required,min=3,max=32"`
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,min=8"`
	Items    []Item `json:"items" validate:"required,min=1,dive"`
}
```

The library stays in the inbound adapter: `rest/validation.go` is the only file that
imports it. Swapping libraries touches one file.

**Setup.** One validator per handler, built in `New`, never as a package variable. It
reports JSON names instead of Go names:

```go
func newValidator() *validator.Validate {
	v := validator.New(validator.WithRequiredStructEnabled())
	v.RegisterTagNameFunc(func(f reflect.StructField) string {
		name, _, _ := strings.Cut(f.Tag.Get("json"), ",")
		if name == "-" {
			return ""
		}
		return name
	})
	return v
}
```

**Normalising.** `validator.ValidationErrors` never leaves the adapter. Each
`FieldError` becomes a `domain.Violation`:

```go
for _, fe := range errs {
	field := fe.Field()
	if _, path, ok := strings.Cut(fe.Namespace(), "."); ok {
		field = path
	}
	violations = append(violations, domain.Violation{Field: field, Rule: fe.Tag(), Param: fe.Param()})
}
```

`Namespace()` is `CreateUserRequest.items[0].sku`. Dropping the first segment removes
the Go type name and keeps the path the client sent.

The validator's own message (`Key: 'CreateUserRequest.Email' Error:Field validation
for 'Email' failed on the 'email' tag`) names a Go type and the library. It is never
shown. The client sees:

```json
{"field": "email", "rule": "email", "message": "must be a valid email address"}
```

**Decoding errors** are shape errors too, and leak just as much if passed through:

| Decoder error | Becomes |
|---|---|
| `*http.MaxBytesError` | 413 `body_too_large` |
| `*json.UnmarshalTypeError` | violation `{field, "type", "integer"}`, with JSON type names, not Go ones |
| anything else (syntax, EOF) | 400 `malformed_request` |

`rest/validation.go` in the templates does all of this in `decode`; handlers call
`h.decode(w, r, &req)` and pass any error to `h.writeError`.

**Custom rules.** Register them on the validator in `newValidator`, and add their
message to `ruleMessages`:

```go
v.RegisterValidation("slug", func(fl validator.FieldLevel) bool {
	return slugPattern.MatchString(fl.Field().String())
})
```

A rule with no entry in `ruleMessages` falls back to "is invalid". Add the entry.

## gRPC

Generated messages cannot carry validator tags, and methods cannot be added to them.
Check shape in `grpc/validation.go` with plain code, returning the same violations:

```go
func validateCreateUserRequest(req *pb.CreateUserRequest) []domain.Violation {
	var violations []domain.Violation
	if req.GetUsername() == "" {
		violations = append(violations, domain.Violation{Field: "username", Rule: "required"})
	}
	return violations
}
```

For large proto surfaces, `buf.build/go/protovalidate` with rules in the `.proto` is
the alternative. Normalise its errors into violations the same way.

## Business rules in the application

A rule that needs state is checked in the use case, after loading:

```go
if existing, err := s.repo.FindByEmail(ctx, user.Email); err == nil && existing.ID != user.ID {
	return domain.User{}, domain.Conflict(domain.Violation{Field: "email", Rule: "taken"})
}
```

For uniqueness, prefer the database's unique constraint over a read-then-write check:
two concurrent requests both pass the read. The repository translates the constraint
violation into the same `domain.Conflict` (see `repository.md`), so the use case can
simply save.

Collect every violation you can before returning, so the client fixes everything in
one round trip:

```go
var violations []domain.Violation
if order.Total > customer.CreditLimit {
	violations = append(violations, domain.Violation{Field: "total", Rule: "lte", Param: strconv.FormatInt(customer.CreditLimit, 10)})
}
if len(violations) > 0 {
	return domain.Order{}, domain.Invalid(violations...)
}
```
