---
name: flow-map
description: |
  Map the full call flow a change requires across services and third-party APIs,
  and produce one interactive artifact: a sequence diagram whose calls reveal
  their DTOs with the changed fields marked. Discovery, not implementation.
  Triggers: "map this flow", "what calls does this need", "trace the flow for",
  "which services does this touch", "diagram the calls".
allowed-tools: Read, Grep, Glob, Bash, Write, WebFetch
---

# Map a flow

Discovery for a change that spans more than one service. Produces one artifact:
a sequence diagram of the calls the work requires, where each call reveals its
DTOs and the fields the change alters.

Not a test of our code, and not an implementation step. A failing call is a
finding.

## Inputs

- the ticket or issue, from whatever tracker is reachable
- whatever the user says in the request, which outranks the ticket
- research, in the order below

## Research order

**1. The code.** Read the services the flow touches. A repository may hold
several services — name the package, not just the repository. Search across
repositories rather than guessing which one owns a call.

**2. Traces and logs, to fill what the code cannot show.** The code says a call
exists; a trace says whether it happens, in what order, how often, and what it
returns in practice. Prefer a real trace over inferring a sequence from a
handler.

Use whatever observability is reachable — a connected MCP server, a CLI, or an
exported log. **If none is reachable, say so and mark every ordering claim as
inferred from code**, rather than presenting it as observed.

**3. Third-party APIs: call them.** Where the flow leaves our systems, make real
requests in **sandbox or staging** and record what comes back. Documentation is
frequently wrong and sandbox frequently differs from production.

**Never call production.** Respect rate limits. Record what succeeded, not only
what failed.

**Never record a secret.** No keys, tokens, account identifiers or captured
payloads containing them. Record the shape and the behaviour: "a request with an
expired token returned 401 with code AUTH_014".

**4. Internal services: read logs and traces instead of calling them.** A
synthetic internal call writes state and fires events. Lean on what already ran.

## Output

One self-contained HTML file, beside the code that owns the flow or wherever the
user asks.

Two panes. Left, the sequence diagram. Right, the DTO for the selected call.

**Every participant appears, including third parties and datastores.** A diagram
that stops at our own boundary hides the part that surprises people.

**Number every call** and make the numbers the clickable control, listed beside
the diagram. Mermaid sequence diagrams do not support click handlers on messages,
so clicking the arrow itself is not available — the numbered list is.

```
┌────────────────────────────┬──────────────────────┐
│  sequenceDiagram           │  3. POST /authorise  │
│    1. POST /orders         │                      │
│    2. insert pending       │    merchantId   str  │
│    3. POST /authorise  ◄── │  + idempotencyKey    │
│    4. 402 declined         │  - legacyRef         │
│    5. mark declined        │    amount.value int  │
└────────────────────────────┴──────────────────────┘
```

**Mark DTO changes against the code as it is today**, not against an older
release. `+` is a field the change requires adding, `-` one it removes, unmarked
is unchanged. Use the real field names and types from the code.

**Include at least one failure path.** The happy path is the one everybody
already knows.

Render mermaid client-side from a CDN and keep everything else inline, so the
file opens from disk with no build step.

## What the artifact must state

- **Where each fact came from** — repository and file, a trace query with its
  window, or an observed sandbox response with its date. A reader must be able to
  rerun it.
- **What is still unknown.** Requirements only a person can answer are named as
  open questions, never invented. Gaps the traces did not cover are marked as
  gaps.

## Never

- call production
- record a secret value
- invent a requirement, a field or a response the research did not establish
- present a diagram as complete when a participant was not verified
