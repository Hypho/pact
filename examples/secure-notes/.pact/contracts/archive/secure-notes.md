# Behavior Contract — secure-notes
Version: v1.0 | PID: .pact/specs/secure-notes-pid.md | Date: 2026-04-28

## Functional Contract

### Happy Path

FC-01: When a signed-in user submits a non-empty title and body, the system creates a note owned by that user.
FC-02: When a user lists notes, the system returns only notes where `ownerId` matches the current user.
FC-03: When a user reads a note they own, the system returns the note content.

### Boundaries and Exceptions

FC-04: When a user reads another user's note id, the system denies access and returns `Note not found` without revealing ownership.
FC-05: When a user submits an empty or whitespace title, the system rejects creation with `Title is required`.
FC-06: When storage fails during note creation, the system returns `Could not save note` and does not create a note.

## Non-Functional Contract

NF-01: Access checks must use the current user id, not a caller-provided owner filter.
NF-02: Denied reads and missing notes must use the same generic error message.

## Test Coverage

Automated: FC-01 through FC-06, NF-02
Manual acceptance: NF-01 reviewed through implementation shape in `src/notes.js`

## Explicitly Out of Scope

- Do not implement authentication or session management.
- Do not implement note sharing.
- Do not implement encryption, audit logs, or retention policy.
- Do not implement persistence beyond the in-memory example store.

