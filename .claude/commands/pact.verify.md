# /pact.verify — 对抗验证

> 目标：主动尝试打破当前实现。verdict 必须基于真实命令输出，禁止推理性断言。

> 文件读取见 CLAUDE.md § 4。

---

## Step 0  意图覆盖率检查

若 `.pact/specs/intent.md` 存在：
- 读取意图记录的"关键环节"表
- 对照当前 Contract 的 FC 条目，检查：
  - 意图记录中标记为"必须"的环节，是否在 Contract 中有对应 FC
  - 若有遗漏，输出：`⚠️ 意图覆盖缺口：[R2] 无对应 FC`
- 等待人工确认：补充FC / 确认不在本功能范围 / 标记为下个功能

无意图记录时跳过本步。

## Step 1  列出 FC 关键路径

进入前先运行：

```bash
bash .pact/bin/pact-guard.sh verify
```

guard 失败则停止，不继续 verify。

读取 contract，逐条列出所有 FC 关键路径条目。

## Step 2  边界输入测试

针对每条 FC 构造边界输入，实际运行，截取命令输出写入 verify.md。

输出规范（防 context 膨胀）：
- 每条 FC 截取前 30 行，超出部分标注 `[...截断，完整输出见终端]`

## Step 3  产品流与状态证据

若 contract 或 PID 声明了 PAD 业务主流程 Step、状态变化、成功后用户去向或体验一致性规则，verify.md 必须记录对应证据：

```text
flow-step: [Sx / 辅助 / 管理 / 实验]
user-path: [上游动作 -> 当前动作 -> 下游动作]
状态变化: [运行结果或测试输出]
成功后去向: [运行结果或测试输出]
```

无法自动化验证时，标注为人工验收项，不得用“应该 / 预期 / 理论上”替代真实输出或人工验收记录。

## Step 4  设计附件证据

若 PID / contract 引用了设计附件，verify.md 必须记录对应证据或人工验收项：

```text
design-evidence: [design brief 中方案边界 / 验收映射的真实输出或验收记录]
sequence-evidence: [sequence 中关键调用顺序 / 状态变化的真实输出或验收记录]
interaction-evidence: [interaction 中 UI 状态 / 反馈规则的真实输出或验收记录]
```

不适用的附件类型可写 `not applicable`，但不能省略已声明附件的验证说明。

## Step 5  运行测试套件

> 目的：为 FC verdict 提供基线佐证，确认对抗测试暴露的问题不是已知用例的回归。
> 与 /pact.ship Step 2 的区别：这里只跑 L1+L2，服务于 verdict；ship 跑完整 L1+L2+L3，服务于发布回归。

运行 L1 + L2，将测试报告摘要写入 verify.md：
- 通过用例 → 只记录计数，例如 `L1: 23 passed`
- 失败用例 → 保留完整输出

单个 verify.md 建议控制在 200 行以内。

## Step 6  输出 verdict

verdict 行格式严格写为（启动校验依赖此精确格式，不得改写为 Markdown 标题或其他格式）：

```
verdict = PASS
verdict = FAIL
verdict = INCONCLUSIVE
```

- **PASS** — 所有 FC 在真实运行下成立 → 更新 state.md 阶段为 `verify-pass` → 进入 /pact.ship
- **FAIL** — 列出哪条 FC 在什么条件下被打破 → 回退 /pact.build
- **INCONCLUSIVE** — 无法在当前环境实际运行（列明具体原因）→ 见下方处置协议

保存路径：`.pact/knowledge/[功能名]-verify.md`

> 禁止在 verdict 中使用"应该""预期""理论上"等推理语言。

---

## INCONCLUSIVE 处置协议

列明无法运行的具体原因，然后等待人工从以下三个选项中选择：

**[A] 补充环境后重新 verify**
→ 解决 INCONCLUSIVE 列明的环境问题，重新执行 /pact.verify

**[B] 人工签字确认，强制推进**
→ 开发者在 verify.md 末尾手动追加：
  `MANUAL OVERRIDE — [日期] — [签字人] — [确认理由]`
  追加后 state.md 阶段更新至 verify-pass，流程继续
  state.md 已完成表 Verify 列标注 "manual"；ship 阶段同步写入 constitution.md 已完成功能表。

**[C] 暂停当前功能**
→ state.md 阻塞字段填写原因，功能保留在队列，不推进

---

> code-review Skill 为可选补充，在 PASS 后按需触发，不是主验证手段。
> 未安装或不可用时，记录说明后跳过，不阻断主流程。
