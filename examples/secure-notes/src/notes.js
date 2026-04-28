class NotesStore {
  constructor(options = {}) {
    this.notes = [];
    this.nextId = 1;
    this.failWrites = Boolean(options.failWrites);
  }

  createNote(userId, title, body) {
    const normalizedUserId = normalizeRequired(userId, "User is required");
    const normalizedTitle = normalizeRequired(title, "Title is required");
    const normalizedBody = normalizeRequired(body, "Body is required");

    if (this.failWrites) {
      return { ok: false, error: "Could not save note" };
    }

    const note = {
      id: `note-${this.nextId++}`,
      ownerId: normalizedUserId,
      title: normalizedTitle,
      body: normalizedBody
    };
    this.notes.push(note);
    return { ok: true, note: { ...note } };
  }

  listNotes(userId) {
    const normalizedUserId = normalizeRequired(userId, "User is required");
    return this.notes
      .filter((note) => note.ownerId === normalizedUserId)
      .map((note) => ({ ...note }));
  }

  getNote(userId, noteId) {
    const normalizedUserId = normalizeRequired(userId, "User is required");
    const normalizedNoteId = normalizeRequired(noteId, "Note id is required");
    const note = this.notes.find((candidate) => candidate.id === normalizedNoteId);

    if (!note || note.ownerId !== normalizedUserId) {
      return { ok: false, error: "Note not found" };
    }

    return { ok: true, note: { ...note } };
  }
}

function normalizeRequired(value, message) {
  if (typeof value !== "string" || value.trim() === "") {
    throw new Error(message);
  }
  return value.trim();
}

module.exports = { NotesStore };

