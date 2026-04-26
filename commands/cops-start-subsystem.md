---
description: "为子系统创建 cmux 工作区并启动 Agent"
allowed-tools: [Bash, Read, Glob, AskUserQuestion]
model: sonnet
---

# cops:start-subsystem - 启动子系统工作区

通过 cmux 为指定子系统创建工作区并启动 Agent。此命令需要 Agent 通过 cmux surface 与子 Agent 交互。

## 执行约束

- **严格按照下方步骤顺序执行**，不得在步骤之间插入额外命令（如 exploratory 查询、状态探测等）
- **bash 命令必须照抄文档原样**，不得修改参数、添加选项或替换命令名
- 如果某个步骤失败，报告错误并停止，不要尝试用替代命令绕过

## 参数

从用户输入中提取子系统名称 `$ARGUMENTS`。

## 执行流程

### 1. 检查子系统是否存在

读取 `subsystems/_registry.json`，确认子系统已注册且状态为 active。

如果子系统不存在，提示用户先执行 `/cops-new-subsystem <名称>`。

### 2. 读取工作区列表

读取 `.system/workspaces.json`，检查该子系统是否已有工作区。如果已存在且状态为 running，跳过并告知用户。

### 3. 创建 cmux 工作区

```bash
# 获取子系统绝对路径
SUBSYS_PATH="$(pwd)/../subsystems/$SUBSYSTEM"

# 使用 cmux 创建新工作区
cmux new-workspace --name "⬡ $SUBSYSTEM" --command "cd '$SUBSYS_PATH'"
```

### 4. 追加 workspaces.json 条目

将新工作区信息追加到 `.system/workspaces.json`（sync 需要该条目已存在才能匹配 cmux workspace）：

```python
import json
with open('.system/workspaces.json') as f:
    data = json.load(f)
data['workspaces'].append({
    'id': '<SUBSYSTEM>',
    'name': '<SUBSYSTEM>',
    'subsystem': '<SUBSYSTEM>',
    'path': 'subsystems/<SUBSYSTEM>',
    'status': 'running',
    'agent': AGENT_CMD
})
data['updated_at'] = '<current timestamp>'
with open('.system/workspaces.json', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
```

### 5. 同步 cmux IDs 到 workspaces.json

```bash
# Sync cmux IDs into workspaces.json
if [ -f "scripts/sync-cmux-ids.py" ]; then
    python3 scripts/sync-cmux-ids.py 2>/dev/null || true
fi
```

### 6. 启动 Agent

```bash
AGENT_CMD="${COMPANY_OPS_AGENT_COMMAND:-claude}"
cmux send -t "$SUBSYSTEM" "$AGENT_CMD" Enter
```

等待几秒让 Agent 启动。

### 7. 通过 cmux surface 发送初始化指令

直接通过 cmux 向子系统 surface 发送初始化消息：

```bash
cmux send -t "$SUBSYSTEM" "You are now the $SUBSYSTEM subsystem agent. Your workspace is subsystems/$SUBSYSTEM/" Enter
```

读取 `rules/init-subsystem.md` 中的初始化模板，替换 `{SUBSYSTEM_ID}` 和 `{WORKSPACE_PATH}` 变量后发送。

### 8. 确认启动

告知用户子系统已启动，列出当前所有活跃工作区。
