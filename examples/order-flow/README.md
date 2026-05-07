# Example: Order Flow

This example shows Global Spine Lite in a completed PACT feature flow.

Feature:

```text
create-order
```

Flow:

```text
Product Spine -> PID -> contract -> build -> verify -> ship
```

Files included:

```text
.pact/specs/PAD.md
.pact/core/architecture.md
.pact/design/create-order-sequence.md
.pact/design/create-order-interaction.md
.pact/specs/create-order-pid.md
.pact/contracts/archive/create-order.md
.pact/knowledge/create-order-verify.md
package.json
src/orders.js
test/create-order.test.js
```

Use this example to understand:
- how PAD defines a core business flow
- how a PID maps a feature to a flow step
- how architecture.md defines a module and entity owner
- how optional design attachments capture sequence and interaction details
- how verify records runtime output plus flow / state evidence

Run the example test:

```bash
node test/create-order.test.js
```

Expected output:

```text
output: 5 passed
```
