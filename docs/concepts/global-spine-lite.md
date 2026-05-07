# Global Spine Lite

Global Spine Lite is PACT's lightweight way to keep feature work tied to the product's main flow and architecture boundaries.

It does not add a new daily workflow step. The feature loop stays:

```text
pid -> contract -> build -> verify -> ship
```

Global Spine Lite adds two anchors that the existing loop reads only when needed:

| Spine | File | Purpose |
|-------|------|---------|
| Product Spine | `.pact/specs/PAD.md` | Product goal, core business flow, feature types, entities and states, UX consistency |
| Architecture Spine | `.pact/core/architecture.md` | Module boundaries, entity ownership, state ownership, write boundaries, dependency direction, ADR triggers |

## Product Spine

Use PAD as the Product Spine. Keep it short enough for agents to read during PID and contract work.

Minimum useful sections:

- Product goal
- Target users and core scenarios
- Core business flow
- Feature type definitions
- Core entities and states
- UX consistency rules
- Out of scope

The core business flow is the main constraint. A feature should map to one step or explicitly explain why it is auxiliary, admin, or experimental.

## Architecture Spine

Use `architecture.md` as the Architecture Spine. Keep it focused on boundaries, not full architecture documentation.

Minimum useful sections:

- Architecture principles
- Module boundaries
- Core entity ownership
- State machine ownership
- Permission decision location
- Write boundaries
- Dependency direction
- ADR triggers

## Feature Mapping

PID Cards should answer:

```text
Which PAD flow step does this feature serve?
What type of feature is it?
Where does the user go after success?
Which modules, entities, states, permissions, or dependencies are touched?
Does this require an ADR?
```

If the feature cannot map to the Product Spine:

```text
[A] update PAD
[B] mark it auxiliary / admin / experimental with a reason
[C] do not build it yet
```

## What This Is Not

Global Spine Lite is not:

- a PRD system
- a user research system
- a design management system
- an architecture governance platform
- a roadmap or project management tool

It is a small global constraint layer for AI-assisted feature delivery.
