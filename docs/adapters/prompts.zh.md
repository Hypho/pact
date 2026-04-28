# Codex、Cursor 与其他 Agent 的 PACT Prompt 模板

当工具不支持 Claude Code `/pact.*` slash commands 时，使用这些 prompt。

默认项目中已经包含：

```text
.pact/
AGENTS.md
```

Cursor 还应包含：

```text
.cursor/rules/pact.mdc
```

---

## 初始化

```text
请按 PACT 初始化当前项目。

先读取 AGENTS.md 和 .pact/state.md。
创建或更新：
- .pact/core/constitution.md
- .pact/specs/PAD.md
- .pact/state.md

不要开始实现功能。
初始化后，请总结还需要人工确认的产品事实。
```

---

## Scope 适用性评估

```text
请对当前项目执行 PACT scope 适用性评估。

读取：
- .pact/core/constitution.md
- .pact/scope/boundaries.md

写入或更新：
- .pact/scope/fitness.md

输出三种结论之一：
- PACT-only
- PACT + specialist review
- Do not use PACT alone

如果信息不足，相关边界标记为 Unknown，不要推断为 No。
除非我明确提供 3 个以上已知功能并要求做依赖规划，否则不要生成 FDG。
```

---

## PID

```text
请为功能「[功能名]」创建 PACT PID Card。

写入前：
- 读取 .pact/state.md
- 运行或等价执行：bash .pact/bin/pact.sh guard pid
- 检查 .pact/scope/boundaries.md
- 仅当 .pact/specs/FDG.md 存在时读取它

写入：
- .pact/specs/[功能名]-pid.md

更新：
- .pact/state.md 阶段为 pid
- 当前功能名必须与生成文件路径中的名称完全一致

如果命中高风险边界，停止并要求人工决策。
```

---

## Contract

```text
请为当前功能生成 PACT 行为契约。

写入前：
- 读取 .pact/state.md
- 运行或等价执行：bash .pact/bin/pact.sh guard contract
- 读取 .pact/specs/[当前功能]-pid.md
- 如果 .pact/specs/PAD.md 存在，则读取它

写入：
- .pact/contracts/[当前功能].md

契约必须包含：
- FC 条目
- 必要的 NF 条目
- 明确不做范围

不要保留模板占位符。
更新 .pact/state.md 阶段为 contract。
```

---

## Build

```text
请按 PACT contract 实现当前功能。

实现前：
- 读取 .pact/state.md
- 运行或等价执行：bash .pact/bin/pact.sh guard build
- 读取 .pact/contracts/[当前功能].md
- 读取 .pact/specs/[当前功能]-pid.md
- 读取 .pact/core/constitution.md

先输出组件计划并等待确认。
然后逐组件实现。
每个组件完成后检查：
- 技术约束
- PAD 一致性
- contract 覆盖
- 运行时边界风险

完成后更新 .pact/state.md 阶段为 build-complete。
```

---

## Verify

```text
请按 PACT 验证当前功能。

验证前：
- 读取 .pact/state.md
- 运行或等价执行：bash .pact/bin/pact.sh guard verify
- 读取 .pact/contracts/[当前功能].md

针对每条 FC：
- 构造边界输入
- 运行真实命令或测试
- 记录真实输出

写入：
- .pact/knowledge/[当前功能]-verify.md

verify 文件必须且只能包含一个：
- verdict = PASS
- verdict = FAIL
- verdict = INCONCLUSIVE

PASS 必须包含 command/output/result 等运行证据标记。
不要用推测性语言替代证据。
```

---

## Ship

```text
请发布归档当前 PACT 功能。

发布前：
- 读取 .pact/state.md
- 运行或等价执行：bash .pact/bin/pact.sh guard ship
- 读取 .pact/knowledge/[当前功能]-verify.md
- 确认其中包含 verdict = PASS 或 MANUAL OVERRIDE

运行相关测试。
如果存在自动化未覆盖的契约项，要求人工验收。

然后：
- 将 .pact/contracts/[当前功能].md 移至 .pact/contracts/archive/[当前功能].md
- 更新 .pact/state.md 已完成表
- 清空当前功能或切换到下一个队列功能

如果 verify 是 FAIL 或 INCONCLUSIVE 且没有人工 override，不要 ship。
```

---

## Retro

```text
请对最近 3-5 个已发布功能执行 PACT retro。

读取：
- .pact/specs/PAD.md
- .pact/scope/fitness.md
- .pact/knowledge/tech-debt.md
- .pact/contracts/archive/

评估：
- 产品意图漂移
- PID 清晰度
- contract 质量
- verify 质量
- 活跃技术债
- 是否需要重新执行 /pact.scope

写入：
- .pact/knowledge/decisions/[YYYY-MM-DD]-retro.md
```
