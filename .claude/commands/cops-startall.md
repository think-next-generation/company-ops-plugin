---
description: "为所有已注册的子系统创建工作区（增量）"
allowed-tools: [Bash, Write, Read, Glob]
model: sonnet
---

# cops:startall - 启动所有子系统

为所有已注册且活跃的子系统创建 cmux 工作区（增量，跳过已存在的）。

## 执行步骤

### 1. 读取注册表

```bash
cat subsystems/_registry.json
```

### 2. 获取活跃子系统

```bash
jq -r '.subsystems[] | select(.status=="active") | .id' subsystems/_registry.json
```

### 3. 增量创建

对每个子系统执行 `!cops:start-subsystem`，跳过已存在的工作区。

### 4. 输出汇总

```
已创建：N 个新工作区
已跳过：N 个已存在
```
