# /pact.ship — 测试、验收、归档

> 文件读取见 CLAUDE.md § 4。

---

## 入口检查

进入前先运行：

```bash
bash .pact/bin/pact-guard.sh ship
```

guard 失败则停止，不继续 ship。

`.pact/knowledge/[功能名]-verify.md` 必须存在，且包含 `verdict = PASS` 或 `MANUAL OVERRIDE` 记录。
不满足则停止，提示先执行 /pact.verify 或完成人工签字。

---

## Step 1  补全测试脚本 TODO

扫描 `.pact/tests/features/[功能名].*`，检查未填写的 TODO 项。

如有 TODO：
```
⚠️ 发现 [N] 个 TODO 未完成
[A] 帮我补全（描述每个用例的具体操作和断言）
[B] 跳过这些用例（记录为部分测试）
```

## Step 2  分级执行测试

> 目的：发布前完整回归。即使 verify 已跑过 L1+L2，此处仍需重跑——确认自 verify 以来（含修复代码后）所有测试仍通过，并补充 L3 完整 E2E + 跨功能回归。

**L1（单元，无需 dev server）→ 自动执行**
失败时：报告问题，等待决策后继续或终止。

**L2（冒烟，核心路径）→ 自动执行**
L1 失败未修复时跳过。

**L3（完整 E2E + 回归）→ 自动执行**
包含所有已完成功能的回归测试。

测试失败时：
```
🔴 测试失败：[用例名]
  预期：[契约描述]  实际：[测试输出]
⏸️ [A] 修复代码重新测试  [B] 契约有误需更新  [C] 标记为已知失败
```

回归失败时：
```
⚠️ 回归失败：[功能名] → [失败用例]
⏸️ [A] 修复  [B] 确认为预期变更（更新对应契约）
```

## Step 3  人工验收

测试全部通过后，从契约中筛出**自动化未覆盖的条目**，输出待验清单：

```
📋 需要人工验证（[N] 项）
[NF-02] 慢网络加载 → 预期：显示骨架屏 → 验证方式：DevTools 限速
[E-01] 错误提示语言 → 预期：友好明确，用户知道怎么改
```

**⏸️ 等待人工反馈后继续。**

验收失败时：
```
[A] 契约已覆盖但实现不符 → 打回 /pact.build 修复
[B] 契约未覆盖的遗漏    → 补充契约后修复
[C] 体验问题，不影响功能正确性 → 登记 tech-debt.md，继续
```

## Step 4  影响面自查

逐条检查，有"是"项则处理后再继续：

- PAD 实体定义是否变更？→ 检查已完成功能的相关契约
- 共享契约（FDG）是否受影响？→ 更新 FDG.md
- 是否有新的全局技术约束？→ 补充 constitution.md
- Schema 是否变更？→ 确认 migration 已创建
- 是否需要更新 handover 文档？→ 更新 `knowledge/handover/[模块].md`

## Step 5  归档

- 更新 constitution.md 已完成功能列表
- 将 `.pact/contracts/[功能名].md` 移至 `.pact/contracts/archive/[功能名].md`
- 将 PID Card 移至 `knowledge/archive/`
- 记录重要架构决策到 `knowledge/decisions/`
- 记录遇到的 AI 幻觉到 `knowledge/errors/`（如有）
- Git commit：`feat([功能名]): [一句话描述]` + `docs: update pact`

更新 state.md 已完成表（填写所有 6 列）：
```
| [功能名] | [开始 YYYY-MM-DD] | [完成 YYYY-MM-DD] | [N] 条 | [N/N] | PASS / manual |
```
- 开始列取自 state.md "当前"块中的开始时间（只保留日期部分）
- 完成列写入归档当日
- 同步更新 constitution.md 已完成功能表（同样 6 列），并刷新总计数

清空"当前"，填写下一个队列功能。

---

## 完成输出

```
✅ ship 完成：[功能名]
  测试：L1 ✅ L2 ✅ L3 [N/N] | 回归 [N/N]
  验收：[N/N] 通过
  影响面：[无跨功能影响 / 已处理 N 项]
  Git：[commit hash]

项目进度：已完成 [N] 个功能 | 待开发：[列出]
[如有] → 建议在完成 [N] 个功能后执行 /pact.retro
```
