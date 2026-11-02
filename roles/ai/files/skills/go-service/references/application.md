# Application

`internal/application` holds the use cases. A use case **orchestrates**: it decides
what happens, in what order, and through which ports. It never knows how a port is
implemented. Templates: `assets/templates/base/internal/application/`.

## application.go

Holds three things and nothing else:

1. the `Service` struct, whose fields are ports
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

type Service struct {
	repo   Repository
	mailer Mailer
	log    *slog.Logger
}

func New(repo Repository, mailer Mailer, log *slog.Logger) *Service {
	return &Service{repo: repo, mailer: mailer, log: log}
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

**Never share a private helper between method files.** If `CreateUser` and
`UpdateUser` both normalise an email, each file gets its own:
`normalizeCreateUserEmail` and `normalizeUpdateUserEmail`. A shared helper couples two
use cases: a change made for one silently changes the other, and nothing in either
file says so. Duplication is the price of being able to change a use case by reading
one file. `scripts/check` reports shared helpers.

## Anatomy of a use case

Most use cases follow the same order. Skip what does not apply, but keep the order.

```go
func (s *Service) PlaceOrder(ctx context.Context, order domain.Order) (domain.Order, error) {
	// 1. Business rules that need no I/O, cheapest first.
	if len(order.Items) == 0 {
		return domain.Order{}, domain.Invalid(domain.Violation{Field: "items", Rule: "required"})
	}

	// 2. Load what the decision needs, through ports.
	customer, err := s.customers.Find(ctx, order.CustomerID)
	if errors.Is(err, domain.ErrNotFound) {
		return domain.Order{}, domain.Invalid(domain.Violation{Field: "customer_id", Rule: "not_found"})
	}
	if err != nil {
		return domain.Order{}, fmt.Errorf("finding customer %d: %w", order.CustomerID, err)
	}

	// 3. Decide, using domain methods.
	order, err = order.PriceFor(customer)
	if err != nil {
		return domain.Order{}, err
	}

	// 4. Persist: one port call per atomic change.
	saved, err := s.orders.Save(ctx, order)
	if err != nil {
		return domain.Order{}, fmt.Errorf("saving order: %w", err)
	}

	// 5. Side effects after the state is safe.
	s.notifyPlaceOrder(ctx, saved)
	return saved, nil
}
```

(The comments are here for the explanation only. Real method files carry none.)

**Why this order**

- Rules first, because they are free and a request that fails them should cost nothing.
- Loads before decisions, so the decision is made on real state, not on the request's
  claims.
- Persist before side effects. An email sent for an order that then failed to save is
  a lie that cannot be taken back. A saved order whose email failed can be retried.

## Errors in a use case

Three moves, in this order of preference:

1. **Pass through with context.** `fmt.Errorf("saving order: %w", err)`. The kind
   survives the wrap, so the inbound adapter still maps it. This is the default.
2. **Re-translate when the use case knows more than the port.** The customer
   repository says `ErrNotFound`, but to the client of `PlaceOrder` the order is
   fine and the `customer_id` field is wrong. That is a 422 on a field, not a 404.
   Only the use case knows that.
3. **Swallow deliberately**, for best-effort work, and log it, because a handled error
   is logged where it stops (see `go-review`):

```go
func (s *Service) notifyPlaceOrder(ctx context.Context, order domain.Order) {
	if err := s.mailer.SendOrderPlaced(ctx, order); err != nil {
		s.log.WarnContext(ctx, "sending order placed email", "order_id", order.ID, "error", err)
	}
}
```

Never log and return the same error. Never return a raw adapter error type; ports
return domain errors, so the application never imports a driver.

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
err := s.tx.InTx(ctx, func(ctx context.Context) error {
	if err := s.stock.Reserve(ctx, order.Items); err != nil {
		return fmt.Errorf("reserving stock: %w", err)
	}
	_, err := s.orders.Save(ctx, order)
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
g.Go(func() (err error) { customer, err = s.customers.Find(gctx, id); return err })
g.Go(func() (err error) { prices, err = s.catalog.Prices(gctx, skus); return err })
if err := g.Wait(); err != nil {
	return domain.Order{}, fmt.Errorf("loading order inputs: %w", err)
}
```

Only for loads that do not depend on each other, and only when latency matters.
Sequential code is easier to read.

## Done when

- `application.go` holds only `Service`, `New` and ports.
- The new method is alone in its snake_case file, with its own helpers.
- Every port error is wrapped, re-translated or deliberately swallowed and logged.
- `go -C <skill>/scripts run ./check "$PWD"` reports nothing for the application.
