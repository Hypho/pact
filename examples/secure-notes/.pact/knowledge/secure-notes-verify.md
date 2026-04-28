# Verify Record — secure-notes
Contract: secure-notes.md | Date: 2026-04-28

## Adversarial Results

| FC | Boundary input | Actual output | Holds |
|----|----------------|---------------|-------|
| FC-01 | `user-a`, `Launch plan`, `Draft the release plan` | `output: created note id=note-1 ownerId=user-a title="Launch plan"` | yes |
| FC-02 | list after `user-a` and `user-b` both create notes | `output: list for user-a length=1 ownerId=user-a` | yes |
| FC-03 | owner reads `note-1` | `output: read ok body="Private A"` | yes |
| FC-04 | `user-b` reads `user-a` note id | `output: {"ok":false,"error":"Note not found"}` | yes |
| FC-05 | title `   ` | `output: error "Title is required"` | yes |
| FC-06 | store configured with `failWrites=true` | `output: {"ok":false,"error":"Could not save note"}; list length=0` | yes |

## Test Report

```text
command: node test/secure-notes.test.js
output: 6 passed

result: PASS
```

## Verdict

verdict = PASS

