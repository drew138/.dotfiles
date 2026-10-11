---
name: external-findings
description: |
  Record observed behaviour of external systems and third-party APIs into the
  personal knowledge base at ~/notes. For deliberate sandbox probing, or for a
  finding that surfaced while building. Only records what cannot be retrieved from
  our own code, tests or git.
  Triggers: "record this finding", "note how this provider behaves", "probe the
  sandbox", "document what the API actually does", "add this to my notes" when the
  subject is a third-party system.
allowed-tools: Read, Write, Glob, Grep, Bash, WebFetch
---

# Recording external system behaviour

Shares the knowledge base with the meeting notes: plain markdown at `~/notes`,
same concept notes, same alias rules. A system discussed in a meeting and the
same system observed in a sandbox land on the same concept page, reachable from
any repository.

## The qualifying test

Before writing anything, ask:

> **Could this be obtained by reading our code, running our tests, or looking at
> git?**

**Yes — do not write it.** A note duplicating something verifiable is redundant
the day it is written and misleading once it drifts, while the truth sits one
grep away.

**No — it qualifies.** Third-party behaviour cannot be recovered later at any
price. Vendor documentation is often wrong, sandbox diverges from production, and
nothing announces a change.

Qualifying material:

- what an API actually returns, including real error codes and undocumented fields
- where sandbox and production differ
- rate limits, timeouts and throttling observed in practice
- what an external certification or review process actually required
- what a vendor said in a call or support thread that is not in their documentation
- behaviour that contradicts the documentation

Not qualifying: how our own code works, our configuration, our migrations, our
tests, anything in git.

## Two ways in

**Deliberate probing**, which is the better one. Pick a question about an external
system, exercise it in sandbox, record what happened. The output is a behaviour
map rather than an anecdote, and it covers what worked as well as what failed.

**Incidental discovery**, while building something else. Lower quality because it
is shaped by whatever you happened to hit, but still worth recording when it
passes the test above.

### Probing rules

- **Sandbox only. Never probe production.**
- Respect rate limits. A characterisation run that gets an account throttled or
  blocked costs more than the knowledge is worth.
- Record what succeeded, not only what failed. A map with only failures tells a
  future reader nothing about the working path.

## Never record secrets

This is where recording external behaviour pulls hardest in the wrong direction.
These notes are plain files with no encryption and no access control.

**Never record secrets** — credentials, keys, tokens, account identifiers, or
captured request and response payloads containing any of them.

Record the shape and the class instead:

```
A request carrying an expired token returned 401 with code AUTH_014.
```

not the token. The behaviour is the finding; the value is a liability.

## Observations, never advice

Every entry is a dated observation of what happened. Never a recommendation.

```
On 2026-10-10 the batch endpoint returned 413 for payloads above 1 MB in sandbox.
```

is durable. A future reader can see when it was observed and judge whether to
trust it.

```
Don't use the batch endpoint.
```

is advice. It carries no date, cannot be checked, and becomes a trap the moment
the limit is raised.

External systems change without telling you, and unlike our own code you cannot
cheaply verify them. The date and the conditions are what make the note safe to
keep.

## Note format

Filename: `YYYY-MM-DD <system> <subject>.md`

```markdown
---
date: 2026-10-10
system: <the external system>
environment: sandbox
concepts: ["[[webhook-retries]]"]
---

## Observed

What happened, concretely. Exact codes, field names, limits, timings.

## Conditions

What it was observed against: endpoint, API version, request shape, account
type. Enough that someone could repeat it.

## Contradicts documentation

Where the documented behaviour and the real behaviour differ, and what the
documentation claims.

## Unresolved

What was not determined.
```

Omit any section that would be empty.

## Length

Prose is capped at **two or three paragraphs for the whole note**, not per
section. A note that will not fit is either holding more than one thing or
padding, and a long note will not be read whole — it crowds out better context
when retrieved.

The one exception is a code block holding an API specification — a request or
response shape, a schema, a payload example. Those may be as long as they need to
be, since a truncated specification is useless. The cap applies to the prose
around the block, never to the block itself.

## Superseding an earlier note

Never edit or delete an existing note. Writing is create-only, and there is no
backup or version history.

External behaviour changing is the normal case, not an error. When a new
observation contradicts an older note, write a new note and state the change
plainly:

```
Previously recorded on 2026-04-02 as a 1 MB limit; now 5 MB.
```

Both notes stay. The dates are what let a reader weigh them.

## Default to writing nothing

Most sessions produce no note. If something is written every time, the bar is
wrong.

Before writing, search the existing notes for the same system and subject. If the
behaviour is already recorded and unchanged, write nothing. Repetition is how a
knowledge base becomes unsearchable — every restated observation makes the
original harder to find.

Write no narrative. No sequence of what was tried. Only observations that pass
the test.

## Concepts

Use the existing concept notes and their aliases, exactly as the meeting notes
do: read what exists, reuse the exact term, create a new concept only when
nothing fits, and link only terms that have concept notes.

The external system itself is usually worth a concept note, so that everything
observed about it and everything discussed about it share a page.

## Reporting

State plainly what was written, what was skipped and why, and any new concepts
created. If nothing qualified, say so rather than writing something to show
effort.
