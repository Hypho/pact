# Adopt Global Spine Lite in an Existing PACT Project

This guide helps a project created before Global Spine Lite adopt the new fields without changing the daily feature loop.

## 1. Update PAD

Open:

```text
.pact/specs/PAD.md
```

Add or complete these sections:

```text
## 产品目标
## 目标用户与核心场景
## 核心业务主流程
## 功能类型定义
## 体验一致性规则
```

Keep the first version small. One core flow is enough.

Example flow table:

```markdown
| Step | 用户目标 | 用户动作 | 系统状态变化 | 对应功能 | 必须体验 |
|------|----------|----------|--------------|----------|----------|
| S1 | 创建订单 | 提交表单 | order:draft -> order:created | create-order | 进入订单详情 |
```

Run:

```bash
bash .pact/bin/pact.sh lint-pad .pact/specs/PAD.md
```

## 2. Update architecture.md

Open:

```text
.pact/core/architecture.md
```

Add or complete:

```text
## 架构原则
## 模块边界
## 核心实体归属
## 状态机归属
## 权限判断位置
## 数据写入边界
## 依赖方向
## ADR 触发条件
```

Run:

```bash
bash .pact/bin/pact.sh lint-architecture .pact/core/architecture.md
```

## 3. Update Active PID Cards Only When Needed

Do not rewrite every archived PID Card.

For active or new feature work, include:

```text
## 主流程映射
## 架构影响
```

Run:

```bash
bash .pact/bin/pact.sh lint-pid --all
```

## 4. Keep The Existing Loop

Do not add a new regular step. Continue using:

```text
pid -> contract -> build -> verify -> ship
```

The only difference is that PID and build now read the Product Spine and Architecture Spine when relevant.

## 5. Use Retro To Find Drift

During `/pact.retro`, check:

- Are shipped features mapped to the core business flow?
- Are too many features auxiliary while the main path remains incomplete?
- Did any feature bypass module boundaries?
- Should any architecture decision be recorded?

## 6. Do Not Split Files Prematurely

Keep PAD and `architecture.md` as the two global spine files until they are genuinely too large or hard to maintain.

Do not create `.pact/product/`, `.pact/architecture/`, or JSON indexes unless the project has a real maintenance problem that requires them.
