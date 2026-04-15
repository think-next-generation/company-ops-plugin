#!/usr/bin/env bash
set -euo pipefail

SUBSYSTEM="${1:?用法: cops-new-subsystem <子系统名称>}"
SUBSYS_TYPE="${2:-function}"

# 定位 subsystems 目录
SUBSYSTEMS_DIR=""
if [ -d "subsystems" ]; then
    SUBSYSTEMS_DIR="subsystems"
elif [ -d "../subsystems" ]; then
    SUBSYSTEMS_DIR="../subsystems"
else
    echo "错误: 找不到 subsystems 目录，请先执行 /cops-init"
    exit 1
fi

SUBSYS_DIR="$SUBSYSTEMS_DIR/$SUBSYSTEM"

# 检查是否已存在
if [ -d "$SUBSYS_DIR" ]; then
    echo "错误: 子系统 '$SUBSYSTEM' 已存在"
    exit 1
fi

echo "=== 创建子系统: $SUBSYSTEM ==="

# 创建目录结构
mkdir -p "$SUBSYS_DIR"/{inbox,outbox,knowledge}
echo "  已创建目录: $SUBSYS_DIR/"

# 创建 CLAUDE.md
cat > "$SUBSYS_DIR/CLAUDE.md" <<EOF
# $SUBSYSTEM 子系统

> 类型: $SUBSYS_TYPE
> 创建时间: $(date -Iseconds)

## 职责

（待完善）

## 操作规范

- 收件箱: inbox/
- 发件箱: outbox/
- 知识库: knowledge/
EOF
echo "  已创建 CLAUDE.md"

# 创建 SPEC.md
cat > "$SUBSYS_DIR/SPEC.md" <<EOF
# $SUBSYSTEM - 规格说明

## 概述

子系统名称: $SUBSYSTEM
类型: $SUBSYS_TYPE

## 职责范围

（待完善）

## 输入/输出

- 输入: inbox/ 中的任务消息
- 输出: outbox/ 中的报告和结果

## 约束

（待完善）
EOF
echo "  已创建 SPEC.md"

# 更新 _registry.json
REGISTRY="$SUBSYSTEMS_DIR/_registry.json"
if [ -f "$REGISTRY" ]; then
    python3 -c "
import json, sys
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

echo ""
echo "子系统 '$SUBSYSTEM' 创建完成!"
echo "  路径: $SUBSYS_DIR/"
echo "  下一步: /cops-start-subsystem $SUBSYSTEM"
