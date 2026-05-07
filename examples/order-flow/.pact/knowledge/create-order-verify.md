# Verify 记录 — create-order
关联 Contract：create-order.md | 日期：2026-05-07

## 对抗测试结果

| 条目 | 构造的边界输入 | 实际命令输出（前 30 行） | 是否成立 |
|------|----------------|--------------------------|---------|
| FC-01 | customerName=`Ada`, items=`Book` | `output: created order id=order-1` | ✓ |
| FC-02 | after create | `output: status="created"` | ✓ |
| FC-03 | after create | `output: destination="order-detail"` | ✓ |
| FC-04 | customerName=` ` | `output: error "Customer name is required" destination="order-form"` | ✓ |
| FC-05 | items=`[]` | `output: error "At least one item is required" destination="order-form"` | ✓ |
| NF-01 | store.save=false | `output: error "Could not save order" destination="order-form"` | ✓ |

## 产品流证据

flow-required: yes
flow-step: S1
user-path: order-form -> submit valid order -> order-detail
状态变化: order draft -> created
成功后去向: order-detail

## 设计附件证据

sequence-evidence: valid input returns created order after save; validation failure leaves store.records length at 0
interaction-evidence: success destination is `order-detail`; validation and save failures return `order-form`
design-evidence: not applicable

## 测试报告

```
command: node test/create-order.test.js
output: 5 passed

result: PASS
```

## Verdict

verdict = PASS
