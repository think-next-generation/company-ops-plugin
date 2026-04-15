---
description: "显示 company-ops 系统状态"
allowed-tools: [Bash, Read, Glob]
model: sonnet
---

# cops:status - 系统状态

显示当前 company-ops 系统的运行状态。

## 执行步骤

### 1. 读取子系统注册表

```bash
cat subsystems/_registry.json
```

### 2. 读取工作区状态

```bash
cat .system/workspaces.json 2>/dev/null || echo "workspaces.json 不存在"
```

### 3. 检查 cmux 状态

```bash
cmux list-surfaces 2>/dev/null || echo "cmux 未运行"
```

### 4. 汇总输出

```
=== Company Ops 状态 ===
子系统：N 个已注册
工作区：N 个运行中
Agent：列出各工作区 agent 状态
```
