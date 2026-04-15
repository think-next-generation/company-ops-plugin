#!/usr/bin/env bash
set -euo pipefail

SUBSYSTEM="${1:?用法: cops-new-subsystem <子系统名称> [type]}"
SUBSYS_TYPE="${2:-function}"
DATE="$(date +%Y-%m-%d)"

# 类型描述
TYPE_DESC="职能部门"
BASE_DIRS="inbox outbox state data src scripts libs docs workspace"

case "$SUBSYS_TYPE" in
    product)
        TYPE_DESC="产品线"
        BASE_DIRS="inbox outbox state src tests data docs scripts libs workspace"
        ;;
    tool)
        TYPE_DESC="工具系统"
        BASE_DIRS="inbox outbox state src bin config data scripts libs docs"
        ;;
    function|*)
        TYPE_DESC="职能部门"
        BASE_DIRS="inbox outbox state data src scripts libs docs workspace"
        ;;
esac

# 定位 subsystems 目录
SUBSYSTEMS_DIR=""
if [ -d "subsystems" ]; then
    SUBSYSTEMS_DIR="subsystems"
elif [ -d "../subsystems" ]; then
    SUBSYSTEMS_DIR="../subsystems"
else
    echo "错误: 找不到 subsystems 目录，请先执行 /company-ops:cops-init"
    exit 1
fi

SUBSYS_DIR="$SUBSYSTEMS_DIR/$SUBSYSTEM"

# 检查是否已存在
if [ -d "$SUBSYS_DIR" ]; then
    echo "错误: 子系统 '$SUBSYSTEM' 已存在"
    exit 1
fi

echo "=== 创建子系统: $SUBSYSTEM (类型: $SUBSYS_TYPE / $TYPE_DESC) ==="

# --- 1. 创建目录结构 ---
mkdir -p "$SUBSYS_DIR"/{inbox,outbox,state}

# 创建类型特定的目录
for d in $BASE_DIRS; do
    mkdir -p "$SUBSYS_DIR/$d"
    touch "$SUBSYS_DIR/$d/.gitkeep"
done

echo "  已创建目录结构"

# --- 2. CLAUDE.md ---
cat > "$SUBSYS_DIR/CLAUDE.md" <<EOF
# $SUBSYSTEM 子系统 Agent

## 身份

你是 $SUBSYSTEM 子系统 Agent，负责${TYPE_DESC}相关事务。你的工作目录是 \`subsystems/$SUBSYSTEM/\`。

## 文件边界约束

**你只能访问以下目录：**

\`\`\`
subsystems/$SUBSYSTEM/
├── CLAUDE.md          ← 你正在阅读的规范
├── SPEC.md             ← 完整规范文档
├── CONTRACT.yaml       ← 交互契约
├── CAPABILITIES.yaml   ← 能力定义
├── local-graph.json   ← 本地知识图谱
├── inbox/              ← 接收消息
├── outbox/             ← 发送消息
├── state/              ← 状态跟踪
│   ├── goals.md
│   ├── status.md
│   └── metrics.yaml
├── data/               ← 数据存储
├── src/                ← 源代码/脚本
├── scripts/            ← 自动化脚本
├── libs/               ← 本地库/依赖
├── docs/               ← 工作文档
└── workspace/          ← 工作空间
\`\`\`

**绝对禁止访问：**
- \`../\` (父目录除 inbox/outbox 外)
- \`../../company-ops/\` (Orchestrator 区域)
- \`../*/\` (其他子系统，除非通过 inbox/outbox 正式通信)
- 任何系统敏感文件

## 核心职责

请参考 SPEC.md 获取完整的职责定义。

## 与其他 Agent 交互

### 与 Orchestrator 通信

**接收任务：**
\`\`\`bash
ls inbox/
cat inbox/msg_*.json
\`\`\`

**汇报结果：**
\`\`\`bash
filename="reply_\$(date +%Y%m%d_%H%M%S).json"
cat > "outbox/\$filename" << 'MSGEOF'
{
  "task_id": "xxx",
  "status": "completed",
  "result": "..."
}
MSGEOF
\`\`\`

### 与其他子系统通信

通过 inbox/outbox 进行跨子系统通信：
\`\`\`bash
cat > "../其他子系统/inbox/req_xxx.json" << 'MSGEOF'
{
  "type": "service_request",
  "content": "..."
}
MSGEOF
\`\`\`

## 决策权限

请参考 SPEC.md 中的决策权限矩阵。

## 数据管理

- 敏感数据必须安全存储
- 禁止将子系统数据传到外部
- 保持数据隔离

## 状态更新

完成重要任务后更新 state/status.md。

## 相关文档

- SPEC.md - 完整规范
- CONTRACT.yaml - 交互协议
- CAPABILITIES.yaml - 能力定义
EOF
echo "  已创建 CLAUDE.md"

# --- 3. SPEC.md ---
cat > "$SUBSYS_DIR/SPEC.md" <<EOF
# $SUBSYSTEM 规范文档

## 基本信息

| 属性 | 值 |
|------|-----|
| 子系统ID | \`$SUBSYSTEM\` |
| 名称 | $SUBSYSTEM |
| 类型 | $SUBSYS_TYPE ($TYPE_DESC) |
| 创建日期 | $DATE |
| 状态 | initializing |

## 概述

${TYPE_DESC}子系统，负责...

## 职责范围

### 文件边界

\`\`\`
subsystems/$SUBSYSTEM/
├── CLAUDE.md
├── SPEC.md
├── CONTRACT.yaml
├── CAPABILITIES.yaml
├── local-graph.json
├── inbox/
├── outbox/
├── state/
│   ├── goals.md
│   ├── status.md
│   └── metrics.yaml
├── data/
├── src/
├── scripts/
├── libs/
├── docs/
└── workspace/
\`\`\`

### 核心职责

| ID | 职责 | 描述 | 优先级 |
|----|------|------|--------|
| TBD | - | 待定义 | - |

### 边界约束

**属于本子系统范围：**
- 待定义

**不属于本子系统范围：**
- 待定义

## 交互契约

请参考 CONTRACT.yaml

## 能力定义

请参考 CAPABILITIES.yaml

## 更新历史

| 日期 | 版本 | 变更说明 |
|------|------|----------|
| $DATE | 0.1.0 | 初始创建 |

---
*创建时间: $DATE*
EOF
echo "  已创建 SPEC.md"

# --- 4. CONTRACT.yaml ---
cat > "$SUBSYS_DIR/CONTRACT.yaml" <<EOF
# CONTRACT.yaml - ${SUBSYSTEM}子系统交互契约

version: "0.1.0"
subsystem_id: $SUBSYSTEM
name: $SUBSYSTEM
last_updated: "$DATE"
status: initializing

# 交互协议
interaction_protocols:
  request:
    format: intent-based
    description: |
      接收基于意图的请求，支持自然语言描述。
      请求通过 inbox/ 目录以文件形式接收。
    schema:
      type: object
      required: [intent, requestor, deadline]
      properties:
        intent:
          type: string
          description: 意图描述
        requestor:
          type: string
          description: 请求方子系统ID
        payload:
          type: object
          description: 请求参数
        deadline:
          type: string
          format: date-time

  response:
    format: structured
    description: |
      返回结构化的执行结果，通过 outbox/ 目录发送。

# 服务定义
services:
  provided: []
  consumed: []

# 通信通道
channels:
  inbox: inbox/
  outbox: outbox/
EOF
echo "  已创建 CONTRACT.yaml"

# --- 5. CAPABILITIES.yaml ---
cat > "$SUBSYS_DIR/CAPABILITIES.yaml" <<EOF
# CAPABILITIES.yaml - ${SUBSYSTEM}子系统能力定义

version: "0.1.0"
subsystem_id: $SUBSYSTEM
last_updated: "$DATE"

capabilities: []

constraints:
  - id: CONSTR-001
    type: file_boundary
    description: 只能在 subsystem/$SUBSYSTEM/ 目录下操作
  - id: CONSTR-002
    type: data_isolation
    description: 禁止访问其他子系统数据
EOF
echo "  已创建 CAPABILITIES.yaml"

# --- 6. local-graph.json ---
cat > "$SUBSYS_DIR/local-graph.json" <<EOF
{
  "metadata": {
    "version": "0.1.0",
    "subsystem": "$SUBSYSTEM",
    "created_at": "$(date -Iseconds)"
  },
  "entities": [],
  "relations": []
}
EOF
echo "  已创建 local-graph.json"

# --- 7. state/ 文件 ---
cat > "$SUBSYS_DIR/state/goals.md" <<EOF
# $SUBSYSTEM 目标

## 长期目标

- [ ] 完成子系统初始化

## 当前目标

- 完善 SPEC.md 职责定义
- 定义核心能力
- 配置交互契约
EOF

cat > "$SUBSYS_DIR/state/status.md" <<EOF
# $SUBSYSTEM 状态报告

## 当前状态

**整体状态：** 🟡 初始化中

**活跃任务：** 0
**阻塞问题：** 0
**待审核决策：** 0

## 本周进展

### 已完成
- $DATE 子系统目录结构创建
- $DATE 基础规范文档创建

### 进行中
- 完善 SPEC.md

### 待开始
- 定义核心能力
- 配置交互契约

## 风险与阻塞

暂无

## 下一步计划

1. 完善 SPEC.md 职责定义
2. 定义核心能力
3. 配置交互契约

---
*报告生成时间：$(date -Iseconds)*
EOF

cat > "$SUBSYS_DIR/state/metrics.yaml" <<EOF
# $SUBSYSTEM 指标

metrics:
  - name: tasks_completed
    type: counter
    description: 完成的任务数量

  - name: tasks_blocked
    type: gauge
    description: 阻塞的任务数量

  - name: avg_response_time
    type: gauge
    description: 平均响应时间(小时)
EOF
echo "  已创建 state/ 文件 (goals.md, status.md, metrics.yaml)"

# --- 8. 更新 _registry.json ---
REGISTRY="$SUBSYSTEMS_DIR/_registry.json"
if [ -f "$REGISTRY" ]; then
    python3 -c "
import json
with open('$REGISTRY') as f:
    data = json.load(f)
data['subsystems'].append({
    'id': '$SUBSYSTEM',
    'name': '$SUBSYSTEM',
    'type': '$SUBSYS_TYPE',
    'status': 'active',
    'created_at': '$(date -Iseconds)'
})
data['updated_at'] = '$(date -Iseconds)'
with open('$REGISTRY', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
"
    echo "  已注册到 _registry.json"
else
    echo "  [警告] _registry.json 不存在，跳过注册"
fi

# --- 完成 ---
echo ""
echo "子系统 '$SUBSYSTEM' 创建完成!"
echo "  路径: $SUBSYS_DIR/"
echo "  文件: CLAUDE.md, SPEC.md, CONTRACT.yaml, CAPABILITIES.yaml, local-graph.json"
echo "  目录: inbox, outbox, state, data, src, scripts, libs, docs, workspace"
echo ""
echo "下一步: /company-ops:cops-start-subsystem $SUBSYSTEM"
