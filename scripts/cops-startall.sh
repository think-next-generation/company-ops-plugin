#!/usr/bin/env bash
set -euo pipefail

echo "=== 启动所有子系统 ==="

# 定位 subsystems 目录
SUBSYSTEMS_DIR=""
if [ -d "subsystems" ]; then
    SUBSYSTEMS_DIR="subsystems"
elif [ -d "../subsystems" ]; then
    SUBSYSTEMS_DIR="../subsystems"
else
    echo "错误: 找不到 subsystems 目录"
    exit 1
fi

REGISTRY="$SUBSYSTEMS_DIR/_registry.json"
if [ ! -f "$REGISTRY" ]; then
    echo "错误: _registry.json 不存在"
    exit 1
fi

# 获取脚本目录（用于调用其他脚本）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 获取活跃子系统列表
SUBSYSTEMS=$(python3 -c "
import json
with open('$REGISTRY') as f:
    data = json.load(f)
for s in data.get('subsystems', []):
    if s.get('status') == 'active':
        print(s['id'])
" 2>/dev/null)

if [ -z "$SUBSYSTEMS" ]; then
    echo "没有活跃的子系统"
    exit 0
fi

CREATED=0
SKIPPED=0

for sub in $SUBSYSTEMS; do
    echo ""
    echo "--- 启动: $sub ---"
    if bash "$SCRIPT_DIR/cops-start-subsystem.sh" "$sub"; then
        CREATED=$((CREATED + 1))
    else
        SKIPPED=$((SKIPPED + 1))
    fi
done

echo ""
echo "=== 完成 ==="
echo "  已创建: $CREATED 个"
echo "  已跳过: $SKIPPED 个"
