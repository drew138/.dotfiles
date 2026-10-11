---
name: go-tests
description: |
  Write Go tests: table-driven, testify (require for setup, assert for comparisons),
  parallel subtests, exact mock arguments, mocks and fixtures in a separate
  in-package file, integration tests behind a build tag using testcontainers and
  the service's own migrations.
  Triggers: "write tests for", "add a test", "unit test this", "integration test",
  "table test", "test coverage for", any request to test Go code or review Go tests.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Writing Go tests

Two kinds of test: **unit** and **integration**. Write both for a service.
Integration tests exist where behaviour cannot be proven without real infra.

Most rules here apply to both. The mock rules apply to unit tests only —
integration tests have no mocks.

## What gets tested

Test business logic: functions and methods with behaviour, branches, rules and
error paths.

Never write tests for:

- constructors
- `main`
- anything under `cmd/` or `config/`
- plain getters and setters
- generated code

Calling a constructor to build the subject is normal. `NewService(repo, clock)` in
the arrange step is correct; `TestNewService` is not.

## Coverage

Aim for **90%**, measured over the code the scope rules above say to test — the
packages holding business logic, not the whole module. Constructors, `main`,
`cmd/`, `config/` and generated code are excluded from testing, so counting them
in the denominator makes the target unreachable by construction.

```bash
go test -coverprofile=cover.out ./internal/...
go tool cover -func=cover.out | tail -1
```

`go tool cover -func=cover.out` without the tail shows per-function figures,
which is where the gaps actually are.

**Coverage counts executed statements, not verified behaviour.** A test that
raises the number without asserting anything is worse than no test — it buys
false confidence and is then counted as covered. That is the same defect as an
unpinned mock argument, and the number will not show it.

So never write a test to move the figure. If a line is hard to cover, that is
usually a design signal: an un-injected dependency, or a branch that cannot be
reached at all.

**Go measures statements, not branches.** Ninety percent of statements can still
leave every error return untested, because the happy path is most of the
statements. Prefer covering an error path over adding another happy-path case —
the `wantErr` column is what reaches those.

**When 90% is not reachable, say so.** Report the figure and name which branches
are uncovered and why. An honest 78% with the gaps named is worth more than 90%
reached by padding.

## File layout

Every file sits in the **same package** as the code under test. Never an external
`_test` package — internal tests reach unexported identifiers and can mock
unexported interfaces.

| file | contents |
|---|---|
| `<file>_test.go` | unit tests |
| `<file>_integration_test.go` | integration tests |
| `<file>_mock_test.go` | mocks, their constructors, `anyCtx`, infra fixtures |

**No shared test utility packages.** A `_test.go` file cannot be imported by
another package, and nothing here is written to be reused. Encapsulation is
preferred over reuse: a package that needs Postgres carries its own setup
function rather than adapting a shared one. Repetition across packages is
accepted; coupling between them is not.

This skill is the canonical copy of those setup blocks. Local copies are free to
diverge where a package genuinely needs something different.

## Naming

| subject | test name |
|---|---|
| function `CreateUser` | `TestCreateUser` |
| method `CreateUser` on `Service` | `TestService_CreateUser` |

PascalCase throughout, struct name first, one underscore. No other underscores —
case descriptions belong in the table's `name` field.

## No comments

Test code carries no comments. The `name` field labels a case; a comment
restating it is noise.

Two exceptions:

- `//go:build` lines, which are compiler directives rather than prose
- a genuinely unconventional decision a reader could not infer and must remember

Conventions described by this skill are never the second case. The rule lives
here, not repeated across test files.

## Table tests

Everything is table-driven, including single-case tests, unit and integration
alike. Mock expectations differ per case, so each case carries its own setup.

```go
func TestService_CreateUser(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name       string
		input      CreateUserInput
		setupMocks func(*MockRepo, *MockClock)
		want       User
		wantErr    error
	}{
		{
			name:  "persists the user",
			input: CreateUserInput{Email: "a@b.c"},
			setupMocks: func(repo *MockRepo, clock *MockClock) {
				clock.On("Now").Return(fixedTime)
				repo.On("Save", anyCtx, User{Email: "a@b.c", CreatedAt: fixedTime}).Return(nil)
			},
			want: User{Email: "a@b.c", CreatedAt: fixedTime},
		},
		{
			name:  "returns ErrDuplicate when the email is taken",
			input: CreateUserInput{Email: "taken@b.c"},
			setupMocks: func(repo *MockRepo, clock *MockClock) {
				clock.On("Now").Return(fixedTime)
				repo.On("Save", anyCtx, User{Email: "taken@b.c", CreatedAt: fixedTime}).Return(ErrDuplicate)
			},
			wantErr: ErrDuplicate,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			repo := newMockRepo(t)
			clock := newMockClock(t)
			tt.setupMocks(repo, clock)

			svc := NewService(repo, clock)
			got, err := svc.CreateUser(t.Context(), tt.input)

			if tt.wantErr != nil {
				require.ErrorIs(t, err, tt.wantErr)
				return
			}
			require.NoError(t, err)
			assert.Equal(t, tt.want, got)
		})
	}
}
```

## Assertions

Use `testify`. Both `require` and `assert` have a job, and the choice is
mechanical, not a matter of taste:

> **If any line after the assertion depends on what was asserted, use `require`.
> If nothing does, use `assert`.**

| situation | use |
|---|---|
| `err` from setup you are about to use | `require` |
| `err` before reading the returned value | `require` |
| length before indexing | `require` |
| pointer before dereferencing | `require` |
| the `wantErr` match | `require` |
| final value comparisons | `assert` |
| several independent fields at the end | `assert` |

`require` calls `t.FailNow()`, so the test stops at the real problem. `assert`
records the failure and keeps going, which is what you want for comparisons —
three mismatched fields reported at once beats finding them one run at a time.

Getting this wrong in the `require` direction costs nothing. Getting it wrong in
the `assert` direction means execution continues with a nil or empty value and
panics, and a panic aborts the whole test binary, killing every parallel test
running alongside it.

Setup errors that are not the subject of the test — starting a server, opening a
fixture — are `require.NoError` and nothing more.

One constraint: `t.FailNow()` must be called from the test's own goroutine. If a
test spawns a goroutine, collect the result and assert it on the main path rather
than calling `require` inside the goroutine.

## Errors

`wantErr` is an `error`, never a `bool`. A bool passes when *any* error occurs,
including one from a branch the case was not exercising — the same defect as an
unasserted mock argument.

```go
require.ErrorIs(t, err, tt.wantErr)
require.ErrorAs(t, err, &target)
```

Never assert message text with `EqualError` or `Contains`; those break when
someone rewords a message. Declare sentinel errors so `ErrorIs` has something to
match.

## Mock arguments — unit tests

Assert exact arguments. An expectation that does not pin its arguments proves
only that a call happened.

**`mock.MatchedBy` is banned. There is no exception.**

**`mock.Anything` is permitted for `context.Context` and nothing else**, through
one declared identifier:

```go
var anyCtx any = mock.Anything
```

```go
repo.On("Save", anyCtx, expectedUser).Return(nil)
```

A context is derived by the callee, so the value a mock receives never equals the
one the test passed. Every other argument is knowable and must be pinned.

### When an argument looks unknowable

Timestamps and generated identifiers are the usual case, and the moment the
banned matchers get reached for. Inject the source instead:

```go
type Clock interface { Now() time.Time }
type IDGen interface { New() string }
```

The mock then receives `fixedTime` and `"id-1"`, both asserted exactly. Reaching
for a matcher is the signal that a dependency is hidden.

## The mock file

```go
package user

import (
	"context"
	"testing"

	"github.com/stretchr/testify/mock"
)

var anyCtx any = mock.Anything

type MockRepo struct {
	mock.Mock
}

func newMockRepo(t *testing.T) *MockRepo {
	t.Helper()
	m := &MockRepo{}
	m.Test(t)
	t.Cleanup(func() { m.AssertExpectations(t) })
	return m
}

func (m *MockRepo) Save(ctx context.Context, u User) error {
	args := m.Called(ctx, u)
	return args.Error(0)
}
```

Every double is obtained through a constructor taking `*testing.T`. That makes a
fresh instance the only way to get one, routes failures to the subtest that owns
them through `m.Test(t)`, and verifies expectations through `t.Cleanup` so
`AssertExpectations` cannot be forgotten.

`t.Cleanup` rather than `defer` in the parent: parallel subtests run after the
parent function returns, so a deferred call fires before they have run.

## Integration tests

Behind a build tag, so a normal run does not compile them:

```go
//go:build integration
```

```
go test ./...                      unit only
go test -tags=integration ./...    integration
```

Infra comes from testcontainers, and the schema comes from **the service's own
migrations**. Never write DDL in a test. A hand-written test schema drifts from
production silently; applying the real migrations makes the schema correct by
construction and makes a broken migration fail the tests rather than the deploy.

The setup function lives in that package's `_mock_test.go`, same shape as the
mock constructors:

```go
type testPostgres struct {
	*database.Database
}

func newPostgres(t *testing.T) *testPostgres {
	t.Helper()

	container, err := postgres.Run(t.Context(), "postgres:14.1-alpine",
		postgres.WithDatabase("test"),
		postgres.WithUsername("postgres"),
		postgres.WithPassword("postgres"),
		testcontainers.WithWaitStrategy(wait.ForListeningPort("5432/tcp")),
	)
	require.NoError(t, err)
	t.Cleanup(func() { assert.NoError(t, container.Terminate(context.Background())) })

	dsn, err := container.ConnectionString(t.Context(), "sslmode=disable")
	require.NoError(t, err)

	m, err := migrate.New("file://../../migration", dsn)
	require.NoError(t, err)
	require.NoError(t, m.Up())

	pg := &testPostgres{Database: database.Open(dsn)}
	t.Cleanup(func() { pg.reset(t) })
	return pg
}
```

Four things in that block are deliberate:

- The migration path is a plain relative path. If the package moves, the test
  fails immediately with a source-not-found error — loud, not silent — which is a
  better trade than machinery that locates the repo root.
- `container.Terminate` takes `context.Background()`, not `t.Context()`:
  `t.Context()` is already cancelled by the time cleanups run.
- Migration directories accumulate files golang-migrate cannot parse. If a
  directory contains unversioned files, filter to properly versioned ones.
- The fixture is a struct rather than a bare handle, because a container that any
  test mutates needs a way to be put back.

### Resetting mutated state

A container is shared, so state a test writes is state the next test inherits.
Any fixture whose container can be mutated exposes a reset method, and the
constructor registers it with `t.Cleanup` so it runs at the end of every test
that took the fixture.

Register it in the constructor rather than calling it from each test. Tests that
forget leave poison behind, and the failure surfaces in an unrelated test later —
the same reasoning that puts `AssertExpectations` in the mock constructor.

```go
func (p *testPostgres) reset(t *testing.T) {
	t.Helper()

	rows, err := p.Query(`
		SELECT tablename FROM pg_tables
		WHERE schemaname = 'public' AND tablename <> 'schema_migrations'`)
	require.NoError(t, err)
	defer rows.Close()

	var tables []string
	for rows.Next() {
		var name string
		require.NoError(t, rows.Scan(&name))
		tables = append(tables, name)
	}
	require.NoError(t, rows.Err())

	if len(tables) == 0 {
		return
	}
	_, err = p.Exec("TRUNCATE " + strings.Join(tables, ", ") + " RESTART IDENTITY CASCADE")
	require.NoError(t, err)
}
```

`schema_migrations` is excluded deliberately. Truncating it makes golang-migrate
believe no migration has been applied, so the next run tries to recreate tables
that already exist and the whole package fails with an error that points nowhere
near the cause.

`RESTART IDENTITY` resets sequences, so a test asserting on a generated id sees
the same value whether it runs first or tenth. `CASCADE` handles foreign keys
without needing to order the truncation.

Reset always, rather than deciding per test whether something was mutated. It
costs one query, and it removes a judgement call that is wrong only in the
direction that breaks other tests.

Integration tests share a container, so they **omit `t.Parallel()`**. The reset
runs between tests, which is what makes sharing safe — and only holds because
they run serially.

## Parallelism

Call `t.Parallel()` in the parent and in every subtest wherever possible.

**The rule that makes it safe: nothing mutable is declared above `t.Run`.** The
table is read-only data. Mocks, the subject, and every fixture are built inside
the subtest closure.

`t.Parallel()` is not possible when the test:

- calls `t.Setenv` — Go panics if it is called in a parallel test
- mutates package-level state, a global registry, a singleton, or swaps a
  package-level variable
- shares a database, container or fixed port without per-case isolation, which
  covers every integration test
- depends on execution order or wall-clock timing

Omit it in those cases and keep everything else.

`t.TempDir()` and `t.Context()` are per-test and parallel-safe.

## Checks

The argument rules are greppable, since the only legitimate `mock.Anything` in a
package is the `anyCtx` declaration:

```bash
grep -rn 'mock\.Anything' --include='*_test.go' . | grep -v anyCtx
grep -rn 'mock\.MatchedBy' --include='*_test.go' .
```

Both must return nothing.
