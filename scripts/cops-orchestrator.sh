#!/usr/bin/env bash
set -euo pipefail

# 验证在正确目录
if [ ! -f "CLAUDE.md" ] && [ ! -f "../subsystems/_registry.json" ]; then
    echo "错误: 请在 company-ops/ 目录下执行此命令"
    exit 1
fi

echo "=== cops:orchestrator 初始化 ==="

# 设置环境变量
export WORKSPACE_TYPE=orchestrator
export WORKSPACE_ROOT="$(pwd)"

# 更新 .system/workspaces.json
if [ -f .system/workspaces.json ]; then
    cat > .system/workspaces.json << 'EOF'
{
  "version": "1.0.0",
  "updated_at": "$(date -Iseconds)",
  "workspaces": [
    {
      "id": "orchestrator",
      "name": "Orchestrator",
      "subsystem": null,
      "path": "company-ops",
      "cmux_id": null,
      "status": "running",
      "agent": "orchestrator-agent"
    }
  ]
}
EOF
    echo "  已更新 .system/workspaces.json"
fi

# Tag current cmux workspace as orchestrator
if command -v cmux &>/dev/null; then
    CURRENT_WS=$(cmux current-workspace 2>/dev/null || true)
    if [ -n "$CURRENT_WS" ]; then
        cmux rename-workspace --workspace "$CURRENT_WS" "⬡ orchestrator" 2>/dev/null && \
            echo "  已标记 cmux workspace: ⬡ orchestrator ($CURRENT_WS)" || true
    fi
fi

# Sync cmux IDs into workspaces.json
if [ -f "scripts/sync-cmux-ids.py" ]; then
    python3 scripts/sync-cmux-ids.py 2>/dev/null || true
fi

# 输出子系统信息
echo ""
echo "=== Orchestrator 已就绪 ==="

if [ -f "../subsystems/_registry.json" ]; then
    SUBSYS_COUNT=$(python3 -c "import json; print(len(json.load(open('../subsystems/_registry.json')).get('subsystems', [])))" 2>/dev/null || echo "0")
    echo "  已注册子系统: $SUBSYS_COUNT 个"
else
    echo "  已注册子系统: 0 个（未初始化）"
fi

echo ""
echo "可用命令:"
echo "  /cops-new-subsystem <名称>   创建子系统"
echo "  /cops-start-subsystem <名称> 启动子系统"
echo "  /cops-status                 查看状态"
