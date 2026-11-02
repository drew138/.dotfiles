# Repository adapters

An outbound adapter that implements a persistence port.
Templates: `assets/templates/postgres/` and `assets/templates/mysql/`.

## Files

| File | Holds |
|---|---|
| `<store>.go` | `Repository`, `New(db *sql.DB)`, one method per port method, `domainError`, `uniqueFields` |
| `dto.go` | row structs with `db` tags and `toDomain()` |
| `mappers.go` | `map<Entity>Row(domain.Entity) <entity>Row` |

The package is named for the store (`postgres`, `mysql`), so the constructor reads
`postgres.New(db)`. When the driver's package has the same name, alias the driver:
`driver "github.com/go-sql-driver/mysql"`.

## Rows

```go
type userRow struct {
	ID       int64  `db:"id"`
	Username string `db:"username"`
	Password string `db:"password"`
}

func (r userRow) toDomain() domain.User { … }
```

Rows mirror the table, not the domain. When they differ (a JSON column, a nullable
column, a joined field) the difference is resolved in `toDomain` and the mapper,
never by tagging the domain struct.

Nullable columns use `sql.Null*` in the row and a zero value or pointer in the domain,
decided in `toDomain`.

## Methods

- Take `ctx` and pass it to every `…Context` call. Never use `db.Exec` without it.
- Convert with the mapper first, query with the row's fields.
- Send every error through `domainError(err, "<what you were doing>")`.
- Clear secrets from what you return after a write (`saved.Password = ""`), so the
  hash travels no further than it must. Reads return what the use case needs: login
  needs the hash.
- One method = one statement, or one transaction for an atomic change. Open the
  transaction, `defer tx.Rollback()`, commit at the end; the rollback after a
  commit is a no-op.

## Error translation

Covered in `errors.md`. When you add a `UNIQUE` constraint, add it to
`uniqueFields` in the same change, or duplicates come back as a field-less conflict.

## Migrations

`migration/` at the repository root, golang-migrate format:
`000002_add_users_email.up.sql` and `.down.sql`. The rules (one per pull request,
backwards compatible, never edit an applied one, every column described, indices for
lookups) are in `go-review`. The scaffold writes `TODO: describe` comments and
`scripts/check` fails until they are replaced.

Migrations run as a deploy step (`migrate -path migration -database "$DATABASE_URL" up`),
not at service startup, so a broken migration stops the deploy instead of every
replica.

## Integration tests

Per `go-tests`: testcontainers, the service's own migrations, a reset between tests,
no `t.Parallel()`.

## Adding a second store

A new folder beside the first (`repository/mysql/` next to `repository/postgres/`),
implementing the same port. `main.go` picks one. The application does not change.
