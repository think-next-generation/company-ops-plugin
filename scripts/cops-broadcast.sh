#!/usr/bin/env bash
set -euo pipefail

MESSAGE="${1:?用法: cops-broadcast <消息内容>}"
WS_FILE=".system/workspaces.json"

echo "=== 广播消息 ==="

# 检查 cmux
if ! command -v cmux &>/dev/null; then
    echo "错误: 未找到 cmux"
    exit 1
fi

if [ ! -f "$WS_FILE" ]; then
    echo "错误: workspaces.json 不存在"
    exit 1
fi

SENT=0
# 读取所有非 orchestrator 的运行中工作区及其 surface_id
python3 << PYEOF
import json
with open('$WS_FILE') as f:
    data = json.load(f)
for w in data.get('workspaces', []):
    if w.get('status') == 'running' and w['id'] != 'orchestrator':
        cmux_info = w.get('cmux', {})
        if cmux_info:
            ws_id = cmux_info.get('workspace_id', '')
            surf_id = cmux_info.get('surface_id', '')
            if ws_id and surf_id:
                print(f"{w['id']}|{ws_id}|{surf_id}")
PYEOF

WORKSPACE_LIST=$(python3 -c "
import json
with open('$WS_FILE') as f:
    data = json.load(f)
for w in data.get('workspaces', []):
    if w.get('status') == 'running' and w['id'] != 'orchestrator':
        cmux_info = w.get('cmux', {})
        if cmux_info:
            ws_id = cmux_info.get('workspace_id', '')
            surf_id = cmux_info.get('surface_id', '')
            if ws_id and surf_id:
                print(f\"{w['id']}|{ws_id}|{surf_id}\")
" 2>/dev/null)

for entry in $WORKSPACE_LIST; do
    WS_ID=$(echo "$entry" | cut -d'|' -f1)
    WORKSPACE=$(echo "$entry" | cut -d'|' -f2)
    SURFACE=$(echo "$entry" | cut -d'|' -f3)

    if cmux send --workspace "$WORKSPACE" --surface "$SURFACE" "[Broadcast] $MESSAGE" 2>/dev/null; then
        cmux send-key --workspace "$WORKSPACE" --surface "$SURFACE" enter 2>/dev/null
        echo "  已发送到: $WS_ID"
        SENT=$((SENT + 1))
    else
        echo "  [失败] $WS_ID"
    fi
done

echo ""
echo "已发送到 $SENT 个工作区"
