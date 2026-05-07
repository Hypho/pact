# Interaction Brief — create-order

## 触发原因
创建订单表单需要明确成功去向、校验错误和保存失败时的 UI 状态。

## 页面 / 区域
- Order create form

## 用户路径
1. 用户进入订单创建表单。
2. 用户填写客户名和商品。
3. 用户提交表单。
4. 成功后进入订单详情。
5. 失败时留在表单并看到可操作错误。

## UI 状态
| 状态 | 触发 | UI 表现 | 验收方式 |
|------|------|---------|----------|
| editing | 用户填写中 | 表单可编辑 | 自动化 |
| success | 保存成功 | destination=`order-detail` | 自动化 |
| validation-error | 必填缺失 | destination=`order-form` 且显示字段错误 | 自动化 |
| save-error | store.save=false | destination=`order-form` 且显示保存失败 | 自动化 |

## 表单 / 输入规则
- customerName：必填，提交时 trim。
- items：至少 1 项。

## 反馈规则
- 成功：进入 `order-detail`。
- 校验失败：返回具体字段错误，留在 `order-form`。
- 系统失败：显示 `Could not save order`，留在 `order-form`。

## 可访问性 / 响应式要求
- 本示例不覆盖。

## 验收映射
- FC 候选：保存成功进入 `order-detail`。
- FC 候选：校验失败留在 `order-form`。
- NF 候选：保存失败留在 `order-form` 并显示错误。
- 人工验收：无

## 明确不做
- 不处理移动端布局。
