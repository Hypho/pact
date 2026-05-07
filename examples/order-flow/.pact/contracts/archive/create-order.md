# 行为契约 — create-order
版本：v1.0 | 关联 PID：.pact/specs/create-order-pid.md | 日期：2026-05-07

## 主流程约束
- flow-step: S1
- 功能类型：主流程
- 用户路径：打开订单创建表单 -> 提交有效订单 -> 进入订单详情页
- 状态变化：order:draft -> order:created
- 成功后去向：订单详情页

## 功能契约（FC）

### 正常路径（关键路径，必须测试）
FC-01：当用户提交有效客户名和至少一个商品时，系统创建一条 order。
FC-02：当 order 创建成功时，系统将 order 状态写为 `created`。
FC-03：当 order 创建成功时，系统返回成功后去向 `order-detail`。

### 边界与异常（关键路径，必须测试）
FC-04：当 customerName 为空或仅包含空白时，系统拒绝创建并返回 `Customer name is required`，用户留在 `order-form`。
FC-05：当 items 为空时，系统拒绝创建并返回 `At least one item is required`，用户留在 `order-form`。

## 非功能契约（NF）

### 可自动化测试
NF-01：当保存失败时，系统返回 `Could not save order`，用户留在 `order-form`。

## 架构约束
- order 写入只能通过 `src/orders.js` 的 `createOrder`。
- 本功能不引入支付、库存或跨模块事务。
- 本功能不需要 ADR。

## 设计附件约束
- sequence：有效输入先校验，再调用 store.save，成功后返回 `order-detail`。
- sequence：校验失败不调用 store.save。
- interaction：校验失败和保存失败都留在 `order-form`。
- interaction：保存成功进入 `order-detail`。

## 测试覆盖范围
自动化：FC-01 ~ FC-05，NF-01
人工验收：无

## 明确不做
- 不处理支付。
- 不处理订单确认。
- 不处理库存扣减。
