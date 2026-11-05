# Provider adapters (services we call)

An outbound adapter for another service the application depends on: a payment
provider, an identity provider, another team's API. It is **our abstraction of that
service: the calls we make to it.** It receives an `*http.Client` (or a gRPC
connection) and the endpoints it needs; how the requests travel is its own detail.

## Where it lives

The same `<kind>/<tech>` rule as every adapter. The **kind** is the capability the
service gives us; the **tech** is the provider that delivers it:

```
internal/infrastructure/psp/adyen/        payments through Adyen
internal/infrastructure/psp/stripe/       payments through Stripe
internal/infrastructure/auth/cognito/     authentication through Cognito
```

The kind says what the service does for us. Two providers of the same kind
implement the same port, and `main.go` picks one; the application stays the same.

## Naming

The kind names the port and the struct, as with `repository` → `Repository`:

| | Example |
|---|---|
| port in `application.go` | `type PSP interface { Charge(ctx context.Context, payment domain.Payment) (domain.Payment, error) }` |
| struct | `adyen.PSP`, `stripe.PSP` |
| constructor | `adyen.New(httpClient, cfg.adyenURL, cfg.adyenAPIKey)` |
| auth example | port `Auth`, struct `cognito.Auth` |

The port speaks domain types only. The provider's request and response shapes,
field names, status codes and error bodies never leave the adapter.

## Files

| File | Holds |
|---|---|
| `<tech>.go` | the struct, `New`, error translation and the helpers the methods share |
| `<method>.go` | one port method per file, in snake_case: `Charge` lives in `charge.go` |
| `<method>_dto.go` | that method's request and response bodies, with the provider's `json` tags; responses have `toDomain()` |
| `dto.go` | bodies several methods share |
| `mappers.go` | `map<Target>` functions building the provider's requests from domain values |

## Shape

`psp/adyen/adyen.go`:

```go
type PSP struct {
	http    *http.Client
	baseURL string
	apiKey  string
}

func New(httpClient *http.Client, baseURL, apiKey string) *PSP {
	return &PSP{http: httpClient, baseURL: baseURL, apiKey: apiKey}
}
```

`psp/adyen/charge.go`:

```go
func (p *PSP) Charge(ctx context.Context, payment domain.Payment) (domain.Payment, error) {
	body, err := json.Marshal(mapChargeRequest(payment))
	if err != nil {
		return domain.Payment{}, fmt.Errorf("encoding charge %d: %w: %w", payment.ID, domain.ErrInternal, err)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, p.baseURL+"/payments", bytes.NewReader(body))
	if err != nil {
		return domain.Payment{}, fmt.Errorf("building charge %d: %w: %w", payment.ID, domain.ErrInternal, err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-API-Key", p.apiKey)

	resp, err := p.http.Do(req)
	if err != nil {
		return domain.Payment{}, fmt.Errorf("charging payment %d: %w: %w", payment.ID, domain.ErrUnavailable, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return domain.Payment{}, fmt.Errorf("charging payment %d: %w", payment.ID, statusError(resp.StatusCode))
	}
	var charged chargeResponse
	if err := json.NewDecoder(resp.Body).Decode(&charged); err != nil {
		return domain.Payment{}, fmt.Errorf("decoding charge %d: %w: %w", payment.ID, domain.ErrInternal, err)
	}
	return charged.toDomain(payment), nil
}
```

`psp/adyen/dto.go`:

```go
type chargeRequest struct {
	Amount    int64  `json:"amount"`
	Currency  string `json:"currency"`
	Reference string `json:"reference"`
}

type chargeResponse struct {
	PSPReference string `json:"pspReference"`
	ResultCode   string `json:"resultCode"`
}

func (r chargeResponse) toDomain(payment domain.Payment) domain.Payment {
	payment.ProviderReference = r.PSPReference
	payment.Status = domain.PaymentStatusCharged
	return payment
}
```

`psp/adyen/mappers.go`:

```go
func mapChargeRequest(payment domain.Payment) chargeRequest {
	return chargeRequest{Amount: payment.Amount, Currency: payment.Currency, Reference: strconv.FormatInt(payment.ID, 10)}
}
```

## Error translation

Every error that leaves the adapter is a domain error (`errors.md`):

```go
func statusError(status int) error {
	switch {
	case status == http.StatusNotFound:
		return domain.ErrNotFound
	case status == http.StatusConflict:
		return domain.ErrConflict
	case status == http.StatusTooManyRequests, status >= 500:
		return domain.ErrUnavailable
	default:
		return fmt.Errorf("unexpected status %d: %w", status, domain.ErrInternal)
	}
}
```

| Provider says | Domain error |
|---|---|
| 404, when "not there" means the same to our caller | `ErrNotFound` |
| 409 | `ErrConflict` |
| 429, 5xx, timeouts, refused connections | `ErrUnavailable` |
| other 4xx | `ErrInternal`: we sent something wrong, which is our bug |
| a failure our caller must hear about precisely (card declined, user disabled) | a specific domain error wrapping a kind (`domain.ErrCardDeclined` wraps `ErrInvalid`), read from the provider's response |

The provider's error body never reaches our client. Its codes and messages belong to
someone else's API, and they would also tell a caller which provider we use.

## Behaviour

- The `*http.Client` comes from `main.go`, built there with whatever timeout the
  user sets. Several provider adapters can share one.
- Endpoints, keys and credentials come from config. Never log them, and never log a
  request or response body: provider payloads are full of PII and PCI data.
- Retry only idempotent calls, only on `ErrUnavailable`, with backoff, inside the
  adapter. The application does not retry.
- Log nothing else here; the error is logged where it stops.
