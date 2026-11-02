# Validation

**Every layer validates what only it can know.** An API adapter is infrastructure
too, just facing inward.

| Layer | Validates | How |
|---|---|---|
| **Inbound adapter** (REST, gRPC) | the request's format: types, required fields, formats, lengths, enum values, rules between fields | go-playground/validator tags on the request DTO |
| **Application** | **stateful business rules**: what the business allows given the current state, or the order of operations | a private `validate<Method>` function, plain Go |
| **Domain** | rules about an entity's own data | methods on the entity |
| **Outbound adapter** (repository) | **relational and integrity rules** the store enforces: unique, foreign keys, not null | the store rejects it; the adapter translates the error |

Each rule lives in one layer. Do not repeat a rule lower down "to be safe".

## Inbound: go-playground/validator

Tags go on the **request DTO**, never on the domain:

```go
type CreateOrderRequest struct {
	CustomerID int64       `json:"customer_id" validate:"required,gt=0"`
	Email      string      `json:"email" validate:"required,email,max=254"`
	Status     string      `json:"status" validate:"required,enum=order_status"`
	Type       string      `json:"type" validate:"required,oneof=personal company"`
	TaxID      string      `json:"tax_id" validate:"required_if=Type company,max=20"`
	Items      []OrderItem `json:"items" validate:"required,min=1,dive"`
}
```

- **Lengths are validator tags** (`max=254`). The validator reports the field, the
  rule and the limit with no extra code. The database's own limit stays as a safety
  net (`repository.md`); if it ever fires, a tag is missing, which is a bug.
- **Cross-field rules** use the built-ins (`required_if`, `required_unless`,
  `eqfield`, `gtfield`, …) or a custom rule. A test for whether a cross-field rule
  belongs here: *would it still have to hold if the data arrived another way, by
  import or from another service?* If not, it is about this API's input and belongs
  here. If so, it is a business rule. It may live here while REST is the only entry
  point; when a second one arrives, it moves to the application.
- **Enum values** use the custom `enum` rule, which asks the domain's `Valid()`.
  Never `oneof` for a domain enum: that repeats the values. `oneof` is fine for
  values only this API knows (`personal company` above).

### The validator

Built once, in the handler's `New`, never as a package variable:

```go
var enums = map[string]func(string) bool{
	"order_status": func(v string) bool { return domain.OrderStatus(v).Valid() },
}

func newValidator() *validator.Validate {
	v := validator.New(validator.WithRequiredStructEnabled())
	v.RegisterTagNameFunc(func(f reflect.StructField) string {
		name, _, _ := strings.Cut(f.Tag.Get("json"), ",")
		if name == "-" {
			return ""
		}
		return name
	})
	_ = v.RegisterValidation("enum", func(fl validator.FieldLevel) bool {
		valid, ok := enums[fl.Param()]
		return ok && valid(fl.Field().String())
	})
	return v
}
```

- `RegisterTagNameFunc` makes errors name the JSON field (`customer_id`), not the Go
  one (`CustomerID`).
- Each domain enum gets one line in `enums`. Its key is the tag's parameter
  (`enum=order_status`).
- Custom rules are registered here too, with `RegisterValidation` for one field or
  `RegisterStructValidation` for a whole struct.

### validateRequest

One private method on the handler, in `handler.go`, used by every route. It reads,
decodes and validates:

```go
func (h *Handler) validateRequest(w http.ResponseWriter, r *http.Request, dst any) error {
	r.Body = http.MaxBytesReader(w, r.Body, maxBodyBytes)
	if err := json.NewDecoder(r.Body).Decode(dst); err != nil {
		var tooLarge *http.MaxBytesError
		var wrongType *json.UnmarshalTypeError
		if errors.As(err, &tooLarge) || errors.As(err, &wrongType) {
			return err
		}
		return fmt.Errorf("%w: %w", errMalformedBody, err)
	}
	return h.validate.Struct(dst)
}
```

It returns the library's own errors untouched. They never leave the REST package:
`mapErrorResponse` turns them into the response (`errors.md`), and nothing else ever
sees them. The library's raw message (`Key: 'CreateOrderRequest.Email' Error:Field
validation for 'Email' failed on the 'email' tag`) names a Go type and the library,
so it is never shown.

## Application: stateful business rules

Each use case that has rules gets a private function in its own file, named after
it: `PlaceOrder` → `validatePlaceOrder`. **The method loads; the function decides.**

```go
func (a *Application) PlaceOrder(ctx context.Context, order domain.Order) (domain.Order, error) {
	customer, err := a.customers.Find(ctx, order.CustomerID)
	if err != nil {
		return domain.Order{}, fmt.Errorf("finding customer %d: %w", order.CustomerID, err)
	}
	if err := validatePlaceOrder(order, customer); err != nil {
		return domain.Order{}, err
	}
	…
}

func validatePlaceOrder(order domain.Order, customer domain.Customer) error {
	var errs []error
	if !customer.Active {
		errs = append(errs, domain.ErrCustomerInactive)
	}
	if order.Total() > customer.CreditLimit {
		errs = append(errs, domain.ErrCreditLimitExceeded)
	}
	return errors.Join(errs...)
}
```

- **No I/O in the function.** It receives what the method loaded, so every rule is
  testable with plain values and no mocks.
- **Report every broken rule at once** with `errors.Join`, so the client fixes them
  all in one round trip. `errors.Join` returns nil for an empty list, and
  `errors.Is` finds each joined error even after the use case wraps it.
- **No validator package here.** Stateful rules need loaded data and business
  decisions, which is plain code.
- **Inline is fine for a single trivial check.** Two or more go in the function, so
  the method keeps reading as orchestration.
- The function is private to its method's file, like every helper
  (`application.md`).

## Outbound: relational and integrity rules

Unique, foreign keys and not null are enforced by the store and reported as errors.
The repository turns each into a domain error: a known constraint into a specific
error (`ErrUsernameTaken`), anything else into its kind. See `repository.md` and
`errors.md`.

## gRPC

Generated messages cannot carry tags. To keep one validation style, the gRPC
adapter has its own `dto.go` request struct with validator tags, maps the generated
message into it, validates it with the same validator setup, then calls
`toDomain()`. See `grpc.md`.
