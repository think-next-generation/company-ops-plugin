# cops:start-subsystem 命令实现

> 为子系统创建 cmux 工作区并启动 Agent

## Agent 启动配置

通过环境变量 `COMPANY_OPS_AGENT_COMMAND` 配置 Agent 启动命令：

```bash
# 在 .zshrc 或环境配置中设置
export COMPANY_OPS_AGENT_COMMAND="claude"
# 或使用其他 agent
export COMPANY_OPS_AGENT_COMMAND="claude -p sonnet"
# 或使用 codex/mini 等
export COMPANY_OPS_AGENT_COMMAND="codex"
```

## 执行流程

### 1. 检查子系统是否存在

```bash
# 从当前工作区读取 subsystems/ 目录
ls ../subsystems/财务/

# 或从 registry 读取
cat ../subsystems/_registry.json | grep 财务
```

### 2. 检查工作区是否已创建

```bash
# 使用 cmux list-surfaces 检查已存在的工作区
cmux list-surfaces

# 过滤已存在的 subsystem 工作区
cmux list-surfaces | grep -i 财务
```

### 3. 创建工作区（如果不存在）

```bash
# 在 cmux 中创建新工作区
cmux new-window -n "财务" -d "cd ai_run_company_with_docs/subsystems/财务"

# 或者使用快捷键 Ctrl-b c
```

### 4. 维护工作区清单

工作区信息保存在 `.system/workspaces.json`：

```json
{
  "version": "1.0.0",
  "updated_at": "2026-04-15T...",
  "workspaces": [
    {
      "id": "orchestrator",
      "name": "Orchestrator",
      "subsystem": null,
      "path": "company-ops",
      "cmux_surface": "0",
      "status": "running",
      "agent": "orchestrator-agent"
    },
    {
      "id": "财务",
      "name": "财务",
      "subsystem": "财务",
      "path": "subsystems/财务",
      "cmux_surface": "1",
      "status": "running",
      "agent": "claude-code"
    }
  ]
}
```

### 5. 启动 Agent 并验证

```bash
# 读取 Agent 启动命令（从环境变量）
AGENT_CMD="${COMPANY_OPS_AGENT_COMMAND:-claude}"

# 切换到工作区
cmux select-window -t 财务

# 使用配置的 Agent 命令启动
cmux send -t 财务 "$AGENT_CMD"

# 或者直接发送启动命令
cmux send -t 财务 "${AGENT_CMD} -d ai_run_company_with_docs/subsystems/财务"

# 发送初始化消息
cmux send -t 财务 "You are now the 财务 subsystem agent. Your workspace is subsystems/财务/"

# 验证启动成功
cmux send -t 财务 "!status"
```

---

## cops:startall 命令

> 为所有已注册的子系统创建工作区

### 执行流程

```bash
# 1. 读取 subsystems/_registry.json
cat subsystems/_registry.json

# 2. 获取所有活跃子系统
jq '.subsystems[] | select(.status=="active")' subsystems/_registry.json

# 3. 增量创建（跳过已存在的）
for subsystem in $(jq -r '.subsystems[].id' subsystems/_registry.json); do
    !cops:start-subsystem $subsystem
done
```

### 过滤条件

- 已在 `workspaces.json` 中的跳过
- 状态为 `active` 的才创建
- 提示用户确认