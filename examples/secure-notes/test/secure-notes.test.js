const assert = require("node:assert/strict");
const { NotesStore } = require("../src/notes");

const tests = [];

function test(name, fn) {
  tests.push({ name, fn });
}

test("creates a private note for the current user", () => {
  const store = new NotesStore();
  const result = store.createNote("user-a", "Launch plan", "Draft the release plan");

  assert.equal(result.ok, true);
  assert.equal(result.note.id, "note-1");
  assert.equal(result.note.ownerId, "user-a");
  assert.equal(result.note.title, "Launch plan");
});

test("lists only notes owned by the current user", () => {
  const store = new NotesStore();
  store.createNote("user-a", "A1", "Private A");
  store.createNote("user-b", "B1", "Private B");

  const notes = store.listNotes("user-a");

  assert.equal(notes.length, 1);
  assert.equal(notes[0].ownerId, "user-a");
  assert.equal(notes[0].title, "A1");
});

test("allows the owner to read a note", () => {
  const store = new NotesStore();
  const created = store.createNote("user-a", "A1", "Private A");

  const result = store.getNote("user-a", created.note.id);

  assert.equal(result.ok, true);
  assert.equal(result.note.body, "Private A");
});

test("denies cross-user note reads without leaking existence", () => {
  const store = new NotesStore();
  const created = store.createNote("user-a", "A1", "Private A");

  const result = store.getNote("user-b", created.note.id);

  assert.deepEqual(result, { ok: false, error: "Note not found" });
});

test("rejects empty title input", () => {
  const store = new NotesStore();

  assert.throws(
    () => store.createNote("user-a", "   ", "Private A"),
    /Title is required/
  );
});

test("reports storage failure without creating a note", () => {
  const store = new NotesStore({ failWrites: true });

  const result = store.createNote("user-a", "A1", "Private A");

  assert.deepEqual(result, { ok: false, error: "Could not save note" });
  assert.equal(store.listNotes("user-a").length, 0);
});

for (const { name, fn } of tests) {
  try {
    fn();
  } catch (error) {
    console.error(`failed: ${name}`);
    throw error;
  }
}

console.log(`output: ${tests.length} passed`);

