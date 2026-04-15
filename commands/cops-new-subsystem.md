---
description: "创建新子系统（两阶段：模板创建 + 交互式问答完善规范）"
allowed-tools: [Bash, Read, Write, Glob, AskUserQuestion]
model: sonnet
---

# cops:new-subsystem - 创建新子系统

从用户输入 `$ARGUMENTS` 中提取子系统名称。执行两阶段流程。

## Phase 1: 基础模板创建

运行脚本创建基础目录结构并注册到 _registry.json：

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cops-new-subsystem.sh" "$ARGUMENTS"
```

## Phase 2: 交互式问答完善规范

脚本执行成功后，**立即进入 Phase 2**。按照以下流程逐个提问用户，每轮问答后立即更新对应文件。

读取 `skills/new-subsystem/SKILL.md` 获取完整的问答流程，以及 `skills/new-subsystem/questions.md` 获取详细的问答引导。

同时使用 `skills/new-subsystem/templates/` 目录下的模板片段：
- `spec_md_fragment.md` → 写入 SPEC.md 的职责和边界章节
- `claude_md_fragment.md` → 写入 CLAUDE.md 的团队和权限章节
- `contract_yaml_fragment.md` → 写入 CONTRACT.yaml 的服务定义

### 5 轮问答

每轮提问后等待用户回答，然后立即更新文件，再进入下一轮：

1. **Q1/5 核心职责** → 更新 SPEC.md
2. **Q2/5 边界约束** → 更新 SPEC.md
3. **Q3/5 Agent 团队** → 更新 CLAUDE.md
4. **Q4/5 决策权限** → 更新 CLAUDE.md
5. **Q5/5 服务定义** → 更新 CONTRACT.yaml

### 结束

告知用户所有文件已更新，提示下一步：`/company-ops:cops-start-subsystem <name>`
