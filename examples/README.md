# PACT Examples

These examples show completed PACT feature flows after `ship`.

| Example | Purpose | Run |
|---------|---------|-----|
| [todo-feature](./todo-feature/) | Minimal happy-path feature with validation and storage failure handling. | `node test/add-todo.test.js` |
| [secure-notes](./secure-notes/) | More realistic feature with ownership checks, denied cross-user access, explicit boundaries, and verification evidence. | `node test/secure-notes.test.js` |

