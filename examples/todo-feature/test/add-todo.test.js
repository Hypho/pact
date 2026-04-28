import assert from "node:assert/strict";
import { createTodoStore } from "../src/todo.js";

const store = createTodoStore();

const created = store.addTodo("Buy milk");
assert.equal(created.ok, true);
assert.equal(created.todo.id, "todo-1");
assert.equal(created.todo.text, "Buy milk");
assert.equal(created.input, "");
assert.deepEqual(store.listTodos(), [{ id: "todo-1", text: "Buy milk" }]);

const empty = store.addTodo("   ");
assert.equal(empty.ok, false);
assert.equal(empty.error, "Todo text is required");

const longText = "x".repeat(121);
const tooLong = store.addTodo(longText);
assert.equal(tooLong.ok, false);
assert.equal(tooLong.error, "Todo text is too long");

const failingStore = createTodoStore({ failSave: true });
const failed = failingStore.addTodo("Keep input");
assert.equal(failed.ok, false);
assert.equal(failed.error, "Could not save todo");
assert.equal(failed.input, "Keep input");

console.log("output: 4 passed");

