# 使用 PACT

PACT 是一层面向 AI 辅助软件开发的协议，不替代编辑器、agent、测试、git、部署流水线或产品判断。

它的作用是让功能开发保持显式：

```text
意图 -> 契约 -> 实现 -> 验证 -> 发布归档
```

English: [USAGE.md](./USAGE.md)

---

## 1. 选择适配方式

PACT 的协议层不绑定具体工具，但不同 AI 工具读取项目规则的方式不同。

| 工具 | 推荐适配方式 | 支持程度 |
|------|-------------|---------|
| Claude Code | `.claude/commands/*.md` slash commands | 一等支持 |
| Codex | `AGENTS.md` + `.pact/` 脚本和模板 | 兼容 |
| Cursor | `.cursor/rules/pact.mdc` + `.pact/` 脚本和模板 | 兼容 |

详细说明：
- [Claude Code 适配](./docs/adapters/claude-code.md)
- [Codex 适配](./docs/adapters/codex.md)
- [Cursor 适配](./docs/adapters/cursor.md)

---

## 2. 安装到项目

把 PACT 框架文件复制到目标项目根目录：

```bash
cp -r CLAUDE.md .claude .pact AGENTS.md .cursor your-project/
```

最小通用集合：

```text
.pact/
AGENTS.md
```

Claude Code 一等支持集合：

```text
CLAUDE.md
.claude/commands/
.pact/
```

Cursor 集合：

```text
.cursor/rules/pact.mdc
.pact/
AGENTS.md
```

---

## 3. 初始化项目

在 Claude Code 中：

```text
/pact.init
/pact.scope
```

在 Codex 或 Cursor 中，用自然语言要求 agent 执行相同阶段：

```text
请按 PACT 初始化当前项目，创建或更新 constitution、PAD 和 state。
然后在第一个功能开始前执行 PACT scope 适用性评估。
```

结果：
- `/pact.init` 建立项目级事实：constitution、PAD 初稿、state。
- `/pact.scope` 判断 PACT 是否适合当前项目，并识别风险边界。
- scope 建议在第一个功能前执行，但它不是状态机阶段。

---

## 4. 开发一个功能

一个功能按主流程推进：

```text
/pact.pid
/pact.contract
/pact.build
/pact.verify
/pact.ship
```

如果工具不支持 slash commands，使用自然语言等价指令：

```text
为 [功能名] 创建 PACT PID Card。
根据 PID Card 生成行为契约。
按契约实现功能。
用真实命令输出验证功能。
PASS 后发布归档该功能。
```

预期产物：

| 阶段 | 产物 |
|------|------|
| `pid` | `.pact/specs/[功能名]-pid.md` |
| `contract` | `.pact/contracts/[功能名].md` |
| `build` | 代码变更 + `state.md` 进入 `build-complete` |
| `verify` | `.pact/knowledge/[功能名]-verify.md` |
| `ship` | 归档 contract + 更新 state |

---

## 5. 什么时候暂停

PACT 在以下情况应该暂停，而不是继续猜：

- 命中高风险边界
- 缺少 PID Card、contract 或 verify 记录
- contract lint 或 verify lint 失败
- verify 为 `FAIL` 或 `INCONCLUSIVE`
- 需要人工验收
- 大功能需要执行计划

暂停是决策点，不是要绕过的错误。

---

## 6. 日常维护

每完成 3-5 个功能，执行：

```text
/pact.retro
```

在 Codex 或 Cursor 中：

```text
请按 PACT 对最近 3-5 个已发布功能做 retro。
检查意图漂移、契约质量、验证质量和活跃技术债。
```

发布或共享框架变更前：

```bash
bash .pact/bin/pact-check.sh
```

如果项目使用 git：

```bash
bash .pact/bin/pact-release-check.sh
```

---

## 7. 发布纪律

PACT 不要求每次文档或规则编辑都更新版本。

只有具备明确发布价值的一组变更才发版：
- `PATCH`：已有行为、文档、模板或检查的修整
- `MINOR`：完整新能力
- `MAJOR`：不兼容协议或状态机变化

发布说明来自 `CHANGELOG.md`。

