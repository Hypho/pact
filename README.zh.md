# PACT — Product-Aware Contract Toolkit
> 面向人机协作开发的轻量协议框架 | v1.6.1
> English: [README.md](./README.md)

[![PACT Check](https://github.com/Hypho/pact/actions/workflows/pact-check.yml/badge.svg)](https://github.com/Hypho/pact/actions/workflows/pact-check.yml)

---

## 是什么

PACT 是一套面向 AI 辅助软件开发的轻量协议框架，用来把产品意图、实现范围和验证证据显式化。

它把开放式的 AI 对话，收束成一条可追踪的工作流：先定义意图，再写行为契约，然后按契约实现，用真实运行结果验证，最后归档变更。

PACT 适合产品型开发者、独立开发者和小团队：既希望借助 AI 提速，又不想丢掉对范围、状态和质量的控制。

它不是代码生成器，不是 agent 调度系统，也不是 CI/CD 的替代品。它更像一层协议：让人的决策和 AI 的执行始终对齐。

核心思路：**实现之前先定义行为，发布之前先验证行为。**

---

## 什么时候适合用 PACT

适合使用 PACT 的情况：

- 你正在借助 AI 开发产品，并且希望过程可追踪、可审计。
- 你希望产品意图、实现、验证和发布之间有清晰交接。
- 你是独立开发者、产品型开发者，或按功能推进的小团队。
- 你更相信明确契约和检查点，而不是依赖一段越来越长的 prompt。

不适合只靠 PACT 解决的情况：

- 你需要的是通用任务管理器或多 agent 调度系统。
- 你需要的是部署、监控、事故响应或 CI/CD 编排。
- 你正在处理高风险安全、金融、并发或性能问题，但没有专项审查。

---

## 适用边界

采用前请先判断项目是否落在 PACT 的适用范围内。

### 框架识别但不求解（强制暂停，等待外部专项处理）

- **事务一致性与并发竞态** — boundaries B-H02 / B-H05
- **金融操作与敏感数据** — boundaries B-H03 / B-H06
- **跨用户聚合 / 实时通信** — boundaries B-H01 / B-H04
- **代码性能（N+1、慢查询等）** — `/pact.build` 运行时边界扫描

> 这些场景 PACT 会主动拦住你，但不提供解决方案。需配合专项审查（安全 / 性能 / DBA）使用。
> 识别 + 暂停本身就是框架的交付物之一。

### 框架完全不涉足

- **生产部署、监控、告警**
- **多人并发开发的冲突协调**
- **CI/CD 流水线与发布管理**

> 这些场景 PACT 完全不介入，需要其他工具链协同。

---

## 快速开始

完整使用指南：[USAGE.zh.md](./USAGE.zh.md)

```bash
# 复制框架到项目根目录
cp -r pact/CLAUDE.md pact/.claude pact/.pact pact/AGENTS.md pact/.cursor your-project/

# 在 Claude Code 中执行
/pact.init    # 项目初始化（一次性）
/pact.scope   # 适用性与风险边界评估（首次功能前建议执行）

# 可选：仓库自检
bash .pact/bin/pact-check.sh

# 可选：git-aware 发布检查
bash .pact/bin/pact-release-check.sh
```

---

## 工具支持

PACT 的协议层不绑定具体工具；当前对 Claude Code 一等支持，并为 Codex 和 Cursor 提供适配文件。

| 工具 | 支持程度 | 入口 |
|------|---------|------|
| Claude Code | 一等支持 | [docs/adapters/claude-code.md](./docs/adapters/claude-code.md) |
| Codex | 兼容 | [docs/adapters/codex.md](./docs/adapters/codex.md) |
| Cursor | 兼容 | [docs/adapters/cursor.md](./docs/adapters/cursor.md) |

Claude Code plugin marketplace 安装方式可作为后续计划，不是当前主要安装路径。

---

## 执行模式

每个功能的流程：`pid → contract → build → verify → ship`

每 3-5 个功能执行一次：`retro`

---

## 命令清单

| 命令 | 触发时机 | 职责 |
|------|---------|------|
| `/pact.init` | 项目开始（一次性） | 交互式初始化，生成 constitution / PAD 初稿 / state |
| `/pact.scope` | 首次功能前建议执行；风险边界或产品方向变化时重新执行 | PACT 适用性与风险边界评估；FDG 为可选规划附件 |
| `/pact.pid` | 每个功能开始 | 定义功能意图，执行边界检测，生成 PID Card |
| `/pact.contract` | pid 完成后 | 生成行为契约（FC/NF 条目），作为 build 和 verify 的基准 |
| `/pact.build` | contract 完成后 | TDD 顺序实现功能代码（先写测试，后写实现） |
| `/pact.verify` | build 完成后 | 对抗验证：主动构造边界输入，基于真实运行结果出 verdict |
| `/pact.ship` | verify PASS 后 | 冒烟测试，登记已完成功能，归档 contract |
| `/pact.retro` | 每 3-5 个功能 | 回顾 contract 质量，清理技术债 |

---

## 目录结构

```
your-project/
├── CLAUDE.md                        ← 热层，会话启动自动加载
│                                      包含：启动序列 / 执行模式 / 命令清单 / 文件装配规则
├── .claude/
│   └── commands/                    ← 8 个命令文件（各命令协议定义）
│       ├── pact.init.md
│       ├── pact.scope.md
│       ├── pact.pid.md
│       ├── pact.contract.md
│       ├── pact.build.md
│       ├── pact.ship.md
│       ├── pact.verify.md
│       └── pact.retro.md
└── .pact/
    ├── state.md                     ← 热层，跨会话状态机
    ├── core/
    │   ├── constitution.md          ← 温层：项目宪法，硬约束 + 文件命名规范
    │   └── architecture.md          ← 冷层：按需加载
    ├── schemas/
    │   └── state.schema.json        ← 未来结构化状态源的草案 schema
    ├── scope/
    │   ├── boundaries.md            ← 边界特征清单（B-H / B-M 风险规则）
    │   └── fitness.md               ← 适配评估结果（/pact.scope 生成）
    ├── specs/                       ← 项目实例文件（由命令生成，非空白模板）
    │   ├── PAD.md                   ← 产品结构文档（/pact.init 生成初稿）
    │   ├── FDG.md                   ← 可选功能依赖图（/pact.scope，明确选择后生成）
    │   └── [功能名]-pid.md          ← 各功能 PID Card（/pact.pid 生成）
    ├── contracts/                   ← 行为契约
    │   ├── [功能名].md              ← 进行中功能的 contract
    │   └── archive/                 ← 已完成功能的 contract（/pact.ship 归档）
    ├── templates/                   ← 空白参照模板（不直接填写）
    │   ├── PAD.md / FDG.md / IFD.md
    │   ├── pid-card.md / contract.md / verify.md
    │   ├── exec-plan.md / handover.md
    │   └── README.md                ← 模板目录说明
    ├── hooks/
    │   └── check-state.sh           ← SessionStart Hook（校验 state.md 与文件系统一致性）
    ├── exec-plans/
    │   ├── active/                  ← 执行中的大功能计划
    │   └── completed/
    ├── knowledge/
    │   ├── [功能名]-verify.md       ← verify 记录（verdict + 对抗测试结果）
    │   ├── tech-debt.md             ← 技术债追踪
    │   ├── decisions/               ← 架构决策归档
    │   ├── errors/                  ← 失败记录
    │   ├── handover/
    │   └── archive/                 ← state / 已完成功能的历史归档
    └── tests/
        ├── features/
        ├── fixtures/
        └── api/
```

---

## 关键机制

### 文件命名规范
所有 contract / verify / exec-plan / pid-card 文件路径都基于 state.md 的功能名字段生成，命名规则在 constitution.md 中定义。启动校验会对比 state.md 声明的阶段与对应文件是否存在，不一致时停止执行。

### 状态源
在 v1.x 阶段，`.pact/state.md` 仍然是人类可读的状态真相源。PACT 同时提供 `.pact/schemas/state.schema.json` 草案，用于定义未来结构化 state 的形状，但它不会改变当前运行方式。

`pact-check.sh` 现在会检查 `state.md` 的基础结构，并通过 fixture 覆盖常见非法状态。

### Contract / Verify Lint
PACT 会检查行为契约和验证记录的基础结构：

- contract 必须包含 FC 条目和明确不做范围
- contract 不能保留明显模板占位符
- verify 必须包含且只包含一个严格的 `verdict = PASS|FAIL|INCONCLUSIVE` 行
- verify 禁止使用“应该 / 预期 / 理论上”等推理性语言替代真实输出
- PASS 类型 verify 必须包含 `output:` 或 `command:` 等运行证据标记

### Command Guard
PACT 提供命令入口检查，用于根据 `state.md` 和必要产物判断某个 `/pact.*` 命令是否允许开始。

```bash
bash .pact/bin/pact-guard.sh pid
bash .pact/bin/pact-guard.sh contract
bash .pact/bin/pact-guard.sh build
bash .pact/bin/pact-guard.sh verify
bash .pact/bin/pact-guard.sh ship
```

guard 不执行命令，不生成文件，不修改 state，只报告当前命令是否允许进入。

### Scope Assessment

`/pact.scope` 用来在功能开发前判断 PACT 是否适合当前项目，并识别需要人工或专项审查的风险边界。

它输出三种使用模式之一：

- `PACT-only`
- `PACT + specialist review`
- `Do not use PACT alone`

FDG 生成为可选项。只有在开发者明确提供 3 个以上已知功能，并且确实需要依赖规划时才生成。

### 边界检测
`/pact.pid` 阶段对照 boundaries.md 执行边界检测：

| 类型 | 内容 | 处置 |
|------|------|------|
| 高风险（B-H） | 实时通信 / 并发写入 / 金融操作 / 跨用户聚合 / 多表事务 / 敏感数据 | 强制暂停，等待人工决策 |
| 中风险（B-M） | 复杂权限 / 文件处理 / 第三方集成 / 异步任务 / 复杂查询 / Schema 变更 | 附加提示，可继续 |

大功能门控（跨 3+ 模块 / Schema 变更 / 需 2+ 会话 / 依赖 3+ 未完成功能）→ 强制生成执行计划，人工确认后继续。

### Verify 机制
不是审查代码，而是主动证伪。针对每条 FC 条目构造边界输入，实际运行，截取真实输出，禁止推理性语言。Verdict 三种结果：`PASS` / `FAIL`（回退 build）/ `INCONCLUSIVE`（三选项处置协议）。

---

## 版本号规则

采用语义化版本：`MAJOR.MINOR.PATCH`

| 位 | 触发条件 | 典型变更 |
|----|---------|---------|
| **MAJOR** | 协议不兼容变更，已初始化项目无法平滑升级 | 命令增删/重命名；状态机阶段调整；文件命名规范变更；目录结构重组 |
| **MINOR** | 向后兼容的协议扩展 | 新增可选 Step 或检查项；新增模板；新增非强制子协议；Hook 能力增强 |
| **PATCH** | 不新增独立能力的修整或补强 | 措辞/错别字；文档内部一致性修正；职责收窄；模板对齐；已有检查规则微调 |

> 只有具备明确发布价值的变更集合才更新版本号；小改可以先暂留本地或进入普通提交，积累到一定程度再发版。
> 重要里程碑打 git tag（`v1.0.0`、`v1.1.0`、`v2.0.0`）。
> 历史记录保留近 10 条于本表，更早记录移至 `CHANGELOG.md`。

---

## 版本历史

详细发布记录维护在 [CHANGELOG.md](./CHANGELOG.md)。
发布流程说明见 [RELEASE.md](./RELEASE.md)。

| 版本 | 日期 | 核心变更 |
|------|------|---------|
| v1.6.1 | 2026-04-27 | 将 `/pact.scope` 收窄为适用性与风险边界评估，将 FDG 改为可选规划附件，并明确低频发版原则 |
| v1.6.0 | 2026-04-27 | 新增 pid / contract / build / verify / ship 命令入口 guard，并将 guard fixtures 接入自检 |
| v1.5.0 | 2026-04-27 | 新增 contract 和 verify lint 脚本、fixtures，并接入自检，用于检查行为契约和验证记录的基础结构 |
| v1.4.0 | 2026-04-27 | 新增 VERSION 作为 file-only 版本真相源，文档化分层发布流程，并新增可选 git-aware 发布检查 |
| v1.3.3 | 2026-04-27 | 新增 CHANGELOG.md 作为正式发布历史，并在仓库自检中要求 changelog 覆盖当前版本 |
| v1.3.2 | 2026-04-27 | 新增 state schema 草案、state fixture、state.md 结构 lint、check-state fixture 覆盖，并补强 build 阶段状态校验 |
| v1.2.1 | 2026-04-26 | 优化 README 产品定位，新增 CI 状态徽章，明确适合/不适合使用 PACT 的场景，并补充仓库自检命令 |
| v1.2.0 | 2026-04-26 | 新增仓库自检脚本与 GitHub Actions 工作流，检查版本一致性、内部路线草案误公开、state 一致性；新增开源维护与发布规则 |
| v1.1.0 | 2026-04-20 | 时间三元组（state.md 新增开始时间字段，已完成表扩展双时间列）；check-state.sh 解析稳健化（归一化冒号、awk 替代 grep+sed）；README 增加「适用边界」段落并提供英文版本 |
| v1.0.0 | 2026-04-20 | 首个公开版本。面向产品人的契约驱动开发框架，8 个命令协议 + 3 层上下文加载 + 风险边界检测 + 对抗验证 + Shell Hook 兜底 |
