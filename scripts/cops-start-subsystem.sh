#!/usr/bin/env bash
set -euo pipefail

SUBSYSTEM="${1:?用法: cops-start-subsystem <子系统名称>}"

echo "=== 启动子系统: $SUBSYSTEM ==="

# 定位子系统目录
SUBSYS_DIR=""
if [ -d "subsystems/$SUBSYSTEM" ]; then
    SUBSYS_DIR="subsystems/$SUBSYSTEM"
elif [ -d "../subsystems/$SUBSYSTEM" ]; then
    SUBSYS_DIR="../subsystems/$SUBSYSTEM"
else
    echo "错误: 子系统 '$SUBSYSTEM' 不存在，请先 /cops-new-subsystem $SUBSYSTEM"
    exit 1
fi

# 获取绝对路径
SUBSYS_ABS="$(cd "$SUBSYS_DIR" && pwd)"

# 检查 tmux/cmux 是否可用
TMUX_CMD=""
if command -v cmux &>/dev/null; then
    TMUX_CMD="cmux"
elif command -v tmux &>/dev/null; then
    TMUX_CMD="tmux"
else
    echo "错误: 未找到 cmux 或 tmux"
    exit 1
fi

echo "  使用: $TMUX_CMD"

# 检查工作区是否已存在
if $TMUX_CMD list-windows 2>/dev/null | grep -q "$SUBSYSTEM"; then
    echo "  [跳过] 工作区 '$SUBSYSTEM' 已存在"
    exit 0
fi

# 创建工作区
$TMUX_CMD new-window -n "$SUBSYSTEM" -d "cd '$SUBSYS_ABS'"
echo "  已创建工作区: $SUBSYSTEM"

# 启动 Agent
AGENT_CMD="${COMPANY_OPS_AGENT_COMMAND:-claude}"
$TMUX_CMD send -t "$SUBSYSTEM" "$AGENT_CMD" Enter
echo "  已启动 Agent: $AGENT_CMD"

# 发送初始化消息
sleep 2
$TMUX_CMD send -t "$SUBSYSTEM" "You are now the $SUBSYSTEM subsystem agent. Your workspace is $SUBSYS_DIR" Enter

# 更新 workspaces.json
WS_FILE=".system/workspaces.json"
if [ ! -f "$WS_FILE" ]; then
    WS_FILE="../.system/workspaces.json"
fi

if [ -f "$WS_FILE" ]; then
    python3 -c "
import json
with open('$WS_FILE') as f:
    data = json.load(f)
data['workspaces'].append({
    'id': '$SUBSYSTEM',
    'name': '$SUBSYSTEM',
    'subsystem': '$SUBSYSTEM',
    'path': 'subsystems/$SUBSYSTEM',
    'status': 'running',
    'agent': '$AGENT_CMD'
})
data['updated_at'] = '$(date -Iseconds)'
with open('$WS_FILE', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
"
    echo "  已更新 workspaces.json"
fi

echo ""
echo "子系统 '$SUBSYSTEM' 已启动!"
