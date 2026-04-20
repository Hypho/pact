# constitution.md — 项目宪法
> 温层：scope / build / verify / ship 时读取。只放不变的硬约束。
> 最后更新：[日期]

---

## 1. 产品概要

```
名称：[由 /pact.init 填写]
描述：[一句话]
阶段：[原型验证 / MVP / 正式产品]
```

---

## 2. 技术栈

```
项目类型：[全栈 Web / 纯后端 TS / 纯后端 Python / Python 全栈]
前端：[框架 + 版本]
后端：[框架 + 语言 + 版本]
数据库：[类型 + 版本]
```

---

## 3. 测试命令

```
L1（单元，~10s）：[命令]
L2（冒烟，~30s）：[命令]
L3（完整，~60s+）：[命令]
```

---

## 4. 代码约束

- 删除策略：[软删除 is_deleted / 硬删除]
- API 返回格式：[{ code, data, message }]
- 命名规范：[变量驼峰 / 文件 kebab-case]
- 错误处理：对外显示友好提示，不暴露技术细节
- 新增依赖：必须在 architecture.md 登记

---

## 5. 严禁事项

- 不允许修改已完成功能的数据库字段名
- 不允许新增顶级目录而不更新 architecture.md
- 禁止在 build 阶段未完成测试前输出收尾语言
- 禁止在 verify.md 中使用推理性语言替代真实运行结果
- [项目追加...]

---

## 6. 文件命名规范（硬约束）

> 所有路径匹配依赖此规范。Claude 和开发者必须严格遵守，不得自行发挥。

**功能名 → 文件名转换规则：**
```
中文功能名：直接使用原名，空格替换为连字符
  例：用户登录 → 用户登录
  例：用户 登录 → 用户-登录

英文功能名：全小写 kebab-case
  例：User Login → user-login
  例：Create Post → create-post

建议：/pact.init 时统一约定功能名使用中文或英文，不混用
```

**生成路径（强制，不得偏离）：**
```
contract 文件   → .pact/contracts/[功能名].md
verify 记录     → .pact/knowledge/[功能名]-verify.md
exec-plan 文件  → .pact/exec-plans/active/[功能名]-plan.md
pid-card 文件   → .pact/specs/[功能名]-pid.md
```

> state.md 中"功能"字段的值必须与以上路径中的 [功能名] 完全一致。
> 路径不一致时，启动校验触发告警，流程停止。

---

## 7. 命令钩子协议

> Claude Code 提供 Hook 系统（PreToolUse / PostToolUse / SessionStart 等生命周期事件），
> 可在 shell 层面真正阻断流程，彻底解决"prompt 层无法强制执行约束"的问题。
>
> **硬检查点定义在各命令文件开头的「入口检查」小节，本节只负责 Hook 脚本的配置与注册，提供第二层兜底。**

---

### Hook 配置指南

在项目根目录创建检查脚本，并在 `.claude/settings.json` 注册为 SessionStart Hook：

**`.pact/hooks/check-state.sh`**（SessionStart 时运行，校验 state.md 一致性）
```bash
#!/bin/bash
STATE=".pact/state.md"
[ ! -f "$STATE" ] && exit 0

# 提取当前功能名和阶段
FEATURE=$(grep -m1 "^功能：" "$STATE" | sed 's/功能：\([^|]*\).*/\1/' | tr -d ' ')
PHASE=$(grep -m1 "阶段：" "$STATE" | sed 's/.*阶段：\([^ ]*\).*/\1/')

[ -z "$FEATURE" ] || [ "$FEATURE" = "[名称]" ] && exit 0

# pid 阶段：pid-card 文件必须存在
if [[ "$PHASE" == "pid" ]]; then
  if [ ! -f ".pact/specs/${FEATURE}-pid.md" ]; then
    echo "❌ PACT 状态不一致：state.md 声明 pid，但 specs/${FEATURE}-pid.md 不存在"
    exit 1
  fi
fi

# contract / build-complete 阶段：contract 文件必须存在
if [[ "$PHASE" == "contract" || "$PHASE" == "build-complete" ]]; then
  if [ ! -f ".pact/contracts/${FEATURE}.md" ]; then
    echo "❌ PACT 状态不一致：state.md 声明 ${PHASE}，但 contracts/${FEATURE}.md 不存在"
    exit 1
  fi
fi

# verify-pass 阶段：verify 文件必须存在且含 PASS
if [[ "$PHASE" == "verify-pass" ]]; then
  VERIFY=".pact/knowledge/${FEATURE}-verify.md"
  if [ ! -f "$VERIFY" ] || ! grep -q "verdict = PASS\|MANUAL OVERRIDE" "$VERIFY"; then
    echo "❌ PACT 状态不一致：state.md 声明 verify-pass，但凭证缺失或不合法"
    exit 1
  fi
fi
```

**`.claude/settings.json`** 中注册：
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [{ "type": "command", "command": "bash .pact/hooks/check-state.sh" }]
      }
    ]
  }
}
```

> Hook 脚本以非零退出码阻断会话继续；零退出码表示检查通过。
> 脚本需要 `chmod +x` 可执行权限。

---

### 软建议（工作习惯，不强制）

```
任意命令完成后：更新 state.md 阶段字段
任意 Step 失败时：将失败摘要写入 .pact/knowledge/errors/[命令]-[YYYYMMDD].md
                   state.md 回退至上一阶段
```

---

## 8. Build 完成条件（硬约束）

```
/pact.build 声明完成的唯一条件：
  1. 当前功能 contract 所有 FC 关键路径条目均已实现且可验证
  2. L1 或 L2 测试通过
  3. state.md 已更新至 build-complete

未满足以上全部条件，禁止输出"完成""已实现"
"基本框架就绪""可在此基础上扩展"等语言。
```

---

## 9. Verify Verdict 规则

```
PASS         — 所有 FC 在真实运行下成立，进入 /pact.ship
FAIL         — 列出被打破的 FC 条目和触发条件，回退 /pact.build
INCONCLUSIVE — 无法在当前环境实际运行（见 pact.verify.md 中 INCONCLUSIVE 处置协议）

进入 /pact.ship 的合法凭证：
  verdict = PASS，或
  verify.md 末尾包含有效的 MANUAL OVERRIDE 记录

禁止使用"应该""预期""理论上"等推理语言替代真实输出。
```

---

## 10. 外部 Skills 注册区

> 项目配置：记录各 Skill 的挂载点和安装状态。
> 到达挂载点时，检查安装状态。未安装则先安装，再触发，不跳过。
> 安装失败则写入 `.pact/knowledge/errors/`，跳过该 Skill，流程继续。

| Skill | 挂载点 | 触发时机 | 安装命令 | 状态 |
|-------|--------|---------|---------|------|
| code-review | /pact.verify（PASS 后可选） | 需要深度代码审查时 | `claude plugin install code-review` | [ ] |
| webapp-testing | /pact.ship Step 2 | 项目含前端时 | `claude plugin marketplace add anthropics/skills && claude plugin install example-skills@anthropic-agent-skills` | [ ] |
| code-simplifier | /pact.retro | 每轮回顾 | `claude plugin install code-simplifier` | [ ] |

**触发逻辑：**
```
[x] → 直接触发
[ ] → 执行安装命令 → 标记 [x] → 触发
安装失败 → 写入 errors/ → 跳过，流程继续
```

---

## 11. 归档触发规则

```
已完成功能表超过 10 条时：
  将最早的 5 条移至 .pact/knowledge/archive/completed.md
  本表只保留最近 5 条 + 首行标注总计数

state.md 已完成队列超过 10 条时：
  将最早的 5 条移至 .pact/knowledge/archive/state-history.md
  state.md 只保留最近 5 条
```

---

## 已完成功能

> 总计：0 个功能

| 功能 | 日期 | 契约 | 测试 | Verify |
|------|------|------|------|--------|
| （暂无） | | | | |
