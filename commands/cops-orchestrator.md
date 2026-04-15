---
description: "设置当前工作区为 Orchestrator（公司总调度）"
allowed-tools: [Bash, Write, Read, Glob]
model: sonnet
---

# cops:orchestrator - 设置 Orchestrator 工作区

将当前工作区初始化为公司运营的总调度中心。

## 执行步骤

### 1. 验证当前目录

确认当前在 `company-ops/` 目录或项目根目录下。

### 2. 设置环境变量

```bash
export WORKSPACE_TYPE=orchestrator
export WORKSPACE_ROOT="$(pwd)"
```

### 3. 初始化 Orchestrator 配置

确保 `.system/workspaces.json` 存在：

```bash
mkdir -p .system
if [ ! -f .system/workspaces.json ]; then
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
      "status": "running",
      "agent": "orchestrator-agent"
    }
  ]
}
EOF
fi
```

### 4. 加载 Orchestrator 规则

读取 `CLAUDE.md` 获取 orchestrator 的完整指令。

### 5. 输出就绪状态

```
Orchestrator 已就绪！
当前子系统：读取 subsystems/_registry.json
可用命令：!cops:new-subsystem, !cops:start-subsystem, !cops:status
```
