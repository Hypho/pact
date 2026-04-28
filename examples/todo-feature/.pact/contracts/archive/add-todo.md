# 行为契约 — add-todo
版本：v1.0 | 关联 PID：.pact/specs/add-todo-pid.md | 日期：2026-04-28

## 功能契约（FC）

### 正常路径（关键路径，必须测试）

FC-01：当用户提交非空 todo text 时，系统创建一条新的 todo item。
FC-02：当 todo item 创建成功时，系统在列表中显示该 item。
FC-03：当 todo item 创建成功时，系统清空输入框。

### 边界与异常（关键路径，必须测试）

FC-04：当用户提交空字符串或纯空白字符时，系统拒绝创建并显示 `Todo text is required`。
FC-05：当用户提交超过 120 个字符的 text 时，系统拒绝创建并显示 `Todo text is too long`。

## 非功能契约（NF）

### 可自动化测试

NF-01：当保存失败时，系统显示 `Could not save todo`，并保留用户输入。

## 测试覆盖范围

自动化：FC-01 ~ FC-05, NF-01
人工验收：无

## 明确不做

- Do not implement edit todo.
- Do not implement delete todo.
- Do not add user accounts or sync.

