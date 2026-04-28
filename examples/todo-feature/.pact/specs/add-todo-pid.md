# PID Card — add-todo
版本：v1.0 | 状态：定稿 | 日期：2026-04-28

## 谁在使用？

Todo app user.

## 他要做什么？

Create a new todo item with non-empty text.

## 成功标准（正常路径）

- User enters todo text and submits.
- System creates a new todo item.
- The new item appears in the todo list.
- The input is cleared after successful creation.

## 失败场景（边界与异常）

| 场景 | 触发条件 | 用户看到 |
|------|---------|---------|
| Empty input | Input is empty or whitespace only | Validation message: `Todo text is required` |
| Long input | Input exceeds 120 characters | Validation message: `Todo text is too long` |
| Storage failure | Save operation fails | Error message: `Could not save todo` |

## 明确不做

- Do not implement edit todo.
- Do not implement delete todo.
- Do not add user accounts or sync.

## 功能关系

- 依赖：无
- 影响：edit-todo, delete-todo
- 共享契约：无

## 边界检测结果

状态：通过
触碰特征：无
人工决策：无

