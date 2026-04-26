---
description: "为所有已注册的子系统创建工作区（增量）"
allowed-tools: [Bash, Read, Glob, AskUserQuestion]
model: sonnet
---

# cops:startall - 启动所有子系统

增量式为所有已注册且活跃的子系统创建 cmux 工作区。此命令需要 Agent 判断和跳过已存在的工作区。

## 执行流程

### 1. 读取子系统注册表

读取 `subsystems/_registry.json`，获取所有 status 为 active 的子系统列表。

### 2. 读取已有工作区

读取 `.system/workspaces.json`，获取已启动的工作区列表。

### 3. 逐个判断并启动

对每个活跃子系统：

1. **检查是否已启动**：如果已在 workspaces.json 中且 status 为 running，跳过
2. **检查 cmux 工作区是否存在**：`cmux list-workspaces` 检查是否已有同名窗口
3. **如果需要创建**：按照 `/cops-start-subsystem` 的流程执行
   - 创建 cmux 工作区
   - 启动 Agent
   - 发送初始化消息
   - 更新 workspaces.json

### 4. 输出汇总

告知用户：
- 新创建了几个工作区
- 跳过了几个已存在的
- 列出所有当前活跃工作区及状态
