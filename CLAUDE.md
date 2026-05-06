# [项目名] — PACT 工作空间
> Product-Aware Contract Toolkit v1.9.0

---

## 1. 启动序列

> 入口职责：`AGENTS.md` 是跨工具 agent 入口；`CLAUDE.md` 是 Claude Code 热层入口。
> 若二者在流程事实上不一致，以 `.pact/core/workflow.md` 为准。
> 若二者在硬约束上不一致，以 `.pact/core/constitution.md` 为准。

每次新会话，按以下顺序执行，不跳过：

```
Step 0  初始化检测：
          读取 constitution.md 产品名称字段
          若名称字段 = "[由 /pact.init 填写]"：
            输出 "⚠️ 项目尚未初始化，请先执行 /pact.init"
            停止，不执行后续步骤，不响应功能命令

Step 1  读取 state.md，获取当前功能名和阶段

Step 2  文件存在性校验（根据阶段）：
          阶段 = pid                      → 检查 .pact/specs/[功能名]-pid.md 是否存在
          阶段 = contract / build / build-complete → 检查 .pact/contracts/[功能名].md 是否存在
          阶段 = verify-pass              → 检查 .pact/knowledge/[功能名]-verify.md 是否存在
                                            且内容包含 "verdict = PASS" 或 "MANUAL OVERRIDE"
        校验失败：输出 "⚠️ 状态不一致：state.md 声明 [阶段] 但对应文件缺失或不匹配"
                  等待人工修正，不继续执行任何命令

Step 3  校验通过后输出：当前任务理解（一句话）+ 发现的约束冲突风险

Step 4  等待人工确认后再执行
```

> **⚠️ Session Memory 说明**
> Claude Code 在后台维护自身的 session_memory（持久化会话摘要）。
> 当 session_memory 与 state.md 内容冲突时，**以 state.md 为准**。
> state.md 是 PACT 的唯一状态事实来源，任何时候有疑问都重新读取该文件。

---

## 2. 执行模式

```
每个功能：/pact.pid → /pact.contract → /pact.build → /pact.verify → /pact.ship
每 3-5 个功能：/pact.retro
```

> 流程定义源见 `.pact/core/workflow.md`。本文件只保留热层摘要，避免多处定义漂移。

---

## 3. 命令清单

| 命令 | 触发时机 | 协议详见 |
|------|---------|---------|
| `/pact.init` | 项目开始（一次性） | pact.init.md |
| `/pact.scope` | 首次功能前建议执行；风险边界或产品方向变化时重新执行 | pact.scope.md |
| `/pact.pid` | 每个功能开始 | pact.pid.md |
| `/pact.contract` | pid 完成后 | pact.contract.md |
| `/pact.build` | contract 完成后 | pact.build.md |
| `/pact.verify` | build 完成后 | pact.verify.md |
| `/pact.ship` | verify PASS 后 | pact.ship.md |
| `/pact.retro` | 每 3-5 个功能 | pact.retro.md |

---

## 4. 文件读取装配规则

> 控制 context 加载边界。非列表内的文件不主动读取。
> **本节是各命令文件读取的唯一来源。命令文件内部不再重复声明，避免双写漂移。**

**常驻层**（每次会话启动必读）
```
CLAUDE.md              — 当前文件
.pact/state.md         — 当前进度与阻塞
```

**命令触发层**（进入对应命令时读取）
```
/pact.init      → .pact/templates/PAD.md
/pact.scope     → .pact/scope/boundaries.md
                  .pact/core/constitution.md
/pact.pid       → .pact/scope/boundaries.md
                  若 specs/FDG.md 已存在 → .pact/specs/FDG.md
/pact.contract  → .pact/templates/contract.md
                  .pact/specs/[当前功能]-pid.md
                  .pact/specs/PAD.md（若存在）
/pact.build     → .pact/core/constitution.md
                  .pact/contracts/[当前功能].md
                  .pact/specs/[当前功能]-pid.md
                  .pact/specs/PAD.md（若存在）
                  .pact/contracts/archive/（跨功能一致性扫描用）
/pact.verify    → .pact/contracts/[当前功能].md
/pact.ship      → .pact/core/constitution.md
/pact.retro     → .pact/specs/PAD.md
                  .pact/specs/FDG.md（若存在）
                  .pact/knowledge/tech-debt.md
                  .pact/contracts/archive/（所有已完成契约）
```

**按需层**（有明确需要时才读，不默认加载）
```
.pact/core/architecture.md       — 涉及新模块或新依赖时
.pact/core/workflow.md           — 需要核对完整流程、阶段输入输出或停止条件时
.pact/knowledge/decisions/       — 遇到历史决策冲突时
.pact/knowledge/errors/          — 调查重复失败模式时
.pact/exec-plans/active/         — 跨会话大功能时
.pact/templates/IFD.md           — 前端交互功能的 pid 阶段
```

---

## 5. 硬约束

> 完整约束见 `.pact/core/constitution.md`

[由 /pact.init Step 2 填写]

---

## 6. 开源维护规则

若当前项目采用 PACT release layer 维护版本与发布记录，遵守以下规则：

- 本地规划、未验证路线、长期构想默认写入 `*.local.md`，不进入公开发布内容。
- 公开路线使用 Issues / Milestones 表达，不用提前承诺式 roadmap 文档。
- `VERSION` 是唯一可编辑版本真相源。
- `pact-check.sh` 必须保持 file-only，不依赖 git、GitHub、网络或 `gh`。
- git-aware 发布检查只能放在可选脚本中，例如 `pact-release-check.sh`。
- 版本发布前必须检查 VERSION、README、README.zh、CLAUDE.md、版本历史、CHANGELOG.md 一致。
- 每次发布必须更新 `CHANGELOG.md`，README 版本历史只保留摘要。
- `CHANGELOG.md` 采用 Keep a Changelog 风格：版本倒序、`## vX.Y.Z — YYYY-MM-DD`、只写有内容的 `Added / Changed / Deprecated / Removed / Fixed / Security` 分类。
- changelog 条目必须描述用户或维护者可感知的变化，不倾倒 commit log，不记录无意义的内部执行步骤。
- 不足以形成独立发布价值的修改，可以暂留本地或普通提交中积累；达到明确发布价值后再统一更新版本号。
- `PATCH` 用于不新增完整能力的修整或补强：文档修正、版本同步、职责收窄、模板一致性、已有检查规则微调。
- `MINOR` 用于可独立说明的新能力：新增脚本、命令、检查体系、模板族或完整可选子协议。
- `MAJOR` 用于状态机、目录结构、命令协议等不兼容变更。
- 创建 tag、GitHub Release、推送公开发布动作前，必须等待维护者明确确认。

---

## 7. 框架边界（不覆盖）

- 代码性能质量（高并发、慢查询）
- 安全漏洞（鉴权遗漏、注入攻击）
- 生产部署、监控、告警
- 事务一致性和并发竞态
