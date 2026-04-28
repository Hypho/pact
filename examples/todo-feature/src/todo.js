export function createTodoStore(options = {}) {
  const todos = [];
  const maxLength = options.maxLength ?? 120;
  const failSave = options.failSave ?? false;

  return {
    addTodo(text) {
      const value = String(text ?? "");

      if (value.trim().length === 0) {
        return {
          ok: false,
          error: "Todo text is required",
          input: value
        };
      }

      if (value.length > maxLength) {
        return {
          ok: false,
          error: "Todo text is too long",
          input: value
        };
      }

      if (failSave) {
        return {
          ok: false,
          error: "Could not save todo",
          input: value
        };
      }

      const todo = {
        id: `todo-${todos.length + 1}`,
        text: value
      };
      todos.push(todo);

      return {
        ok: true,
        todo,
        todos: [...todos],
        input: ""
      };
    },

    listTodos() {
      return [...todos];
    }
  };
}

