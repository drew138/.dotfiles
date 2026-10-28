# Working rules

## Answers

- Be brief. Give one short reason, not a paragraph.
- Always explain a flow with a sequence diagram, and **one per answer** — a
  second only when asked for one.
- Keep it short: only the participants the point needs, and about six steps.
  Collapse the rest into one labelled step instead of drawing them.
- Draw it as plain text in a code block. Terminal output is the default and it
  cannot render mermaid, so a mermaid block in an answer is invisible.
- Mermaid is only ever for a committed document, where a viewer renders it. Never
  render a diagram to an image for terminal output.

## Changes

- Show the diff before applying it.
- Do only what was asked.
- Discussing an idea is not approval to build it.
- Act on an explicit instruction without asking again.

## Code

- Comments only where the code cannot explain an unconventional decision.

## Facts

- Verify before claiming. Say what the evidence does not prove.
- No guessing. Explicit identifiers, never "the most recent one".

## Safety

- Never print or commit a secret value.
- Never undo a change you did not make.
- Confirm anything outward-facing.

## SSH

- SSH keys live in Bitwarden. Before running anything that needs one (ssh, git
  over SSH, a signed commit), start Bitwarden if it is not running:
  `pgrep -x Bitwarden || open -g -a Bitwarden`.
