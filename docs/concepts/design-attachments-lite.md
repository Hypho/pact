# Design Attachments Lite

Design Attachments Lite lets PACT capture product, flow, sequence, architecture, and UI interaction details only when a feature needs them.

It does not add a new required command or workflow step. The feature loop stays:

```text
pid -> contract -> build -> verify -> ship
```

PID decides whether a feature needs any attachment.

## Attachment Types

| Type | File | Use when |
|------|------|----------|
| Design Brief | `.pact/design/[feature]-design.md` | Business flow, user path, product options, or PRD boundary is unclear |
| Sequence | `.pact/design/[feature]-sequence.md` | Multi-module, async, third-party, permission chain, multi-state, or front/back-end sequence matters |
| Interaction Brief | `.pact/design/[feature]-interaction.md` | New page, multi-step form, complex list, bulk action, editor, mobile-critical path, or accessibility requirement matters |

## Trigger Rules

Default:

```text
No design attachment.
```

Generate an attachment only when PID detects a trigger.

Need a design brief:

- unclear business flow
- unclear user path
- multiple reasonable product options
- feature cannot map to Product Spine
- feature changes core PRD boundaries

Need a sequence:

- 2+ modules coordinate
- async job
- third-party integration
- permission chain
- multi-state transition
- front/back-end multi-step interaction

Need an interaction brief:

- new page
- multi-step form
- complex list / filter / sort
- drag/drop, batch action, editor
- mobile-critical path
- accessibility requirement

## How It Guides Development

`/pact.pid` records whether attachments are needed and where they live.

`/pact.contract` reads declared attachments and turns acceptance mapping into FC / NF / manual acceptance items.

`/pact.build` uses attachments to shape the component plan and implementation checks.

`/pact.verify` records evidence for declared attachments:

```text
design-evidence:
sequence-evidence:
interaction-evidence:
```

## What This Is Not

Design Attachments Lite is not:

- a required design phase
- a full PRD process
- a Figma replacement
- a reason to write sequence diagrams for every feature
- a UI design system

It is a small place to put design details when skipping them would make implementation ambiguous.
