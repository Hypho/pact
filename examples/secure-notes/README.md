# Example: Secure Notes

This example shows a completed PACT feature flow for a small business rule with an access boundary.

Feature:

```text
secure-notes
```

Flow:

```text
pid -> contract -> build -> verify -> ship
```

Files included:

```text
.pact/contracts/archive/secure-notes.md
.pact/knowledge/secure-notes-verify.md
.pact/state.md
.pact/specs/secure-notes-pid.md
package.json
src/notes.js
test/secure-notes.test.js
```

The feature is intentionally small, but it is less artificial than the todo example: it includes note ownership, cross-user denial, invalid input, and a storage failure case.

Run the example test:

```bash
node test/secure-notes.test.js
```

Expected output:

```text
output: 6 passed
```

