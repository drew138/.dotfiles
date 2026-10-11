---
name: go-review
description: |
  Review Go changes against house conventions: delta-scoped findings, structured
  logging, no PII/PCI or credentials in logs, consumer-defined interfaces, no init,
  no utils packages, simple naming. Reports locally for your own changes; posts
  inline comments on someone else's pull request after confirmation.
  Triggers: "review this", "review my changes", "review PR", "code review",
  "check this before I push", "review before merging".
allowed-tools: Read, Grep, Glob, Bash
---

# Reviewing Go changes

Testing conventions are **not** restated here. They live in the `go-tests` skill,
which is the single source of truth — read it and check the diff against it.
Restating rules in two places guarantees they drift.

## Modes

| input | behaviour |
|---|---|
| your own changes | report findings locally, nothing is posted |
| someone else's pull request | post **inline comments** on the changed lines, after confirming |

Determine the mode from what was asked. For a pull request use `gh pr diff` and
`gh pr view`; for local work use `git diff` against the base branch.

**Never post without confirming.** Print every finding first and ask. A comment
on someone else's pull request is public and notifies them even if deleted
afterwards, so a wrong finding is not recoverable.

## Scope

**Comment only on lines the diff changed.** The one exception is a high-risk
vulnerability, which is worth raising wherever it is.

Looking is not commenting. Read whole files for context, and inspect the package
tree where a structural rule requires it — package layout, interface placement,
duplicate config packages cannot be judged from changed lines alone. The
restriction is on where findings are reported, not on what may be read.

## Severity

Two levels. No score — a number invites arguing about the number instead of
fixing the thing.

**Blocking** — objectively wrong, must be addressed:

- PII or PCI data in logs
- credentials, tokens or secrets in logs
- `init()`, or package-level variables that do work
- a package exporting an interface it implements
- a `utils` package, or anything added to one
- `fmt.Print*`, `println`, or unstructured text logging
- more than one config package in a service
- violations of the `go-tests` conventions
- a migration breaking any rule under **Migrations** below

**Advisory** — taste, offered as a suggestion:

- constructor naming
- naming shape generally
- whether logging is sufficient

Advisory findings are phrased as suggestions, which makes them safe to post on
anyone's pull request.

## Cap

Report at most **15 findings**, most severe first. If more were found, say how
many were omitted. A review of thirty items gets skimmed exactly like a noisy
one, and the blocking findings get lost among the advisory ones.

## Logging

Structured logging only. Plain text log lines and `fmt.Print*` are blocking.

**Never log credentials, tokens or secrets. Never log PII or PCI data** —
card numbers, CVVs, full names, emails, national identifiers. Masked values are
acceptable. This is the most serious finding the review can produce and it is
always blocking.

Volume:

- at least one log per complete flow, at its boundary, carrying a correlation id
- every error logged exactly **once**, where it is handled

A function that logs an error and also returns it is the anti-pattern — the same
failure then appears at every level it passes through, and none of the entries
say more than the first. Errors propagate by wrapping:

```go
if err != nil {
	return fmt.Errorf("fetching user %s: %w", id, err)
}
```

and are logged at the point they stop propagating.

## Interfaces

**A package declares the interfaces it accepts, never the interfaces it
exposes.**

An application package defines what it needs and takes it as a parameter. The
adapter imports that package and implements it.

```go
package billing

type Repository interface {
	Find(ctx context.Context, id string) (Invoice, error)
}

func New(r Repository) *Service { ... }
```

```go
package postgres

type InvoiceRepo struct{ db *sql.DB }

func (r *InvoiceRepo) Find(ctx context.Context, id string) (billing.Invoice, error) { ... }
```

Declaring the interface beside its implementation inverts the dependency: the
consumer then imports the adapter, and the adapter cannot be swapped. Flag any
package that exports an interface it also implements.

## Package layout

- `cmd/` holds entrypoints only, no logic
- `internal/` holds everything not meant for external import
- `pkg/` only for code genuinely intended to be imported by other repositories
- **`utils`, `helpers`, `common`, `shared` and `misc` packages are banned.** If
  something needs a home, give it a named package describing what it does. A
  grab-bag package has no boundary, so it accumulates forever and everything
  ends up depending on it.
- **exactly one config package per service.** Never a second one inside
  `internal/`.

## No `init`

No `func init()`, and no package-level variables that call functions or perform
work:

```go
var client = mustNewClient(os.Getenv("URL"))
```

That is `init` with extra steps — the same unordered, implicit, import-time side
effects, and the same impossibility of testing or substituting it. Do the work in
a constructor the caller invokes.

## Migrations

**One migration per pull request**, with both an `up` and a `down`. A pull
request carrying several migration files is blocking — review and rollback both
become guesswork once a single change spans multiple versioned steps.

**Never modify a migration that already exists on the base branch.** Add a new
one. An edited migration means two environments hold the same version number
against different schemas, and nothing will ever tell you.

**Check the version number is not already taken**, on the base branch *and* on
other open pull requests — two branches reaching for `000040_` is a merge
conflict discovered at the worst moment. `gh pr list` and the diff of each open
pull request touching the migration directory answer this.

**The migration must be backwards compatible with the deployed version.** During
a rollout the old binary runs against the new schema. Dropping or renaming a
column in the same pull request that stops using it breaks production for the
length of the deploy. That is two phases in two pull requests: stop using it and
ship, then remove it.

**A rename is never one step.** Add the new column, write both, migrate, drop the
old one later.

**Data backfill never shares a migration with a schema change.** A long `UPDATE`
holds locks and stalls the deploy. Separate migration, or a job.

**`NOT NULL` on an existing column** requires a default or a completed backfill,
otherwise it fails against existing rows.

**Every new column carries a description.** In Postgres that is
`COMMENT ON COLUMN`. No exceptions for obvious-looking names — the name is what
someone guessed at the time, the comment is what it means.

**Prioritise indices.** Flag a new column used for lookups, filtering, joins or
ordering that has no index.

**The `down` restores the schema.** Where data loss is unavoidable — dropping a
column takes its data with it — the migration says so explicitly rather than
implying it is reversible.

## Naming

Simpler is better. Advisory unless it causes an actual collision.

- No stutter: `user.Service`, not `user.UserService`
- A package with one primary type exposes `New`, so `service.New()` rather than
  `service.NewService()`
- No `Manager`, `Helper`, `Processor` or `Util` types — name what it does
- No `I` prefix on interfaces
- Interfaces named for behaviour: `Repository`, `Notifier`, `Fetcher`
- Short receiver names

## Comments in the code under review

Flag comments that restate what the code does. A comment is justified only when
an unconventional decision was taken that a reader could not infer and that
cannot be expressed in the code itself. Build directives such as `//go:build` are
not comments for this purpose.

## Output

For each finding: file and line, whether it is blocking or advisory, what is
wrong, and the concrete consequence. A finding that cannot name a consequence is
not a finding — drop it rather than hedging it.

State explicitly when nothing was found. A review that invents something to say
in order to look thorough is worse than one that says the diff is clean.
