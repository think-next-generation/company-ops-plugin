#!/usr/bin/env bash
set -euo pipefail

echo "=== Company Ops 状态 ==="
echo ""

# 定位子系统目录
SUBSYSTEMS_DIR=""
if [ -d "subsystems" ]; then
    SUBSYSTEMS_DIR="subsystems"
elif [ -d "../subsystems" ]; then
    SUBSYSTEMS_DIR="../subsystems"
fi

# 子系统注册表
if [ -n "$SUBSYSTEMS_DIR" ] && [ -f "$SUBSYSTEMS_DIR/_registry.json" ]; then
    SUBSYS_COUNT=$(python3 -c "import json; print(len(json.load(open('$SUBSYSTEMS_DIR/_registry.json')).get('subsystems', [])))" 2>/dev/null || echo "?")
    echo "已注册子系统: $SUBSYS_COUNT 个"
    python3 -c "
import json
with open('$SUBSYSTEMS_DIR/_registry.json') as f:
    data = json.load(f)
for s in data.get('subsystems', []):
    print(f\"  - {s['id']} ({s.get('type', '?')}) [{s.get('status', '?')}]\")
" 2>/dev/null
else
    echo "已注册子系统: 0 个（未初始化）"
fi

echo ""

# 工作区状态
WS_FILE=""
for f in ".system/workspaces.json" "../.system/workspaces.json"; do
    if [ -f "$f" ]; then
        WS_FILE="$f"
        break
    fi
done

if [ -n "$WS_FILE" ]; then
    WS_COUNT=$(python3 -c "import json; print(len(json.load(open('$WS_FILE')).get('workspaces', [])))" 2>/dev/null || echo "?")
    echo "工作区: $WS_COUNT 个"
    python3 -c "
import json
with open('$WS_FILE') as f:
    data = json.load(f)
for w in data.get('workspaces', []):
    print(f\"  - {w['id']} [{w.get('status', '?')}] agent={w.get('agent', '?')}\")
" 2>/dev/null
else
    echo "工作区: 未初始化（请先 /cops-orchestrator）"
fi

echo ""

# cmux/tmux 状态
if command -v cmux &>/dev/null; then
    echo "cmux 会话:"
    cmux list-windows 2>/dev/null || echo "  未运行"
elif command -v tmux &>/dev/null; then
    echo "tmux 会话:"
    tmux list-windows 2>/dev/null || echo "  未运行"
else
    echo "tmux/cmux: 未安装"
fi
