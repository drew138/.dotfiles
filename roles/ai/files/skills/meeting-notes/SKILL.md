---
name: meeting-notes
description: |
  Turn meeting transcripts into linked markdown notes in the personal knowledge
  base at ~/notes. Captures business logic and genuinely new information, discards
  the rest, and links notes through shared concept terms.
  Triggers: "process today's transcripts", "write up today's calls", "meeting notes",
  "summarise today's meetings", "add today's meetings to my notes".
  Scope is always today's meetings, and the user invokes it deliberately.
allowed-tools: Read, Write, Glob, Grep, Bash
---

# Writing meeting notes into the knowledge base

The knowledge base is a plain folder of markdown files at `~/notes`. No git, no
plugins, no database. The notes exist to be **searched later by an agent**, not
read as minutes.

The value of a note is the business logic it preserves. A record of what was
discussed is close to worthless; a record of how something is supposed to work is
worth keeping for years.

## Hard rules

1. **Never edit or delete an existing note.** Writing is create-only. There is no
   backup and no version history, so an edit that loses information is
   unrecoverable. The one exception is adding an alias to a concept note.
2. **Reading existing notes is expected.** You must read previous notes to judge
   whether something is new. Read widely, write one new file.
3. **Never invent.** If the transcript is unclear, record that it was unclear.
   Do not smooth a gap into plausible prose.
4. **One note per meeting.** No per-concept summaries, rollups or index files.
   Links between notes are enough.

## Which transcripts to process

Only transcripts from **today**. Nothing older, no date ranges, no individually
named meetings — today's meetings are the entire scope of this skill.

Transcripts are often generated asynchronously and may appear hours after a
meeting ends, so a recently finished meeting may not have one yet. Say so rather
than reporting that the meeting had nothing in it.

## Where transcripts come from

Use whichever connected MCP server can reach them. Do not assume a particular
provider or hardcode a path. In order of preference:

1. A meeting- or transcript-specific server, if one is connected.
2. A document or drive server — meeting tools commonly write transcripts into
   cloud storage as documents named after the meeting.
3. A general workspace search server.

**If the server needs authentication, stop and say so.** Report which server it
is and that the user must authorise it — in Claude Code that means running `/mcp`
and selecting it. Do not fall back to another source, do not work from calendar
entries or meeting titles alone, and do not write a note from anything other than
a transcript. A note invented from a meeting's existence is worse than no note.

If no server can reach transcripts at all, say that plainly rather than producing
nothing silently.

## Reading a transcript

Layout varies by provider, so do not rely on one. Some label each turn with a
speaker and timestamp, some are continuous prose, some interleave captions.

Work from what is actually there:

- Where speakers are labelled, use the labels to attribute statements.
- Where they are not, do not guess who said what — record the substance without
  attribution.
- Timestamps are not needed; ignore them.
- Automatic transcription mishears names and technical terms. If a term is
  garbled but inferable from context, record the term you are confident about. If
  it is not inferable, say the transcript was unclear rather than picking a
  plausible word.

## What to capture

In priority order:

1. **Business logic.** How something is supposed to behave. Rules, constraints,
   thresholds, orderings, edge cases, what happens on failure, which conditions
   change the outcome. This is the highest-value content and most of what is worth
   writing down.
2. **Decisions that change how something works**, and what they replaced.
3. **Problems and their causes**, including the specific symptom.
4. **Anything unresolved**, stated explicitly. "Nobody could explain why it only
   happens in one environment" is valuable and must not be dropped.

Do not record: pleasantries, scheduling chatter, who joined late, restatements of
things already in the knowledge base, or a narrative of the conversation's shape.

## The novelty test

Before writing anything, search the existing notes for the topics this meeting
covered. Then for each candidate point, ask two questions:

|  | relevant | not relevant |
|---|---|---|
| **new** | keep | discard |
| **not new** | keep only if it corrects or sharpens what is already recorded | discard |

"Not new and not relevant" is discarded silently. Repetition is the main way a
knowledge base becomes unsearchable — every restated point makes the original
harder to find.

If a point contradicts or refines something already recorded, keep it and say
plainly what changed, e.g. "previously recorded as X; now Y". Do not edit the
older note.

**If nothing survives the test, write no note.** Report that the meeting produced
nothing new. An empty or padded note is worse than no note.

## Note format

Filename: `YYYY-MM-DD <short meeting title>.md`

```markdown
---
date: 2026-10-10
attendees: [Name One, Name Two]
concepts: ["[[retry-policy]]", "[[export-pipeline]]"]
transcript: <link to the source transcript>
---

## Logic

How things work, as established in this meeting. The substance of the note.

## Changes

What changed from what was previously understood, if anything.

## Unresolved

What was left open.
```

Omit any section that would be empty. Keep frontmatter to these fields. Links in
frontmatter still count as links, so `concepts` builds the graph without
cluttering the body.

## Writing for retrieval, not for reading

The reader is a search tool. Optimise accordingly:

- **Keep specifics verbatim.** Error strings, status codes, field names, numbers,
  thresholds, identifiers. "Discussed a failure" is unfindable; "the export times
  out at 30s when the batch exceeds 10k rows" is findable in a year.
- **Keep the vocabulary that was actually used.** Distinctive nouns are what make
  a note findable. Do not translate domain language into general prose.
- **Make each note self-contained.** Resolve pronouns and name things explicitly.
  An agent retrieves a fragment with no surrounding context, so "they said it was
  broken" carries nothing.
- **Short is good.** A three-line note that captures one rule is a success.

## Length

Prose is capped at **two or three paragraphs for the whole note**, not per
section. A note that will not fit is either holding more than one thing or
padding, and both make the knowledge base harder to search.

The one exception is a code block holding an API specification — a request or
response shape, a schema, a payload example. Those may be as long as they need to
be, since a truncated specification is useless. The cap applies to the prose
around the block, never to the block itself.

## Concepts and the vocabulary

Concepts are the recurring subjects of the notes, expressed as short kebab-case
terms that emerge from the meetings themselves. They are not people, dates or
file names.

Before writing a note:

1. List the existing concept notes in `~/notes` and read their `aliases`.
2. If the meeting is about an existing concept, **reuse that exact term**.
3. Only create a new concept when nothing existing fits.
4. Link only terms that have concept notes. Everything else stays plain text.

Consistency is the whole point. `[[retry-policy]]`, `[[Retry Policy]]` and
`[[retry_policy]]` are three unrelated pages to a link graph, so inconsistent
naming silently produces a useless graph that still looks populated.

A new concept note is a stub whose only job is to declare aliases:

```markdown
---
aliases: [retries, retry-backoff]
---

# retry-policy
```

Never write prose into a concept note. Adding an alias to an existing one is
allowed; changing anything else is not.

## Reporting

End by stating plainly: how many transcripts were found, how many notes were
written, which meetings produced nothing new, and any new concepts created. If
nothing was found at all, say so rather than producing a note.
