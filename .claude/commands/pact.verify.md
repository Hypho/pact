# /pact.verify — 对抗验证

> 目标：主动尝试打破当前实现。verdict 必须基于真实命令输出，禁止推理性断言。

> 文件读取见 CLAUDE.md § 4。

---

## Step 1  列出 FC 关键路径

读取 contract，逐条列出所有 FC 关键路径条目。

## Step 2  边界输入测试

针对每条 FC 构造边界输入，实际运行，截取命令输出写入 verify.md。

输出规范（防 context 膨胀）：
- 每条 FC 截取前 30 行，超出部分标注 `[...截断，完整输出见终端]`

## Step 3  运行测试套件

> 目的：为 FC verdict 提供基线佐证，确认对抗测试暴露的问题不是已知用例的回归。
> 与 /pact.ship Step 2 的区别：这里只跑 L1+L2，服务于 verdict；ship 跑完整 L1+L2+L3，服务于发布回归。

运行 L1 + L2，将测试报告摘要写入 verify.md：
- 通过用例 → 只记录计数，例如 `L1: 23 passed`
- 失败用例 → 保留完整输出

单个 verify.md 建议控制在 200 行以内。

## Step 4  输出 verdict

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
  constitution.md 已完成功能表 Verify 列标注 "manual"

**[C] 暂停当前功能**
→ state.md 阻塞字段填写原因，功能保留在队列，不推进

---

> code-review Skill 为可选补充，在 PASS 后按需触发，不是主验证手段。
> 安装：`claude plugin install code-review`（见 constitution.md Skills 注册区）
