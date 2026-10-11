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
