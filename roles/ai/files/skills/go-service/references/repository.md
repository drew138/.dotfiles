# Repository adapters

An outbound adapter that implements a persistence port, at
`internal/infrastructure/repository/<tech>/`. Its files are the shape every outbound
adapter follows: caches, clients and publishers too.

The code here shows the shape. Write the store-specific code for the store the
service uses, following that shape and the rules.

## Files

| File | Holds |
|---|---|
| `<tech>.go` | `Repository`, `New`, one method per port method, `domainError`, `constraintErrors` |
| `dto.go` | row structs with the store's tags and `toDomain()` |
| `mappers.go` | `map<Entity>Row(domain.Entity) <entity>Row` |

The package is named for the tech (`postgres`, `mysql`, `mongo`), so the
constructor reads `postgres.New(db)`. When the driver's package has the same name,
alias the driver: `driver "github.com/go-sql-driver/mysql"`.

## Rows

```go
type userRow struct {
	ID       int64  `db:"id"`
	Username string `db:"username"`
	Status   string `db:"status"`
}

func (r userRow) toDomain() domain.User {
	return domain.User{ID: r.ID, Username: r.Username, Status: domain.UserStatus(r.Status)}
}
```

Rows mirror the table, not the domain. Differences (nullable columns, JSON columns,
joined fields, enums stored as text) are resolved in `toDomain` and the mapper,
never by tagging the domain struct.

## Plain SQL

Every query is SQL written in the repository method, run through `database/sql` or
the driver (`pgx`). **Never GORM or any other ORM.** With AI writing the code, SQL
costs nothing extra, and every query stays visible in the method that runs it:
reviewable, explainable with `EXPLAIN`, and tunable without fighting a library.

```go
err := r.db.QueryRowContext(ctx,
	"INSERT INTO users (username, email, password) VALUES ($1, $2, $3) RETURNING id",
	row.Username, row.Email, row.Password).Scan(&row.ID)
```

- Parameters always go through placeholders (`$1`, `?`), never string formatting,
  so input can never become SQL.
- Select the columns by name, never `SELECT *`, so a new column cannot silently
  shift a `Scan`.

## Methods

- Take `ctx` and pass it to every call.
- Map with the mapper first; query with the row's fields.
- Send every error through `domainError(err, "<what you were doing>")`.
- Clear secrets from what you return after a write (`saved.Password = ""`). Reads
  return what the use case needs: login needs the hash.
- One method is one statement, or one transaction for an atomic change: begin,
  `defer tx.Rollback()`, commit at the end.

## Error translation

Every error that leaves the repository is a domain error (`errors.md`):

```go
var constraintErrors = map[string]error{
	"users_username_key": domain.ErrUsernameTaken,
}

func domainError(err error, doing string) error {
	switch {
	case isNotFound(err):
		return domain.ErrNotFound
	case constraintName(err) != "":
		if mapped, ok := constraintErrors[constraintName(err)]; ok {
			return fmt.Errorf("%s: %w", doing, mapped)
		}
		return fmt.Errorf("%s: %w: %w", doing, constraintKind(err), err)
	case isUnavailable(err):
		return fmt.Errorf("%s: %w: %w", doing, domain.ErrUnavailable, err)
	default:
		return fmt.Errorf("%s: %w: %w", doing, domain.ErrInternal, err)
	}
}
```

`isNotFound`, `constraintName`, `constraintKind` and `isUnavailable` are what each
store provides differently. Where to find them:

| | Postgres (pgx) | MySQL (go-sql-driver) |
|---|---|---|
| not found | `errors.Is(err, sql.ErrNoRows)` | same |
| the error type | `*pgconn.PgError` | `*mysql.MySQLError` |
| constraint name | `pgErr.ConstraintName` | not a field: parse the key name from the message (`for key 'users.username'`) |
| unique violation → `ErrConflict` | code `23505` | number `1062` |
| other integrity or data errors → `ErrInvalid` | code class `23` (FK `23503`, not null `23502`) and `22` (too long `22001`) | `1452` (FK), `1048` (not null), `1406` (too long) |
| unavailable | code classes `08`, `53`, `57P`; any `net.Error` | `driver.ErrInvalidConn`; any `net.Error` |

When you add a unique constraint, add it to `constraintErrors` and add its specific
error to `domain/errors.go` in the same change. If one is forgotten, the client
still gets a 409, just without the field.

## Constraints and limits

- **Name constraints explicitly** in migrations, so `constraintErrors` keys are
  predictable: `CONSTRAINT users_username_key UNIQUE (username)`.
- **Column limits are a safety net.** The API's validator tags are what users hit
  (`max=32`). The database keeps its own limit so bad data can never be stored by
  any path; if it fires, a tag is missing, and the client gets a generic 400.
- **Enum values are stored as plain text**; the API validates them.
- MySQL must run in strict mode (`STRICT_TRANS_TABLES`). Without it, MySQL
  silently truncates long values instead of failing.

## Migrations

At the repository root, in `migration/`. golang-migrate
format: `000002_add_users_email.up.sql` and `.down.sql`. The rules (one per pull
request, backwards compatible, never edit an applied one, every column described,
indices for lookups) are in `go-review`.

Migrations run as a deploy step
(`migrate -path migration -database "$DATABASE_URL" up`), not at service startup, so
a broken migration stops the deploy instead of every replica.

## A second store

A new folder beside the first (`repository/mongo/` next to `repository/postgres/`),
implementing the same port. `main.go` picks one. The application does not change.
