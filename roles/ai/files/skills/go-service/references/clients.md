# Client adapters (other services)

An outbound adapter that calls another service over HTTP or gRPC and implements a
port such as `Catalog` or `Payments`. Lives in `internal/infrastructure/client/<name>/`,
with the same three files as every adapter.

| File | Holds |
|---|---|
| `<name>.go` | `Client`, `New(httpClient, baseURL)`, one method per port method, `domainError` |
| `dto.go` | the upstream's request and response structs with `json` tags, `toDomain()` |
| `mappers.go` | `map<UpstreamRequest>(domain…)` |

```go
type Client struct {
	http    *http.Client
	baseURL string
}

func New(httpClient *http.Client, baseURL string) *Client {
	return &Client{http: httpClient, baseURL: baseURL}
}

func (c *Client) Product(ctx context.Context, sku string) (domain.Product, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, c.baseURL+"/products/"+url.PathEscape(sku), nil)
	if err != nil {
		return domain.Product{}, fmt.Errorf("building product request: %w", err)
	}
	resp, err := c.http.Do(req)
	if err != nil {
		return domain.Product{}, domainError(err, "fetching product "+sku)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return domain.Product{}, statusError(resp.StatusCode, "fetching product "+sku)
	}
	var body productResponse
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		return domain.Product{}, fmt.Errorf("decoding product %s: %w", sku, err)
	}
	return body.toDomain(), nil
}
```

## Error translation

| Upstream | Domain |
|---|---|
| 404, when "not there" means the same to our caller | `ErrNotFound` |
| 409 | `ErrConflict` |
| 429, 502, 503, 504, timeouts, refused connections | `ErrUnavailable`, wrapped with the cause |
| other 4xx | wrapped, a 500: we sent something wrong, which is our bug |
| other 5xx | `ErrUnavailable` |

The upstream's error body never reaches our client. Its field names, codes and
messages belong to someone else's API. If a field-level error matters, map it to a
`domain.Violation` on **our** field name.

## Behaviour

- The `*http.Client` comes from `main.go` with a timeout set. `http.DefaultClient`
  has none.
- Retry only idempotent calls, only on `ErrUnavailable`, with backoff, inside the
  adapter. The application does not retry.
- The upstream's base URL and credentials come from config.
- Log nothing here; the error is handled where it stops.
