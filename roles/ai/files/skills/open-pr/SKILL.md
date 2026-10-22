---
name: open-pr
description: |
  Open a draft pull request with a short summary of its objective, against a base
  branch confirmed by the user.
  Triggers: "open a PR", "open a pull request", "raise a PR", "put this up for
  review", "create the PR".
allowed-tools: Bash, Read, Grep, Glob
---

# Opening a pull request

Always a **draft**. The body is a short summary of the objective — what the
change is for and why. No templates, no checklists.

Repository pull request templates are ignored deliberately. Most of what they
contain is attestation about work a person did — DBA review, QA runs, approval
from named people — and filling those in would be fabricating a claim.

## Branch name

[Conventional Branch](https://conventionalbranch.org/) v1.1.0 —
`<type>/<description>`, with the ticket key as the whole description:

```
feature/TRU-196
bugfix/C2-9147
```

The type follows the commit type the work carries:

| commit type | branch type |
|---|---|
| `feat` | `feature` |
| `fix` | `bugfix` |
| a production incident being patched now | `hotfix` |
| cutting a version | `release` |
| `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci` | `chore` |

**The ticket key alone, written exactly as the tracker writes it.** `TRU-196`,
not `tru-196`. The spec restricts the description to lowercase; we deviate there
on purpose, because the key is an identifier and changing its case makes the
branch name and the tracker two different strings to reconcile.

Nothing else in the description. The spec permits one after the key —
`feature/issue-123-new-login` — and we do not use it. No username prefix, no
title slug. Linear and Jira both offer a generated name like
`andressalazar/tru-196-stop-pci-vgs-int-failing-on-unknown-vgs-card-ids`: do not
use it, and do not shorten it either.

The key therefore needs no translation when it is read back out of the branch
name for the pull request title or a `Refs:` trailer — it is already the key.

The spec's agent prefixes (`ai/`, `claude/`, `copilot/`, `cursor/`, `codex/`) are
not used: a branch is named for the work, not for who typed it.

`main`, `master` and `develop` are trunk branches and take no prefix. Never
create a branch with one of those names — branch off them.

**A branch on the wrong name gets renamed before the pull request is opened:**

```bash
git branch -m feature/TRU-196
git push origin -u feature/TRU-196
git push origin --delete <old-name>
```

The delete only applies if the wrong name was already pushed. **A pushed branch
someone has already reviewed or commented on is not renamed without asking** —
renaming orphans their comments.

No ticket key anywhere — not in the tracker, not in the commits — means the
description has no permitted form, so ask for the key rather than inventing one.

## Base branch

**Ask which branch to target. Never infer it.**

List what the repository actually has first, so the question is answerable rather
than open-ended:

```bash
git ls-remote --heads origin develop dev development staging stage
git symbolic-ref --short refs/remotes/origin/HEAD
```

Present the candidates that exist alongside the default branch, and wait. Do not
assume the default is `main` — detect it.

A pull request opened against the wrong base compares against the wrong history
and shows changes that are not yours, which is tedious to notice and annoying to
correct.

## Title

The ticket key inferred from the branch name, then a concise statement of the
objective:

```
C2-9147 retry the token refresh on 503
```

If the branch carries no key, omit it. Never ask for one.

## Body

A short summary of the objective — what the change is for and why. A few
sentences of prose.

Not a list of commits; those are already on the pull request and repeating them
adds nothing.

**State what was verified, and state explicitly what was not.** If nothing was
run, say so rather than leaving it implied. Never claim a verification that did
not happen, and never describe work that is not in the diff.

### The ticket link

**The body ends with a link to the ticket**, on its own line, above the
attribution lines:

```
Refs: [TRU-196](https://linear.app/yunoprod/issue/TRU-196)
```

The key is the one already inferred for the title, from the branch name. **Use
the ticket's real URL** — the one in the tracker, in a commit's `Refs:` trailer,
or wherever it was read during the work — verbatim. Construct it only when you
do not have it:

| key prefix | URL |
|---|---|
| `TRU-` | `https://linear.app/yunoprod/issue/<KEY>` |
| every other prefix | `https://yunopayments.atlassian.net/browse/<KEY>` |

One link, never two, and never a second copy inside the prose. **The link is
what keeps the body short** — the reason the summary can be a few sentences is
that anyone who wants the requirement clicks through to it. So do not paste the
ticket's description, acceptance criteria or comments into the body.

No key in the branch and none in the commits means no line. Omit it, say so when
reporting the body, and do not ask for one — the same rule as the title.

## Opening it

The branch has to exist on the remote first:

```bash
git push -u origin HEAD
gh pr create --draft --base <base> --title <title> --body-file -
```

A branch whose history was rewritten needs `--force-with-lease`, never `--force`.

No reviewers, no labels, no assignees. A draft is not ready for anyone, and
assigning one notifies them about something that is not finished.

## Show it first

Print the base branch, the title and the body, and wait.

A pull request is public and notifies watchers of the repository. Editing it
afterwards does not unsend that, so the review happens before it is opened, not
after.

## Never

- open a pull request as ready for review unless asked
- open against a base that was not confirmed
- include a commit list, a template, or checkboxes
- claim that tests passed, QA ran, or a review happened
- open one with no ticket link when the branch carries a key
- restate the ticket in the body instead of linking it
