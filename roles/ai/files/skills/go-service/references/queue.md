# Queue adapters

A queue touches a service from both sides, so it is two adapters:

| Side | Direction | Folder | Implements / calls |
|---|---|---|---|
| **Publisher** | outbound | `internal/infrastructure/publisher/<broker>/` | implements a `Publisher` port |
| **Consumer** | inbound | `internal/infrastructure/queue/<broker>/` | calls use cases through its own `Application` interface, like a REST handler |

A consumer is an inbound adapter for the same reason a handler is: a message arrives
from outside and asks the service to do something. It follows the same
`<kind>/<tech>` rule as every adapter: the kind is `queue`, the tech is the broker.

The code below uses RabbitMQ (`github.com/rabbitmq/amqp091-go`). For Kafka, SQS or NATS
the files, ports and error handling are the same; only the client calls change. Ask
which broker the service uses before writing either side.

## Publisher

The port, in `application.go`, speaks domain events, not broker terms:

```go
type Publisher interface {
	UserCreated(ctx context.Context, user domain.User) error
}
```

One method per event. No `Publish(topic string, payload []byte)`: that makes the
application choose routing keys and encodings, which are adapter concerns.

`publisher/rabbitmq/rabbitmq.go`:

```go
type Publisher struct {
	ch       *amqp.Channel
	exchange string
}

func New(ch *amqp.Channel, exchange string) *Publisher {
	return &Publisher{ch: ch, exchange: exchange}
}

func (p *Publisher) UserCreated(ctx context.Context, user domain.User) error {
	body, err := json.Marshal(mapUserCreatedMessage(user))
	if err != nil {
		return fmt.Errorf("encoding user created %d: %w", user.ID, err)
	}

	err = p.ch.PublishWithContext(ctx, p.exchange, "user.created", true, false, amqp.Publishing{
		ContentType:  "application/json",
		DeliveryMode: amqp.Persistent,
		MessageId:    "user.created:" + strconv.FormatInt(user.ID, 10),
		Body:         body,
	})
	if err != nil {
		return fmt.Errorf("publishing user created %d: %w: %w", user.ID, domain.ErrUnavailable, err)
	}
	return nil
}
```

`dto.go` holds `userCreatedMessage` with `json` tags, and `mappers.go` holds
`mapUserCreatedMessage`. Same rules as a response DTO: **no secrets in a message**.
Every consumer of the topic would receive them.

- `MessageId` is deterministic (`<event>:<id>`), so consumers can deduplicate.
- `DeliveryMode: Persistent` and `mandatory: true`, so a message is neither lost on a
  broker restart nor silently dropped when nothing is bound to the routing key.
- Broker errors become `ErrUnavailable`: the publish may succeed on retry.

### Publishing from a use case

Publish **after** the state change is saved (`application.md`, *Anatomy of a use case*).
Then decide what a failed publish means:

| Need | Approach |
|---|---|
| Losing an event now and then is acceptable (notifications, cache warming) | best-effort: log and continue, in a helper private to the method file |
| Every saved change must produce its event | **outbox**: see below |

Never publish first and save second. Consumers would act on a change that may then
fail to save.

### Outbox

The repository writes the event into an `outbox` table **in the same transaction** as
the change. A separate relay reads unsent rows, publishes them, and marks them sent.

- The use case calls one port method, `users.SaveWithEvent(ctx, user, event)`, and
  never touches the publisher.
- The relay is its own small inbound loop, started from `main.go` beside the servers,
  using the `Publisher` adapter.
- Delivery becomes at-least-once, so consumers must be idempotent. They should be
  anyway.

## Consumer

`queue/rabbitmq/` has the same files as `api/rest/`:

| File | Holds |
|---|---|
| `rabbitmq.go` | `Application` interface, `Consumer`, `New`, `Run`, `handle`, one method per message type, validator setup |
| `dto.go` | message structs with `json` and `validate` tags and `toDomain()` |

Incoming messages are validated exactly like REST requests: tags on the message DTO,
the same validator setup (`validation.md`).

```go
type Application interface {
	CreateUser(ctx context.Context, user domain.User) (domain.User, error)
}

type Consumer struct {
	ch       *amqp.Channel
	queue    string
	app      Application
	validate *validator.Validate
	log      *slog.Logger
}

func New(ch *amqp.Channel, queue string, app Application, log *slog.Logger) *Consumer {
	return &Consumer{ch: ch, queue: queue, app: app, validate: newValidator(), log: log}
}

func (c *Consumer) Run(ctx context.Context) error {
	deliveries, err := c.ch.ConsumeWithContext(ctx, c.queue, "", false, false, false, false, nil)
	if err != nil {
		return fmt.Errorf("consuming %s: %w", c.queue, err)
	}
	for {
		select {
		case <-ctx.Done():
			return nil
		case d, ok := <-deliveries:
			if !ok {
				return fmt.Errorf("consuming %s: delivery channel closed", c.queue)
			}
			c.handle(ctx, d)
		}
	}
}
```

Each message type gets a method shaped like a REST route: decode, validate, call the
use case.

```go
type ImportUserMessage struct {
	Username string `json:"username" validate:"required,max=32"`
	Email    string `json:"email" validate:"required,email,max=254"`
}
```

```go
func (c *Consumer) importUser(ctx context.Context, body []byte) error {
	var msg ImportUserMessage
	if err := json.Unmarshal(body, &msg); err != nil {
		return fmt.Errorf("%w: %w", errMalformedMessage, err)
	}
	if err := c.validate.Struct(msg); err != nil {
		return fmt.Errorf("%w: %w", errMalformedMessage, err)
	}
	_, err := c.app.CreateUser(ctx, msg.toDomain())
	return err
}
```

A message that fails decoding or validation is malformed: no retry will fix it.

### Errors become acknowledgements

A consumer has no client to answer, so a domain error decides the message's fate
instead of a status code. `handle` is the consumer's `mapErrorResponse`:

```go
func (c *Consumer) handle(ctx context.Context, d amqp.Delivery) {
	err := c.importUser(ctx, d.Body)
	switch {
	case err == nil, errors.Is(err, domain.ErrConflict):
		c.settle(ctx, d, d.Ack(false))
	case errors.Is(err, errMalformedMessage), errors.Is(err, domain.ErrInvalid):
		c.log.WarnContext(ctx, "dead-lettering message", "queue", c.queue, "message_id", d.MessageId, "error", err)
		c.settle(ctx, d, d.Nack(false, false))
	default:
		c.log.ErrorContext(ctx, "handling message", "queue", c.queue, "message_id", d.MessageId, "error", err)
		c.settle(ctx, d, d.Nack(false, true))
	}
}
```

| Error | Fate | Why |
|---|---|---|
| none | ack | done |
| `ErrConflict`, including specific ones such as `ErrUsernameTaken` | ack | already applied: a redelivery of something that succeeded. This is what makes the consumer idempotent |
| malformed or failed validation, `ErrInvalid` | nack without requeue → dead-letter queue | will never succeed; retrying blocks the queue |
| `ErrNotFound` | depends: dead-letter if the message is wrong, requeue if the referenced data may still arrive | decide per message type, write it in the switch |
| `ErrUnavailable`, anything else | nack with requeue | may succeed later |

Requeueing forever turns one poison message into a hot loop. Give the queue a
delivery limit and a dead-letter exchange (quorum queues: `x-delivery-limit`,
`x-dead-letter-exchange`), so a message that keeps failing ends up in the DLQ.

The consumer is where the error stops, so it is where the error is logged, once. An
ack or nack that fails is logged too, since the broker will redeliver. How the
logger is passed in is part of the logging design, which is not settled yet.

### Idempotency

Delivery is at-least-once with every broker. A consumer must survive the same message
twice:

- Let a unique constraint reject the duplicate and treat `ErrConflict` as success, as
  above.
- When the use case has no natural unique key, store processed `MessageId`s in a
  table and check them in the use case, through a port.

## Wiring

```go
conn, err := amqp.Dial(cfg.AMQPURL)
if err != nil {
	return fmt.Errorf("connecting to rabbitmq: %w", err)
}
defer conn.Close()

pubCh, err := conn.Channel()
…
consumeCh, err := conn.Channel()
…
if err := consumeCh.Qos(10, 0, false); err != nil { … }

app := application.New(repo, publisher.New(pubCh, cfg.Exchange))
importer := consumer.New(consumeCh, cfg.ImportQueue, app, log)
go func() { errCh <- importer.Run(ctx) }()
```

- **One channel per direction.** A channel is not safe for concurrent publishing, and a
  slow consumer must not stall publishes.
- `Qos` sets the prefetch: how many unacked messages the consumer holds at once.
- Both broker packages are named `rabbitmq`. Import them as `publisher` and
  `consumer` in `main.go`.
- `Run` returns when `ctx` is cancelled, so shutdown is the same signal context as the
  servers.
- Exchange, queue and binding definitions live at the repository root in
  `rabbitmq/` (for example `rabbitmq/definitions.json`), applied by the deploy, not
  declared at service startup.
- `AMQP_URL`, the exchange and queue names come from config.
