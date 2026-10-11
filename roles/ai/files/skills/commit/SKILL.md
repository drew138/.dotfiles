---
name: commit
description: |
  Carve finished, verified work into atomic conventional commits and write the
  messages. Invoked when development is complete and believed correct.
  Triggers: "commit this", "commit my changes", "write a commit message",
  "let's commit", "split this into commits".
allowed-tools: Bash, Read, Grep, Glob
---

# Committing finished work

Invoked when the work is done and already believed correct. **This skill does not
review the code or judge whether it is ready** — that is `go-review`, and it
happens before. The job here is to carve a verified working tree into commits and
describe them.

## Secrets, PII and PCI data

**Nothing containing a secret gets committed.** Scan the content being staged
before proposing anything.

If something is found, **reject the commit.** Report the delta as not ready and
hand it back for revision. Do not edit it out, do not stage around it, and do not
commit the rest while leaving that part for later — what happens to it is the
author's decision, not a detail to route around.

Look for:

- credentials, API keys, tokens, session cookies
- private keys and certificates: `.pem`, `.key`, `.p12`, `.jks`, `id_rsa`
- connection strings carrying a password
- `.env` files, and anything shaped like one
- PII or PCI data in fixtures, test data, sample payloads or logs

**Never print the value in the report.** Name the file, the line, and the kind of
thing it is. A report that quotes the key has just copied it somewhere new.

**Already committed is a different problem.** If the secret is in an earlier
commit rather than in the staged change, rejecting this commit achieves nothing —
say so plainly. It is in history, which needs rewriting, and the secret should be
treated as compromised and rotated whether or not the branch was ever pushed.

**Values encrypted at rest are meant to be committed.** An `ansible-vault`
string, a `sops`-encrypted file or a sealed secret is ciphertext, not a finding.
Only plaintext is.

### Logging that could leak

Reject the commit for code that *could* leak this data at runtime, not only for
literal values present in the diff.

The red flag is logging a **container** rather than named fields — a whole
struct, a request or response body, a header set, or a `%+v` of any of them.
Whether it leaks today depends on which data happens to flow through it, and that
is not a safety property.

- `httputil.DumpRequest` and `DumpResponse`
- logging `r.Header`, which carries `Authorization` and `Cookie`
- `log.Printf("%+v", req)`, or any struct dump
- a raw body or payload added as a structured log field
- an error wrapped around a request and then logged
- a debug-level statement printing a payload — the level is configuration, not a
  guarantee

Log named fields chosen deliberately, or masked values. A commit adding any of
the above is not ready, and is rejected and handed back for the same reason as a
literal secret.

These criteria mirror the logging rules in `go-review`; a change to either should
be made to both.

## Format

```
type(scope): description
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`,
`revert`, `ci`.

Scope is the area changed — a package, module, or role name. Omit it only when
the change genuinely spans everything. A breaking change takes `!` after the
scope: `feat(api)!: ...`

## Description

- **Imperative present.** Never `adds`, `added` or `will add`. The test is
  "If applied, this commit will ___".
- Lowercase, no trailing full stop.
- At most 72 characters including the type and scope.
- Say what changes in the system, not which files were touched.

### Choosing the verb

**Never repeat the type as the verb.** `fix(client): fix the retry` says nothing
twice. `fix(client): retry the token refresh on a 503` says what actually
changed. The type already classifies the commit; the verb should narrow it.

**Pick the most specific verb that is true.** `update`, `change`, `improve`,
`enhance`, `tweak` and `adjust` are almost always replaceable by something
sharper, and the sharper word is what makes a log skimmable a year later.

| intent | verbs |
|---|---|
| adding | add, introduce, implement, support, expose, enable, register, wire, bind, install |
| removing | remove, drop, delete, retire, prune, strip, unregister |
| replacing | replace, switch, swap, convert, migrate, promote, demote |
| fixing | stop, prevent, guard, correct, resolve, recover, reject, accept |
| tightening or loosening | restrict, tighten, relax, widen, narrow, bound, require, allow |
| reliability | retry, back off, time out, limit, debounce, deduplicate, harden |
| performance | cache, batch, reuse, precompute, short-circuit, avoid, reduce |
| restructuring | extract, inline, move, rename, split, merge, collapse, flatten, decouple, invert, reorder |
| observability | log, trace, instrument, surface, report, mask, redact, annotate |
| dependencies and meta | pin, bump, vendor, rotate, document, clarify, record, note |

**This table is illustrative, not a closed list.** The right verb for a change is
often not in it — reach for the accurate word rather than the nearest listed one.

Some of these carry information a generic verb cannot. `stop the handler hanging`
names a behaviour that ends. `surface the parse error` says something previously
swallowed is now visible. `bound the retry window` says a limit now exists where
none did. `pin` says a version stopped floating. Reach for those.

Two constructions that always have a sharper form: `make X faster` is `speed up
X`, and `use X` is `switch to X` when something was replaced.

## Body

The diff already shows *what* changed. The body exists to say **why**.

- Give the reason the change was made, and what it replaces if anything.
- Cite observed evidence — the number, the output, the thing that was run.
- **State what the verification does not prove.** This is the most useful line in
  a commit message and the one most often missing. A commit that says a test
  passed should say what the test could not cover.
- **At most two paragraphs, each at most two or three lines.** If it does not
  fit, the commit is doing more than one thing.
- Never a bullet list of files. Never a changelog.
- Omit the body entirely when the subject says everything.

## Ticket reference

Optional. A ticket key or link goes in a **trailer**. The scope is the area being
changed.

```
feat(client): retry the token refresh on a 503

The provider returns 503 during its deploy window, which surfaced as a
failed refresh rather than a retryable error.

Refs: C2-9147
```

A URL works in place of a key. Jira and Linear both detect keys anywhere in the
message, so a trailer is sufficient and it leaves the 72-character subject budget
untouched.

**Infer it, never ask.** In order:

1. the branch name, which usually encodes it — `feature/C2-9147-authentication`
2. the trailers of commits already on the branch

If neither yields a key, omit the trailer. It never blocks and it is never
prompted for, including when rewriting a series. Every commit in a series carries
the same reference.

## Atomic commits

One change per commit.

**Every commit must pass the repository's own checks.** In a compiled language
that means it builds; elsewhere it means the linters, formatters and tests the
repo already runs. No commit may leave the tree failing them, including when it
is the tip of a bisect.

**Tests go in the same commit as the code they cover.** Split them and a revert
strips the production symbols while leaving tests that reference them, which then
fails. `test:` is for commits that only add coverage to code that already exists.

**When atomic and passing conflict, passing wins** and the commit gets bigger.
A rename cannot be split without a broken intermediate state, so it is one
commit. A history that bisects into rubble is worse than a slightly coarse one.

**Never bundle unrelated changes.** If the tree holds two unrelated changes,
propose two commits. Do not quietly fold an incidental fix into a feature commit.

## What belongs together

**The unit is a logical change, not a file.** One file often holds hunks
belonging to different commits, and one commit often spans several files.

Correlated — these go in **one** commit:

- an endpoint, the service method behind it, the repository implementation it
  calls, the interface the service accepts to reach it, and the tests for all of
  them

Separate commits, and normally earlier in the series:

- server bootstrap and wiring
- shared configuration
- dependency additions
- build, lint or CI changes
- scaffolding generated from a template

Order is scaffolding, then shared infrastructure, then the features that use
them. Every commit has to build, so anything a later commit depends on is
committed before it.

## Staging hunks

`git add -p` is interactive and cannot be driven here. Stage a subset by writing
the diff to a patch, removing the hunks that belong to other commits, and
applying what remains to the index:

```bash
git diff --unified=0 > /tmp/commit-1.patch
git apply --cached --unidiff-zero /tmp/commit-1.patch
```

**Always `--unified=0`.** A hunk must mean one contiguous run of changed lines.
At the default three lines of context, two changes closer than that merge into a
single hunk, so hunk numbering stops matching what you planned against.

**`--unidiff-zero` is required** to apply a zero-context patch. Without it
`git apply` rejects the patch for having no context to locate.

**Split a hunk when contiguous deltas belong to different commits.** Contiguous
lines are one hunk even at `--unified=0`, so an atomic commit sometimes needs the
hunk broken up. Rewrite the header to cover only the lines being kept and drop
the rest:

```
@@ -2,2 +2,2 @@        two unrelated line changes
@@ -2,1 +2,1 @@        keep only the first
```

`@@ -oldStart,oldCount +newStart,newCount @@` — adjust both counts to the lines
you keep. This applies cleanly under `--unidiff-zero`.

Confirm the result by reading the index, never by counting hunks.

For a file that belongs entirely to one commit, `git add <file>` is simpler and
should be preferred — only reach for a patch when a file's hunks are split across
commits.

## Verifying a commit passes

Hunk-level splitting is exactly where a series starts failing, so check the
staged content rather than the working tree:

```bash
git stash push --keep-index --include-untracked
go build ./...
git stash pop
```

`--include-untracked` matters whenever the commit adds files. Without it the
untracked ones stay in the tree and the check sees more than the commit holds.

`--keep-index` leaves only the staged hunks in the tree, so the check sees
precisely what the commit will contain. Without this step it is the finished work
being verified, not the commit.

`go build ./...` is the example. Substitute whatever this repository actually
gates on — find it in the `Makefile`, `.pre-commit-config.yaml`, or the CI
workflow rather than assuming. A repository with no compiler still has checks:
linters, formatters, schema validation, a test runner.

## Propose before committing

Always show the plan first and wait:

- each commit in order, and for each, the files **and which hunks** of them
- the full message for each
- anything deliberately left unstaged, and why

Never commit a set of changes that has not been shown. Multiple commits from one
tree are easy to get wrong, and an unwanted commit is more annoying to undo than
a round trip costs.

**Never stage files the user did not intend.** Unrelated modified files stay
unstaged, and the plan says so explicitly rather than silently including or
dropping them.

Say which branch the commits will land on. If it is the default branch, say so
plainly rather than branching unasked or committing quietly.

## Writing the message

Pass the message on stdin so the body keeps its formatting:

```bash
git commit -F - <<'MSG'
fix(client): retry the token refresh on a 503

The provider returns 503 during its deploy window, which surfaced as a
failed refresh rather than a retryable error. Three attempts with backoff
covers the observed window.

Verified against the sandbox, which does not reproduce the deploy window —
so the retry path is exercised but the original failure is not.
MSG
```

The interactive `commit` script in this repo writes subject lines only and is for
committing by hand. Both produce the same format.

## Rebase onto the target branch

Commits end up on top of the current target branch. Fetch first — rebasing onto
a stale local ref achieves nothing.

Determine the target rather than assuming `main`:

```bash
git symbolic-ref --short refs/remotes/origin/HEAD
```

If that is unset, fall back to
`gh repo view --json defaultBranchRef --jq .defaultBranchRef.name`.

On a feature branch:

```bash
git fetch origin
git rebase --autostash origin/<target>
```

Already on the target branch, where there is nothing to rebase onto:

```bash
git pull --rebase --autostash origin <target>
```

`--autostash` matters because this skill deliberately leaves unrelated files
unstaged, and a rebase refuses to start against a dirty tree.

### Resolving conflicts

A conflict means the branch and the target changed the same lines.

**Prefer the resolution that preserves backwards compatibility.** Where both
sides can coexist, keep both — a field, method, parameter or endpoint the target
branch added stays, and the branch's change applies alongside it. Anything
already merged may have callers, and dropping it during a rebase removes it
silently, with no diff anyone will review.

**Ask when compatibility and the branch's purpose contradict each other.** If
the branch deliberately removes or replaces what the target added, no resolution
satisfies both, and picking either one discards work without saying so. Stop,
show both sides, and ask.

Ask as well whenever the resolution depends on intent that is not visible in the
diff.

**Always report what was resolved and how**, file by file. A conflict that was
resolved and never mentioned is indistinguishable from one that never happened,
and it is the thing most likely to be wrong.

**Never `git rebase --skip`** — it discards the commit entirely.

After resolving, build and run the tests. A resolved conflict is where a semantic
break hides, and by definition it now applies cleanly.

### After rebasing

Each commit's build guarantee was established against the old base, so rebuild
the final state afterwards. A rebase that applies cleanly can still produce a
semantic conflict that only a build or the tests reveal.

### Pushing a rebased branch

A branch that was already pushed needs `--force-with-lease`, never `--force`:

```bash
git push --force-with-lease
```

`--force-with-lease` refuses if someone else pushed in the meantime. `--force`
overwrites their work without asking. Do not rebase a branch other people are
working on unless they expect it.

## Rewriting a feature branch

Scrapping a series and rebuilding it is expected — the commits made while working
are rarely the commits worth keeping. Reviewing, adding more changes, and
recommitting the lot is a normal cycle, not a repair.

**Only commits unique to the branch may be rewritten**, meaning the range
`origin/<target>..HEAD`. Never rewrite a commit that already exists on the target
branch, and never rewrite the target branch itself.

**Record the current tip first and report it:**

```bash
git rev-parse HEAD
```

Recovery is then `git reset --hard <that sha>`. The reflog holds it too, but an
explicit sha in the report is what makes recovery obvious at the moment someone
needs it.

### Redoing the whole series

The approach to prefer. Move the branch pointer back to the base while keeping
every change staged, then commit again under the normal rules:

```bash
git reset --soft $(git merge-base HEAD origin/<target>)
```

The working tree is untouched — only which commits exist changes. From there the
carving, grouping, hunk-staging and message rules apply exactly as they would for
uncommitted work.

### Targeted edits

For smaller adjustments:

```bash
git commit --amend --no-edit
git commit --fixup=<sha>
git rebase --autosquash origin/<target>
```

`git rebase -i` opens an editor and cannot be driven here. Where a
non-interactive rewrite is genuinely required, drive it through
`GIT_SEQUENCE_EDITOR` to pick the action and `GIT_EDITOR` to supply the message:

```bash
GIT_SEQUENCE_EDITOR="sed -i '' 's/^pick <sha>/reword <sha>/'" \
GIT_EDITOR="cp /path/to/newmsg" \
git rebase -i --autostash <sha>~1
```

**`--autostash` is required**, not optional. A rebase refuses to start against a
dirty tree, and this skill deliberately leaves unrelated files unstaged.

### What still applies

- the secrets gate, re-run against the recommitted content
- every commit in the new series passes the repository's checks, verified per
  commit
- confirmation before rewriting anything
- `--force-with-lease` to push a branch that was already pushed

This is also the mechanism referred to above when a secret has already reached
branch history: rewrite it out, and rotate the secret regardless of whether the
branch was pushed.

## Never

- `wip`, `fix`, `update`, or any subject that describes nothing
- a subject naming files instead of the change
- claiming a verification that was not performed
- amending or rewriting a commit that has been pushed, unless explicitly asked
