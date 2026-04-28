# Example: Todo Feature

This example shows what a completed PACT feature flow looks like after ship.

Feature:

```text
add-todo
```

Flow:

```text
pid -> contract -> build -> verify -> ship
```

Files included:

```text
.pact/state.md
.pact/specs/add-todo-pid.md
.pact/knowledge/add-todo-verify.md
.pact/contracts/archive/add-todo.md
```

The active contract has already been archived, because the feature is shipped.

Use this example to understand:
- how PID captures intent and out-of-scope boundaries
- how contract converts intent into FC/NF entries
- how verify records real command output
- how ship updates state and archives the contract

