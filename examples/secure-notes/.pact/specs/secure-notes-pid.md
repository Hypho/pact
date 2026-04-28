# PID Card — secure-notes
Version: v1.0 | Status: final | Date: 2026-04-28

## Who uses it?

A signed-in notes app user.

## What do they want to do?

Create and read personal notes without exposing notes owned by another user.

## Success Criteria

- User can create a note with title and body.
- User sees only their own notes in the list.
- User can open a note they own.
- Cross-user reads return a generic not-found result.

## Failure Scenarios

| Scenario | Trigger | User-visible result |
|----------|---------|---------------------|
| Empty title | Title is empty or whitespace | `Title is required` |
| Cross-user read | User B requests User A's note id | `Note not found` |
| Storage failure | Save operation fails | `Could not save note` |

## Explicitly Out of Scope

- Do not implement authentication or session management.
- Do not implement note sharing.
- Do not implement encryption, audit logs, or retention policy.
- Do not implement persistence beyond the in-memory example store.

## Feature Relationships

- Depends on: signed-in user identity supplied by caller
- Impacts: future note sharing and audit trail features
- Shared contract: note ownership boundary

## Boundary Detection Result

Status: continue with documented boundary.
Touched characteristics:
- B-M01 complex permission: user-owned note access boundary.
- B-H06 sensitive data: personal note content. This example demonstrates detection and contract framing only; production sensitive-data controls require specialist review.
Human decision: acceptable for example code because data is in-memory and non-production.

