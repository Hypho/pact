const assert = require("assert");
const { createOrder } = require("../src/orders");

function makeStore({ failSave = false } = {}) {
  let counter = 0;
  const records = [];
  return {
    nextId() {
      counter += 1;
      return `order-${counter}`;
    },
    save(order) {
      if (failSave) return false;
      records.push(order);
      return true;
    },
    records
  };
}

let passed = 0;
function test(name, fn) {
  fn();
  passed += 1;
}

test("creates an order and moves to detail", () => {
  const store = makeStore();
  const result = createOrder({ customerName: "Ada", items: ["Book"] }, store);
  assert.equal(result.ok, true);
  assert.equal(result.order.id, "order-1");
  assert.equal(result.order.status, "created");
  assert.equal(result.destination, "order-detail");
  assert.equal(store.records.length, 1);
});

test("records the state transition", () => {
  const store = makeStore();
  const result = createOrder({ customerName: "Ada", items: ["Book"] }, store);
  assert.equal(result.stateTransition, "draft -> created");
});

test("rejects missing customer name", () => {
  const store = makeStore();
  const result = createOrder({ customerName: " ", items: ["Book"] }, store);
  assert.equal(result.ok, false);
  assert.equal(result.error, "Customer name is required");
  assert.equal(result.destination, "order-form");
  assert.equal(store.records.length, 0);
});

test("rejects empty items", () => {
  const store = makeStore();
  const result = createOrder({ customerName: "Ada", items: [] }, store);
  assert.equal(result.ok, false);
  assert.equal(result.error, "At least one item is required");
  assert.equal(result.destination, "order-form");
  assert.equal(store.records.length, 0);
});

test("keeps the user on the form when storage fails", () => {
  const store = makeStore({ failSave: true });
  const result = createOrder({ customerName: "Ada", items: ["Book"] }, store);
  assert.equal(result.ok, false);
  assert.equal(result.error, "Could not save order");
  assert.equal(result.destination, "order-form");
});

console.log(`output: ${passed} passed`);
