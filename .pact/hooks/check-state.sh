#!/bin/bash
# PACT SessionStart Hook — 校验 state.md 与文件系统一致性
# 配置方式见 .pact/core/constitution.md § 7 Hook 配置指南

STATE=".pact/state.md"
[ ! -f "$STATE" ] && exit 0

# 提取当前功能名和阶段
FEATURE=$(grep -m1 "^功能：" "$STATE" | sed 's/功能：\([^|]*\).*/\1/' | tr -d ' ')
PHASE=$(grep -m1 "阶段：" "$STATE" | sed 's/.*阶段：\([^ ]*\).*/\1/')

# 无活跃功能，跳过检查
[ -z "$FEATURE" ] || [ "$FEATURE" = "[名称]" ] && exit 0

# pid 阶段：pid-card 文件必须存在
if [[ "$PHASE" == "pid" ]]; then
  if [ ! -f ".pact/specs/${FEATURE}-pid.md" ]; then
    echo "❌ PACT 状态不一致：state.md 声明 pid，但 specs/${FEATURE}-pid.md 不存在"
    echo "   请检查文件是否被误删，或手动修正 state.md 中的阶段字段"
    exit 1
  fi
fi

# contract / build-complete 阶段：contract 文件必须存在
if [[ "$PHASE" == "contract" || "$PHASE" == "build-complete" ]]; then
  if [ ! -f ".pact/contracts/${FEATURE}.md" ]; then
    echo "❌ PACT 状态不一致：state.md 声明 ${PHASE}，但 contracts/${FEATURE}.md 不存在"
    echo "   请检查文件是否被误删，或手动修正 state.md 中的阶段字段"
    exit 1
  fi
fi

# verify-pass 阶段：verify 文件必须存在且含合法凭证
if [[ "$PHASE" == "verify-pass" ]]; then
  VERIFY=".pact/knowledge/${FEATURE}-verify.md"
  if [ ! -f "$VERIFY" ]; then
    echo "❌ PACT 状态不一致：state.md 声明 verify-pass，但 ${VERIFY} 不存在"
    exit 1
  fi
  if ! grep -q "verdict = PASS\|MANUAL OVERRIDE" "$VERIFY"; then
    echo "❌ PACT 状态不一致：${VERIFY} 存在但不含 verdict = PASS 或 MANUAL OVERRIDE"
    exit 1
  fi
fi

exit 0
