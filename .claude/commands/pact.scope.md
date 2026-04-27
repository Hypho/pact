# /pact.scope — PACT 适用性与风险边界评估

> 目标：判断当前项目是否适合用 PACT 推进，并识别需要人工或专项审查的风险边界。
> 文件读取见 CLAUDE.md § 4。

---

## 适用时机

- 首次功能开发前建议执行。
- 产品方向、技术栈或风险边界发生变化时重新执行。
- 已知功能明显增加，且需要判断是否存在跨功能风险时重新执行。

> `/pact.scope` 不是项目规划器，也不是任务管理器。FDG 是可选规划附件，不是 scope 的核心产物。

---

## Step 1  读取基础信息

读取：
- `.pact/core/constitution.md`（产品概要、技术栈、硬约束）
- `.pact/scope/boundaries.md`（风险边界清单）

如 `constitution.md` 仍包含初始化占位符，输出：

```text
⚠️ 项目尚未完成初始化信息，scope 结果只能作为临时判断。
```

继续评估，但必须标注信息不足。

---

## Step 2  项目级风险边界评估

对照 `boundaries.md` 判断当前项目可能暴露的风险：

- 高风险边界（B-H）
- 中风险边界（B-M）
- PACT 明确不覆盖的盲区

输出表格：

```markdown
| ID | Level | Applies? | Reason | Required action |
|----|-------|----------|--------|-----------------|
| B-H02 | High | Yes/No/Unknown | [理由] | [继续/专项审查/拆分/信息不足] |
```

判断规则：
- 信息不足时写 `Unknown`，不能推断为 `No`。
- 触及高风险边界时，不能输出 `PACT-only`。
- 中风险边界必须说明 contract 阶段需要明确的处理方式。

---

## Step 3  输出适配结论

三选一：

```text
PACT-only
PACT + specialist review
Do not use PACT alone
```

### PACT-only

适用条件：
- 未发现高风险边界。
- 中风险边界较少，且可在 contract 中明确。
- 不依赖 PACT 明确不覆盖的能力。

### PACT + specialist review

适用条件：
- 存在中风险边界。
- 存在局部高风险边界，但可以隔离、拆分或引入专项审查。
- 需要安全、性能、DBA、法务、合规等外部输入。

### Do not use PACT alone

适用条件：
- 核心路径依赖金融操作、高并发一致性、敏感数据、实时通信、跨用户聚合或安全关键权限。
- PACT 只能作为辅助协议，不能作为主要保障机制。

---

## Step 4  写入 `.pact/scope/fitness.md`

输出结构：

```markdown
# PACT Scope Assessment
> 由 /pact.scope 生成。最后更新：[日期]

## Verdict
[PACT-only / PACT + specialist review / Do not use PACT alone]

## Risk Boundaries
| ID | Level | Applies? | Reason | Required action |
|----|-------|----------|--------|-----------------|

## Blind Spots

## Recommended Usage Mode

## Optional Planning Artifacts
- FDG: [Not needed / Suggested / Generated]
```

---

## Step 5  可选规划附件：FDG

仅当开发者明确提供 3+ 个已知功能，并且希望分析依赖时，才建议生成或更新 `.pact/specs/FDG.md`。

输出：

```text
📋 可选规划附件：检测到 3+ 个已知功能。
是否需要生成 FDG（功能依赖图）？
[A] 生成 FDG
[B] 暂不生成，仅保留 scope 评估
```

未得到明确选择时，不生成 FDG。

> FDG 是 optional planning artifact，不是 `/pact.scope` 成功完成的必要条件。

---

## 完成输出

```text
✅ scope 完成
  适配结论：[PACT-only / PACT + specialist review / Do not use PACT alone]
  高风险边界：[N] 个
  中风险边界：[N] 个
  盲区：[N] 项
  FDG：[未生成 / 已生成 / 建议但暂未生成]
```
