# Application

`internal/application` holds the use cases. A use case **orchestrates**: it decides
what happens, in what order, and through which ports. It never knows how a port is
implemented.

## application.go

Holds three things and nothing else:

1. the `Application` struct, whose fields are ports
2. `New`, taking every port as a parameter
3. the ports: the interfaces the use cases consume

```go
type Repository interface {
	Save(ctx context.Context, user domain.User) (domain.User, error)
	Find(ctx context.Context, id int64) (domain.User, error)
}

type Mailer interface {
	SendWelcome(ctx context.Context, user domain.User) error
}

type Application struct {
	repo   Repository
	mailer Mailer
	log    *slog.Logger
}

func New(repo Repository, mailer Mailer, log *slog.Logger) *Application {
	return &Application{repo: repo, mailer: mailer, log: log}
}
```

**Ports**

- One interface per kind of dependency, named for what it does: `Repository`,
  `Mailer`, `Catalog`, `Publisher`, `Clock`.
- Methods speak domain types. No `*sql.Tx`, `*http.Response` or proto message ever
  appears in a port. If one would have to, the port is drawn at the wrong place.
- `ctx context.Context` first, always.
- When `Repository` grows past one entity, split it by entity: `Users`, `Orders`.
- Declare only the methods a use case calls. An adapter may do more; the port does
  not need to know.

## Method files

One public method per file, named in snake_case: `PlaceOrder` lives in
`place_order.go`. The file also holds that method's private helpers, and only that
method's.

**Never share a private helper between method files.** Duplicate it, under a name
specific to each method.

### Why: the shared helper that breaks a use case nobody touched

It starts reasonably. Both use cases clean the email the same way, so the helper
lives in one file and the other calls it:

```go
// create_user.go
func (a *Application) CreateUser(ctx context.Context, user domain.User) (domain.User, error) {
	user.Email = normalizeEmail(user.Email)
	…
}

func normalizeEmail(email string) string {
	return strings.ToLower(strings.TrimSpace(email))
}
```

```go
// update_user.go
func (a *Application) UpdateUser(ctx context.Context, user domain.User) (domain.User, error) {
	user.Email = normalizeEmail(user.Email) // declared in create_user.go
	…
}
```

Months later, signup needs to block duplicate accounts made with aliases:
`ana+1@x.com` and `ana+2@x.com` both reach `ana@x.com`. The change is about
creating users, so it is made in `create_user.go`:

```go
func normalizeEmail(email string) string {
	email = strings.ToLower(strings.TrimSpace(email))
	local, domainPart, _ := strings.Cut(email, "@")
	local, _, _ = strings.Cut(local, "+")
	return local + "@" + domainPart
}
```

The pull request touches only `create_user.go`, and the reviewer checks signup.
But `UpdateUser` now rewrites every address a user saves: someone who deliberately
sets `ana+work@x.com` to filter their mail gets `ana@x.com`, and their filters stop
working. `update_user.go` did not change, so nothing pointed anyone at it.

With one helper per method file, each use case keeps its own rule:

```go
// create_user.go
func normalizeCreateUserEmail(email string) string {
	email = strings.ToLower(strings.TrimSpace(email))
	local, domainPart, _ := strings.Cut(email, "@")
	local, _, _ = strings.Cut(local, "+")
	return local + "@" + domainPart
}
```

```go
// update_user.go
func normalizeUpdateUserEmail(email string) string {
	return strings.ToLower(strings.TrimSpace(email))
}
```

The signup change is now visibly signup-only, and `UpdateUser` behaves exactly as it
did. The cost is a few duplicated lines. In return, each use case can be read,
changed and reviewed from its own file.

The rule is about **private helpers in the application layer**, where each method
is a separate business decision. Shared behaviour that genuinely belongs to the
business (an email is valid when…) is a domain method or a domain function, used on
purpose by both use cases. Adapters may share helpers within their own package
(`domainError`, `writeJSON`), because they translate, not decide.

## Anatomy of a use case

Most use cases follow the same order. Skip what does not apply, but keep the order.
The request's format was already validated by the inbound adapter, so the use case
starts from well-formed domain values.

```go
func (a *Application) PlaceOrder(ctx context.Context, order domain.Order) (domain.Order, error) {
	// 1. Load what the decision needs, through ports.
	customer, err := a.customers.Find(ctx, order.CustomerID)
	if errors.Is(err, domain.ErrNotFound) {
		return domain.Order{}, domain.ErrCustomerNotFound
	}
	if err != nil {
		return domain.Order{}, fmt.Errorf("finding customer %d: %w", order.CustomerID, err)
	}

	// 2. Check the stateful business rules, all at once.
	if err := validatePlaceOrder(order, customer); err != nil {
		return domain.Order{}, err
	}

	// 3. Decide, using domain methods.
	order.Status = domain.OrderStatusPending

	// 4. Persist: one port call per atomic change.
	saved, err := a.orders.Save(ctx, order)
	if err != nil {
		return domain.Order{}, fmt.Errorf("saving order: %w", err)
	}

	// 5. Side effects after the state is safe.
	a.notifyPlaceOrder(ctx, saved)
	return saved, nil
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

(The comments are here for the explanation only. Real method files carry none.)

**Why this order**

- Loads first, so rules are checked against real state, not the request's claims.
- Rules before any change, and all of them at once, so a rejected request costs
  nothing and the client fixes everything in one round trip. How
  `validate<Method>` works is in `validation.md`.
- Persist before side effects. An email sent for an order that then failed to save is
  a lie that cannot be taken back. A saved order whose email failed can be retried.

## Errors in a use case

Three moves, in this order of preference:

1. **Wrap and pass through.** `fmt.Errorf("saving order: %w", err)`. The kind and
   any specific error survive the wrap, so the inbound adapter still maps them.
   This is the default.
2. **Re-translate when the use case knows more than the port.** The customer
   repository says `ErrNotFound`, but to the client of `PlaceOrder` the order
   references a customer that does not exist. That is `domain.ErrCustomerNotFound`
   (which wraps `ErrInvalid`: a 422 on `customer_id`), not a 404. Only the use case
   knows that.
3. **Swallow deliberately**, for best-effort work, in a helper private to the method
   file:

```go
func (a *Application) notifyPlaceOrder(ctx context.Context, order domain.Order) {
	if err := a.mailer.SendOrderPlaced(ctx, order); err != nil {
		a.log.WarnContext(ctx, "sending order placed email", "order_id", order.ID, "error", err)
	}
}
```

A swallowed error must still be logged, because that is where it stops. How the
application gets its logger is part of the logging design, which is not settled yet.

Never log and return the same error. Never return a raw adapter error; ports return
domain errors, so the application never imports a driver.

## Atomic changes across ports

Prefer one port method that does the whole atomic change:
`orders.SaveWithReservation(ctx, order)`. The repository opens and commits the
transaction, and the application stays transaction-free.

When the change genuinely spans two ports, add a `Transactor` port:

```go
type Transactor interface {
	InTx(ctx context.Context, fn func(ctx context.Context) error) error
}
```

```go
err := a.tx.InTx(ctx, func(ctx context.Context) error {
	if err := a.stock.Reserve(ctx, order.Items); err != nil {
		return fmt.Errorf("reserving stock: %w", err)
	}
	_, err := a.orders.Save(ctx, order)
	return err
})
```

The adapter puts the `*sql.Tx` into the context it passes to `fn`, and its repository
methods use it when present. The application still sees only `context.Context`.

Never call a remote service inside a database transaction. The transaction holds
locks for as long as the network takes.

## Concurrent loads

Independent loads may run concurrently with `golang.org/x/sync/errgroup`:

```go
g, gctx := errgroup.WithContext(ctx)
g.Go(func() (err error) { customer, err = a.customers.Find(gctx, id); return err })
g.Go(func() (err error) { prices, err = a.catalog.Prices(gctx, skus); return err })
if err := g.Wait(); err != nil {
	return domain.Order{}, fmt.Errorf("loading order inputs: %w", err)
}
```

Only for loads that do not depend on each other, and only when latency matters.
Sequential code is easier to read.

## Done when

- `application.go` holds only `Application`, `New` and ports.
- The new method is alone in its snake_case file, with its own helpers.
- Stateful rules are in `validate<Method>`, pure and joined.
- Every port error is wrapped, re-translated or deliberately swallowed and logged.
