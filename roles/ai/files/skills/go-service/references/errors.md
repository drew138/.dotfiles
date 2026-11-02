# Errors

An error changes shape at every boundary, just like data does. The error values
themselves are in `domain.md`.

```mermaid
flowchart LR
    db["driver error<br/>unique · FK · no rows · connection"] -->|"repository: domainError"| dom["domain error<br/>ErrUsernameTaken · ErrInvalid · …"]
    up["provider reply<br/>404 · 503 · timeout"] -->|"provider adapter"| dom
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

## Outbound: caches and providers

A cache never fails a request (`cache.md`). A provider adapter translates provider
replies the same way a repository translates drivers (`providers.md`).

## Application

Three moves:

1. **Wrap and pass through.** `fmt.Errorf("saving user: %w", err)`. The default.
2. **Re-translate when the use case knows better.** The customer repository says
   `ErrNotFound`, but for `PlaceOrder` that means the order references a customer
   that does not exist: return `domain.ErrCustomerNotFound`, which wraps
   `ErrInvalid` (422 on `customer_id`), not a 404.
3. **Return broken business rules** from `validate<Method>`, joined.

## Inbound: REST

### The error body

Every error response has the same body:

```json
{
  "type": "invalid_argument",
  "title": "The request is invalid.",
  "status": 422,
  "errors": [
    {"code": "max", "field": "username", "param": "32"},
    {"code": "reserved", "field": "username"},
    {"code": "signups_closed"}
  ]
}
```

| Member | Holds | Present |
|---|---|---|
| `type` | the kind of failure, a stable word clients switch on: `invalid_argument`, `not_found`, `conflict`, … | always |
| `title` | the fixed human summary for that type | always |
| `status` | the HTTP status, repeated so the body stands alone in logs and queues | always |
| `errors` | each individual failure: a `code`, plus `field` when it is about one field and `param` when the rule has a value | only when there is something to list |

Field and non-field failures share the list: a failure about one field carries
`field`, one about the request as a whole (signups closed, credit limit exceeded)
carries only `code`. Several failures from `errors.Join` all appear, in the order of
the adapter's table.

A 404 is just:

```json
{"type": "not_found", "title": "The resource does not exist.", "status": 404}
```

The content type is `application/json`.

### Choosing it

`mapErrorResponse(err)` in `rest/mappers.go` builds the body, status included; it is
the only place a status is chosen. It checks, in this order:

1. **The request itself**, errors that never reached the application:

   | Error | Status | `type` | `errors` |
   |---|---|---|---|
   | body over 1 MiB (`*http.MaxBytesError`) | 413 | `body_too_large` | none |
   | invalid JSON (`errMalformedBody`) | 400 | `malformed_request` | none |
   | wrong JSON type (`*json.UnmarshalTypeError`) | 422 | `invalid_argument` | `{code: type, field, param: integer}` |
   | validator failure (`validator.ValidationErrors`) | 422 | `invalid_argument` | one per failed rule |

2. **Specific domain errors**, from the adapter's table. Every row whose error
   matches with `errors.Is` adds an entry, so joined errors all appear:

   ```go
   var domainErrors = []struct {
   	err    error
   	status int
   	code   string
   	field  string
   }{
   	{domain.ErrUsernameTaken, http.StatusConflict, "taken", "username"},
   	{domain.ErrCreditLimitExceeded, http.StatusUnprocessableEntity, "over_credit_limit", "total"},
   	{domain.ErrSignupsClosed, http.StatusUnprocessableEntity, "signups_closed", ""},
   }
   ```

   Field names live here, in the adapter, because only the adapter knows the names
   its clients use. A failure about the request as a whole has an empty `field`.

3. **Generic kinds**, which give the `type` and `title`, and the status when no row
   matched:

   | Kind | Status | `type` |
   |---|---|---|
   | `ErrNotFound` | 404 | `not_found` |
   | `ErrConflict` | 409 | `conflict` |
   | `ErrInvalid` | 422 | `invalid_argument` |
   | `ErrUnavailable`, `context.DeadlineExceeded` | 503 | `unavailable` |
   | `ErrInternal`, anything else | 500 | `internal` |

**Entries from the validator** carry the JSON field name, the rule as `code` (the
tag: `required`, `max`, `email`, `enum`) and `param` only for value rules (`max` →
`32`). Rules that compare fields (`eqfield`, `required_if`) would expose a Go field
name as their parameter, so they are sent without one.

The code is in `rest.md`.

## Inbound: gRPC and queues

gRPC maps the same kinds to status codes (`grpc.md`). A queue consumer maps them to
ack, dead-letter or requeue (`queue.md`).

## Testing

Assert with `require.ErrorIs(t, err, domain.ErrUsernameTaken)` per `go-tests`.
Never assert on message text.
