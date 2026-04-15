---
description: "为子系统创建 cmux 工作区并启动 Agent"
allowed-tools: [Bash, Write, Read, Glob]
model: sonnet
---

# cops:start-subsystem - 启动子系统工作区

为指定子系统创建 cmux 工作区并启动 Agent。

## 参数

- `subsystem` (required): 子系统名称

## 执行步骤

### 1. 检查子系统是否存在

```bash
ls "subsystems/$subsystem/" 2>/dev/null || echo "子系统不存在"
cat subsystems/_registry.json | grep "$subsystem"
```

### 2. 检查工作区是否已创建

```bash
cmux list-surfaces 2>/dev/null | grep -i "$subsystem"
```

### 3. 创建工作区

```bash
cmux new-window -n "$subsystem" -d "cd $(pwd)/subsystems/$subsystem"
```

### 4. 启动 Agent

```bash
AGENT_CMD="${COMPANY_OPS_AGENT_COMMAND:-claude}"
cmux send -t "$subsystem" "$AGENT_CMD"
```

### 5. 发送初始化消息

读取 `rules/init-subsystem.md` 中的初始化模板，替换变量后发送给 Agent。

### 6. 更新 workspaces.json

将新工作区信息记录到 `.system/workspaces.json`。
