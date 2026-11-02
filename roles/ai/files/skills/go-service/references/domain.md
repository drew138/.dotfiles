# Domain

`internal/domain` is the service's language. Everything else translates into it and out
of it. Template: `assets/templates/base/internal/domain/`.

## domain.go — models

- Every model of the service lives here.
- **No struct tags.** `json`, `db`, `validate`, `bson`: none. A tag is a promise about
  serialisation, and serialisation belongs to whichever adapter needs it. Two adapters
  rarely want the same shape (the response hides `Password`, the row keeps it).
- No imports outside the standard library.
- IDs are plain types (`int64`, `string`). How they are generated is an adapter concern
  (database sequence) or a port (`IDGenerator`) when the application must know the ID
  before saving.

## Behaviour on entities

Pure rules belong on the entity as methods: no I/O, no context, no ports.

```go
func (o Order) Cancel(now time.Time) (Order, error) {
	if o.Status == StatusShipped {
		return Order{}, Invalid(Violation{Field: "status", Rule: "already_shipped"})
	}
	o.Status = StatusCancelled
	o.CancelledAt = now
	return o, nil
}
```

Return a new value instead of mutating, so a failed rule leaves the caller's copy
untouched. Pass time in (`now`); never call `time.Now()` in the domain, or the rule
cannot be tested.

If a rule needs a database or another service to decide, it is not a domain rule. It
belongs in the application method that orchestrates the lookup.

## errors.go — the error vocabulary

The only errors that cross from outbound adapters, through the application, to the
inbound adapters.

| Value | Meaning | REST | gRPC |
|---|---|---|---|
| `ErrNotFound` | the thing asked for does not exist | 404 | NotFound |
| `ErrConflict` | the request clashes with current state | 409 | AlreadyExists |
| `ErrInvalid` | the request breaks a rule | 422 | InvalidArgument |
| `ErrUnavailable` | a dependency is down; retrying may work | 503 | Unavailable |
| `*ViolationError` | `ErrInvalid` or `ErrConflict` plus the fields at fault | 422 / 409 + fields | + BadRequest details |

Build field-level errors with the constructors:

```go
domain.Invalid(domain.Violation{Field: "email", Rule: "email"})
domain.Conflict(domain.Violation{Field: "username", Rule: "taken"})
```

`ViolationError.Unwrap` returns its kind, so `errors.Is(err, domain.ErrConflict)` holds
through any amount of `%w` wrapping, and `go-tests`' `require.ErrorIs` works on it.

**Violation fields:**

- `Field` is the snake_case name of the field, which is also its JSON and proto name.
  Nested fields use dots: `items.0.sku`.
- `Rule` is a stable machine code: validator tag names (`required`, `email`, `min`) or
  your own (`taken`, `not_found`, `already_shipped`). Clients switch on it, so never
  rename one.
- `Param` is the rule's argument (`3` for `min=3`), used to build the message.

Messages are not stored in the domain. Each inbound adapter turns a `Rule` into words.

**Adding a sentinel** is justified only when a caller must react differently: a new
status code, a retry, a different message. "Something more specific went wrong" is
what wrapping is for.
