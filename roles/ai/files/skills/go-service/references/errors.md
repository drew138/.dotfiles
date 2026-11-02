# Errors

An error changes shape at every boundary, just like data does. The error values
themselves are in `domain.md`.

```mermaid
flowchart LR
    db["driver error<br/>unique · FK · no rows · connection"] -->|"repository: domainError"| dom["domain error<br/>ErrUsernameTaken · ErrInvalid · …"]
    up["upstream reply<br/>404 · 503 · timeout"] -->|"client adapter"| dom
    rules["broken business rule"] -->|"application: validate&lt;Method&gt;"| dom
    dom -->|"application: wrap %w"| wrapped["wrapped domain error"]
    wrapped -->|"inbound: mapErrorResponse"| out["status + error body"]
    val["validator / JSON errors"] -->|"inbound: mapErrorResponse"| out
```

## Rules

1. **Every error that leaves an outbound adapter is a domain error.** A known
   failure becomes its specific error, an unknown one its generic kind. The
   original error is wrapped inside for the logs, but nothing above the adapter
   needs to know which driver produced it.
2. **Wrap with what you were doing**, using `%w`:
   `fmt.Errorf("saving order %d: %w", id, err)`. To translate and keep the cause,
   wrap both: `fmt.Errorf("%s: %w: %w", doing, domain.ErrUnavailable, err)`.
3. **No PII or PCI in an error, ever.** Errors get logged, so a wrap that names an
   email, a name or a card number leaks it. Identify things by ID. Check what a
   driver puts in its own message too: MySQL's duplicate-key message contains the
   duplicated value.
4. **Never show `err.Error()` to a client.** The response is built from fixed codes
   and messages in the inbound adapter.
5. **A cancelled request is not an error.** `context.Canceled` means the client went
   away: write nothing. `context.DeadlineExceeded` is treated as unavailable.

## Outbound: the repository

Every query's error goes through one `domainError(err, doing)` function.

```go
var constraintErrors = map[string]error{
	"users_username_key": domain.ErrUsernameTaken,
	"users_email_key":    domain.ErrEmailTaken,
}
```

| Store says | Domain error |
|---|---|
| no rows | `ErrNotFound` |
| a constraint in `constraintErrors` | its specific error |
| any other unique violation | `ErrConflict` |
| any other integrity or data error (foreign key, not null, value too long) | `ErrInvalid` |
| connection refused, reset, timeout, server shutting down | `ErrUnavailable` |
| anything else | `ErrInternal` |

A missing foreign key is `ErrInvalid`, not `ErrNotFound`: the client referenced
something that does not exist, which is a problem with their request. `ErrNotFound`
would tell them the resource they asked for is missing.

The store-specific checks are in `repository.md`.

## Outbound: caches and other services

A cache never fails a request (`cache.md`). A client adapter translates upstream
replies the same way a repository translates drivers (`clients.md`).

## Application

Three moves:

1. **Wrap and pass through.** `fmt.Errorf("saving user: %w", err)`. The default.
2. **Re-translate when the use case knows better.** The customer repository says
   `ErrNotFound`, but for `PlaceOrder` that means the order references a customer
   that does not exist: return `domain.ErrCustomerNotFound`, which wraps
   `ErrInvalid` (422 on `customer_id`), not a 404.
3. **Return broken business rules** from `validate<Method>`, joined.

## Inbound: REST

`mapErrorResponse(err)` in `rest/mappers.go` is the only place a status is chosen.
It checks, in this order:

1. **The request itself**, errors that never reached the application:

   | Error | Status | `code` |
   |---|---|---|
   | body over 1 MiB (`*http.MaxBytesError`) | 413 | `body_too_large` |
   | wrong JSON type (`*json.UnmarshalTypeError`) | 422 | `invalid_argument` + the field, expected type |
   | invalid JSON (`errMalformedBody`) | 400 | `malformed_request` |
   | validator failure (`validator.ValidationErrors`) | 422 | `invalid_argument` + every field |

2. **Specific domain errors**, from the adapter's table. Every row whose error
   matches with `errors.Is` adds its field, so joined errors all appear:

   ```go
   var domainErrors = []struct {
   	err    error
   	status int
   	field  string
   	rule   string
   }{
   	{domain.ErrUsernameTaken, http.StatusConflict, "username", "taken"},
   	{domain.ErrCreditLimitExceeded, http.StatusUnprocessableEntity, "total", "over_credit_limit"},
   	{domain.ErrSignupsClosed, http.StatusUnprocessableEntity, "", "signups_closed"},
   }
   ```

   Field names live here, in the adapter, because only the adapter knows the names
   its clients use. A rule that is not about one field leaves `field` empty.

3. **Generic kinds**, which choose the status when no row matched:

   | Kind | Status | `code` |
   |---|---|---|
   | `ErrNotFound` | 404 | `not_found` |
   | `ErrConflict` | 409 | `conflict` |
   | `ErrInvalid` | 422 | `invalid_argument` |
   | `ErrUnavailable`, `context.DeadlineExceeded` | 503 | `unavailable` |
   | `ErrInternal`, anything else | 500 | `internal` |

**Fields from the validator** carry the JSON name, the rule (the tag: `required`,
`max`, `email`, `enum`) and the parameter only for value rules (`max` → `32`).
Rules that compare fields (`eqfield`, `required_if`) would expose a Go field name as
their parameter, so they are sent without one.

The current error body:

```json
{
  "error": {
    "code": "invalid_argument",
    "message": "The request has invalid fields.",
    "fields": [
      {"field": "username", "rule": "max", "param": "32"},
      {"field": "username", "rule": "taken"},
      {"rule": "signups_closed"}
    ]
  }
}
```

**Not settled yet:** the body's exact shape (including whether to adopt RFC 9457
Problem Details), 422 versus 400 for invalid fields, whether rule codes should be
our own words instead of validator tag names, and how 5xx errors are logged. Keep
the current behaviour until those are decided.

## Inbound: gRPC and queues

gRPC maps the same kinds to status codes (`grpc.md`). A queue consumer maps them to
ack, dead-letter or requeue (`queue.md`).

## Testing

Assert with `require.ErrorIs(t, err, domain.ErrUsernameTaken)` per `go-tests`.
Never assert on message text.
