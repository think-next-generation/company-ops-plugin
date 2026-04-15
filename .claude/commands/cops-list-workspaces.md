---
description: "列出所有工作区"
allowed-tools: [Bash, Read, Glob]
model: sonnet
---

# cops:list-workspaces - 列出所有工作区

列出 company-ops 系统中所有已注册的工作区。

## 执行步骤

### 1. 读取工作区配置

```bash
cat .system/workspaces.json 2>/dev/null || echo "尚未初始化 Orchestrator"
```

### 2. 读取子系统注册表

```bash
cat subsystems/_registry.json
```

### 3. 检查 cmux 工作区

```bash
cmux list-surfaces 2>/dev/null
```

### 4. 格式化输出

以表格形式展示所有工作区及其状态。
