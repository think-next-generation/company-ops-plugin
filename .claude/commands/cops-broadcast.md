---
description: "向所有工作区广播消息"
allowed-tools: [Bash, Read, Glob]
model: sonnet
---

# cops:broadcast - 广播消息

向所有子系统工作区发送广播消息。

## 参数

- `message` (required): 要广播的消息内容

## 执行步骤

### 1. 读取活跃工作区列表

```bash
cat .system/workspaces.json
```

### 2. 逐个发送消息

```bash
for ws in $(jq -r '.workspaces[] | select(.status=="running") | .id' .system/workspaces.json); do
    if [ "$ws" != "orchestrator" ]; then
        cmux send -t "$ws" "[Broadcast] $message"
    fi
done
```

### 3. 确认发送

输出已发送消息的工作区列表。
