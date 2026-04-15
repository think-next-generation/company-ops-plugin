---
description: "创建新子系统：Phase 1 模板 + Phase 2 交互式完善"
allowed-tools: [Bash, Write, Read, Glob, AskUserQuestion]
model: sonnet
---

# cops:new-subsystem - 创建新子系统

创建新的业务子系统，包含完整的目录结构和配置文件。

## 参数

- `subsystem` (required): 子系统名称
- `type` (optional): 类型 function/product/tool，默认 function

## 执行步骤

### 1. 验证参数

确保 `subsystem` 名称已提供，检查是否已存在。

### 2. 创建子系统目录结构

```bash
mkdir -p subsystems/"$subsystem"/{inbox,outbox,knowledge}
```

### 3. 使用 new-subsystem skill

如果项目中包含 `.claude/skills/new-subsystem/SKILL.md`，则按照该 skill 的流程执行。

### 4. 更新 _registry.json

将新子系统注册到 `subsystems/_registry.json`。

### 5. 输出结果

```
子系统 $subsystem 创建完成！
路径：subsystems/$subsystem/
下一步：运行 !cops:start-subsystem $subsystem 启动
```
