#!/usr/bin/env bash
set -euo pipefail

MESSAGE="${1:?用法: cops-broadcast <消息内容>}"

echo "=== 广播消息 ==="

# 检查 tmux/cmux
TMUX_CMD=""
if command -v cmux &>/dev/null; then
    TMUX_CMD="cmux"
elif command -v tmux &>/dev/null; then
    TMUX_CMD="tmux"
else
    echo "错误: 未找到 cmux 或 tmux"
    exit 1
fi

# 读取工作区列表
WS_FILE=""
for f in ".system/workspaces.json" "../.system/workspaces.json"; do
    if [ -f "$f" ]; then
        WS_FILE="$f"
        break
    fi
done

if [ -z "$WS_FILE" ]; then
    echo "错误: workspaces.json 不存在"
    exit 1
fi

SENT=0
WORKSPACES=$(python3 -c "
import json
with open('$WS_FILE') as f:
    data = json.load(f)
for w in data.get('workspaces', []):
    if w.get('status') == 'running' and w['id'] != 'orchestrator':
        print(w['id'])
" 2>/dev/null)

for ws in $WORKSPACES; do
    $TMUX_CMD send -t "$ws" "[Broadcast] $MESSAGE" Enter 2>/dev/null && {
        echo "  已发送到: $ws"
        SENT=$((SENT + 1))
    } || echo "  [失败] $ws"
done

echo ""
echo "已发送到 $SENT 个工作区"
