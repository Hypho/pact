# PACT — Product-Aware Contract Toolkit
> 面向产品人的 AI 辅助开发框架 | v1.1.0
> English: [README.md](./README.md)

---

## 是什么

PACT 是一套运行在 Claude Code 上的开发框架，通过 Markdown 文件约束 AI 的行为边界，让产品背景的开发者能够可靠地构建软件——而不是在 AI 的自由发挥中反复救火。

核心思路：**在实现之前定义行为，用契约驱动开发，而不是用 prompt 碰运气。**

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

```bash
# 复制框架到项目根目录
cp -r pact/CLAUDE.md your-project/
cp -r pact/.claude   your-project/
cp -r pact/.pact     your-project/

# 在 Claude Code 中执行
/pact.init    # 项目初始化（一次性）
/pact.scope   # 范围适配评估（init 后必须执行）
```

---

## 执行模式

每个功能的流程：`pid → contract → build → verify → ship`

每 3-5 个功能执行一次：`retro`

---

## 命令清单

| 命令 | 触发时机 | 职责 |
|------|---------|------|
| `/pact.init` | 项目开始（一次性） | 交互式初始化，生成 constitution / PAD 初稿 / state |
| `/pact.scope` | init 后必须执行；功能增至 3+ 时可重新执行 | 范围适配评估，生成 FDG（3+ 功能时） |
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
    ├── scope/
    │   ├── boundaries.md            ← 边界特征清单（B-H / B-M 风险规则）
    │   └── fitness.md               ← 适配评估结果（/pact.scope 生成）
    ├── specs/                       ← 项目实例文件（由命令生成，非空白模板）
    │   ├── PAD.md                   ← 产品结构文档（/pact.init 生成初稿）
    │   ├── FDG.md                   ← 功能依赖图（/pact.scope 生成，3+ 功能时）
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
| **PATCH** | 不改变协议契约的修整 | 措辞/错别字；文档内部一致性修正；示例脚本修复；注释维护 |

> 每次合入主干必须更新版本号；重要里程碑打 git tag（`v1.0.0`、`v1.1.0`、`v2.0.0`）。
> 历史记录保留近 10 条于本表，更早记录移至 `CHANGELOG.md`。

---

## 版本历史

| 版本 | 日期 | 核心变更 |
|------|------|---------|
| v1.0.0 | 2026-04-20 | 首个公开版本。面向产品人的契约驱动开发框架，8 个命令协议 + 3 层上下文加载 + 风险边界检测 + 对抗验证 + Shell Hook 兜底 |
| v1.1.0 | 2026-04-20 | 时间三元组（state.md 新增开始时间字段，已完成表扩展双时间列）；check-state.sh 解析稳健化（归一化冒号、awk 替代 grep+sed）；README 增加「适用边界」段落并提供英文版本 |
