# Domain

`internal/domain` is the service's business language. Every other layer translates
into it and out of it. Templates: `assets/templates/domain/`.

| File | Holds |
|---|---|
| `domain.go` | models, and methods on them |
| `enums.go` | domain enums, string-based, each with `Valid()` |
| `errors.go` | the error values every layer returns |

Nothing else lives here. A struct that only carries data between layers for control
flow is not domain, even though it is a struct.

## domain.go: models

- **No struct tags.** `json`, `db`, `validate`: none. Serialisation belongs to the
  adapter that needs it, and two adapters rarely want the same shape (the response
  hides `Password`, the row keeps it).
- No imports outside the standard library.
- IDs are plain types (`int64`, `string`). How they are generated is an adapter
  concern, or a port (`IDGenerator`) when the application needs the ID before saving.

## Behaviour on models

**Logic that depends only on an entity's own data is a method on it.** Transitions
are the obvious case, but not the only one: derived values, eligibility, totals.

```go
func (o Order) CanCancel() bool {
	return o.Status == OrderStatusPending || o.Status == OrderStatusPaid
}

func (o Order) Total() int64 {
	var total int64
	for _, item := range o.Items {
		total += item.Price * int64(item.Quantity)
	}
	return total
}
```

- No I/O, no context, no ports. If deciding needs a database or another service, it
  is an application rule (`application.md`).
- Pass time in as a parameter; never call `time.Now()` in the domain, or the rule
  cannot be tested.
- Return a value or a bool; let the use case decide which error to return.

## enums.go: enums

**Always string-based. Never `iota`.** A string reads the same in the code, the
database, JSON and logs, and reordering the constants changes nothing. An `iota`
value is a bare number everywhere outside the code, and inserting a constant
renumbers every value after it, including the ones already stored.

```go
type OrderStatus string

const (
	OrderStatusPending OrderStatus = "pending"
	OrderStatusPaid    OrderStatus = "paid"
	OrderStatusShipped OrderStatus = "shipped"
)

func (s OrderStatus) Valid() bool {
	switch s {
	case OrderStatusPending, OrderStatusPaid, OrderStatusShipped:
		return true
	}
	return false
}
```

- **`Valid()` is the only list of allowed values.** The API's `enum` validator rule
  calls it (`validation.md`), so adding a constant here is all it takes to accept it.
- Constants are prefixed with the type name: `OrderStatusPaid`, not `Paid`.
- **Only domain enums.** A value that matters to one adapter only (a broker's
  delivery mode, a provider's status code) stays in that adapter's package as a
  plain string, with no custom type.
- **No enums in the database.** Store the string in a text column, with no database
  enum type and no check constraint. The API validates, and the domain owns the list.

`scripts/check` reports `iota`, non-string types in `enums.go`, and enums without
`Valid()`.

## errors.go: errors

Plain error values, nothing else: no error structs, no fields.

```go
var (
	ErrNotFound    = errors.New("not found")
	ErrConflict    = errors.New("conflict")
	ErrInvalid     = errors.New("invalid")
	ErrUnavailable = errors.New("unavailable")
	ErrInternal    = errors.New("internal")
)

var (
	ErrUsernameTaken       = fmt.Errorf("username taken: %w", ErrConflict)
	ErrCreditLimitExceeded = fmt.Errorf("credit limit exceeded: %w", ErrInvalid)
)
```

**Generic kinds** say how bad it is and what a client can do about it:

| Kind | Means |
|---|---|
| `ErrNotFound` | the thing asked for does not exist |
| `ErrConflict` | the request clashes with existing data |
| `ErrInvalid` | the request breaks a rule |
| `ErrUnavailable` | a dependency is down; retrying may work |
| `ErrInternal` | something unexpected; a bug or an unknown failure |

**Specific errors** say exactly what happened, and **always wrap a kind** with
`%w`. `errors.Is(err, ErrUsernameTaken)` and `errors.Is(err, ErrConflict)` are then
both true, so an adapter that has no row for a new specific error still answers
with the right kind instead of a 500.

Add a specific error when a caller must be told something precise: which field,
which rule. Name it for what happened (`ErrUsernameTaken`), not for where
(`ErrRepositoryDuplicate`).

Sentinel errors are the one accepted kind of package-level value: they are
constants in all but syntax, and `errors.Is` needs them.

How the errors travel and become responses is in `errors.md`.
