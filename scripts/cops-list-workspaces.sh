#!/usr/bin/env bash
set -euo pipefail

echo "=== 工作区列表 ==="
echo ""

# 工作区配置
WS_FILE=""
for f in ".system/workspaces.json" "../.system/workspaces.json"; do
    if [ -f "$f" ]; then
        WS_FILE="$f"
        break
    fi
done

if [ -n "$WS_FILE" ]; then
    python3 -c "
import json
with open('$WS_FILE') as f:
    data = json.load(f)
print(f'{'ID':<20} {'状态':<12} {'Agent':<20} 路径')
print('-' * 72)
for w in data.get('workspaces', []):
    print(f\"{w['id']:<20} {w.get('status', '?'):<12} {w.get('agent', '?'):<20} {w.get('path', '?')}\")
" 2>/dev/null
else
    echo "尚未初始化 Orchestrator，请先 /cops-orchestrator"
fi
