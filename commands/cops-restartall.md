---
description: "重置并启动所有子系统（先删除所有非 Orchestrator 工作区，再重新启动）"
allowed-tools: [Bash, Read, Glob, AskUserQuestion]
model: sonnet
---

# cops:restartall - 重置并启动所有子系统

此命令先删除 `.system/workspaces.json` 中除 Orchestrator 之外的所有子系统工作区，然后重新执行 startall。

## 执行流程

### 1. 提醒用户即将关闭非 Orchestrator 工作区

**输出以下消息给用户：**

```
⚠️ 即将执行重置操作：

1. 关闭并删除 cmux 中除 Orchestrator 之外的所有工作区
2. 重新创建所有活跃子系统的工作区
3. 重启 cc-connect（双机器人配置）

按 Enter 继续，Ctrl+C 取消。
```

### 2. 删除 workspaces.json 中的非 Orchestrator 工作区

```bash
python3 << 'EOF'
import json
with open('.system/workspaces.json') as f:
    data = json.load(f)
removed = [w for w in data.get('workspaces', []) if w['id'] != 'orchestrator']
removed_count = len(removed)
# 过滤保留 only orchestrator
data['workspaces'] = [w for w in data.get('workspaces', []) if w['id'] == 'orchestrator']
data['updated_at'] = '2026-04-28T00:00:00.000000+08:00'
with open('.system/workspaces.json', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print(f"已从 workspaces.json 删除 {removed_count} 个工作区")
EOF
```

### 3. 自动关闭 cmux 中对应的非 Orchestrator 工作区

```bash
# 获取所有非 orchestrator 的 workspace_id
WORKSPACE_IDS=$(python3 -c "
import json
with open('.system/workspaces.json') as f:
    data = json.load(f)
for w in data.get('workspaces', []):
    if w['id'] != 'orchestrator':
        cmux_info = w.get('cmux', {})
        if cmux_info:
            print(cmux_info.get('workspace_id', ''))
" 2>/dev/null)

for ws_id in $WORKSPACE_IDS; do
    echo "关闭 cmux 工作区: $ws_id"
    cmux close-workspace --workspace "$ws_id" 2>/dev/null || true
done
```

### 4. 重启 cc-connect daemon

```bash
cc-connect daemon restart
sleep 3
cc-connect daemon status
```

### 5. 重新创建工作区（Startall 流程）

按照 `/cops-startall` 流程执行：
1. 读取 `../subsystems/_registry.json`
2. 读取 `.system/workspaces.json`
3. 逐个判断并启动

### 6. 输出汇总

告知用户：
- 删除了几个工作区
- 新创建了几个工作区
- 列出所有当前活跃工作区及状态
