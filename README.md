# company-ops-plugin

> Claude Code 插件：为公司运营系统提供多工作区编排能力，与 cmux 终端集成实现多 Agent 并行运行。

## 概述

company-ops-plugin 是一个 Claude Code 插件，用于管理公司运营系统的多工作区编排。通过 cmux 终端实现多 Agent 并行运行，每个子系统（财务、法务、开发等）在独立的工作区中执行任务。

```
┌─────────────────────────────────────────────────────┐
│                    cmux 终端                         │
│                                                     │
│  ┌─────────────────┐  ┌─────────────────┐        │
│  │ Orchestrator    │  │ 财务子系统      │        │
│  │ (总调度)        │  │ (Agent)         │        │
│  └─────────────────┘  └─────────────────┘        │
│                                                     │
│  ┌─────────────────┐  ┌─────────────────┐        │
│  │ 法务子系统      │  │ 开发子系统      │        │
│  │ (Agent)         │  │ (Agent)         │        │
│  └─────────────────┘  └─────────────────┘        │
└─────────────────────────────────────────────────────┘
```

## 功能列表

| 命令 | 说明 | Matchers |
|------|------|---------|
| `!cops:init` | 初始化运行环境 | `!cops:init`, `!init-cops`, `!init` |
| `!cops:orchestrator` | 设置为 Orchestrator 总调度 | `!cops:orchestrator`, `!cops:orch` |
| `!cops:new-subsystem` | 创建新子系统 | `!cops:new-subsystem`, `!cops:new` |
| `!cops:list-workspaces` | 列出所有工作区 | `!cops:list-workspaces`, `!cops:ws` |
| `!cops:broadcast` | 向所有工作区广播消息 | `!cops:broadcast` |
| `!cops:status` | 显示系统状态 | `!cops:status` |
| `!cops:start-subsystem` | 启动子系统工作区 | `!cops:start-subsystem`, `!cops:start` |
| `!cops:startall` | 启动所有子系统 | `!cops:startall` |

## 安装

### 方式 1：使用 Claude Code 插件命令（推荐）

```bash
# 添加 marketplace
claude plugin marketplace add https://github.com/think-next-generation/company-ops-plugin.git

# 安装插件
claude plugin install company-ops
```

### 方式 2：克隆仓库

```bash
# 克隆到插件目录
git clone https://github.com/think-next-generation/company-ops-plugin.git \
  ~/.claude/plugins/marketplaces/company-ops

# 重启 Claude Code 使插件生效
```

### 方式 3：手动安装

```bash
# 创建目录
mkdir -p ~/.claude/plugins/marketplaces/company-ops

# 复制文件
cp plugin.json ~/.claude/plugins/marketplaces/company-ops/
cp -r rules/ ~/.claude/plugins/marketplaces/company-ops/
```

## 环境配置

### 必需：Agent 启动命令

在 `~/.zshrc` 或 `~/.bashrc` 中添加：

```bash
# Agent 启动命令（必需）
export COMPANY_OPS_AGENT_COMMAND="claude"

# 可选：指定模型
# export COMPANY_OPS_AGENT_COMMAND="claude -p sonnet"   # 使用 Sonnet 模型
# export COMPANY_OPS_AGENT_COMMAND="claude -p haiku"    # 使用 Haiku 模型（便宜快速）
# export COMPANY_OPS_AGENT_COMMAND="codex"               # 使用 Codex
```

### 可选：cmux 通知设置

```
cmux 配置 → 通知 → 取消勾选"收到通知时重新排序"
```

## 项目结构

### 工作目录结构

```
ai_run_company_with_docs/
├── company-ops/              # Orchestrator 工作区
│   ├── CLAUDE.md             # Agent 运行规��
│   ├── inbox/               # 接收消息
│   ├── outbox/              # 发送消息
│   ├── orchestrator/        # 监控脚本
│   ├── scripts/            # 工具脚本
│   └── .claude/skills/     # 本地 Skills
│       └── new-subsystem/  # 交互式创建子系统
├── subsystems/              # 子系统目录
│   ├── _registry.json     # 子系统注册表
│   ├── 财务/             # 财务子系统
│   ├── 法务/             # 法务子系统
│   ├── develop/          # 开发子系统
│   └── research/         # 研发子系统
└── docs/                  # 文档
```

### 子系统文件结构

```
subsystems/<name>/
├── CLAUDE.md             # Agent 运行规范（定义文件边界、权限）
├── SPEC.md               # 规范文档（核心职责、边界）
├── CONTRACT.yaml        # 交互契约（提供服务、消费服务）
├── CAPABILITIES.yaml    # 能力定义
├── local-graph.json     # 本地知识图谱
├── inbox/               # 接收消息
├── outbox/              # 发送消息
├── state/               # 状态跟踪
│   ├── goals.md
│   ├── status.md
│   └── metrics.yaml
├── data/                # 数据存储
├── src/                 # 源代码
├── scripts/             # 脚本
├── libs/                # 本地库
├── docs/                # 文档
└── workspace/          # 工作空间
```

## 快速开始

### 步骤 1：初始化环境

```bash
# 在 company-ops 目录下
cd ai_run_company_with_docs/company-ops

# 初始化
!cops:init
```

### 步骤 2：设置为总调度

```bash
# 设置为 Orchestrator
!cops:orchestrator
```

### 步骤 3：启动子系统

```bash
# 单个启动
!cops:start-subsystem 财务
!cops:start-subsystem 法务

# 或一次性启动所有
!cops:startall
```

### 步骤 4：查看状态

```bash
!cops:status
!cops:list-workspaces
```

## 命令详解

### cops:init

初始化完整运行环境：
1. 安装全局 llm-wiki skill
2. 拉取 ai_run_company_with_docs 项目
3. 安装 cops 工具
4. 配置环境变量

### cops:new-subsystem

创建新子系统（两阶段）：
- **Phase 1**：创建基础模板（目录、文件）
- **Phase 2**：交互式问答完善规范

```bash
!cops:new-subsystem 财务 --type=function
!cops:new-subsystem 产品研发 --type=product
!cops:new-subsystem 任务系统 --type=tool
```

### cops:start-subsystem

为子系统创建 cmux 工作区并启动 Agent：
1. 检查子系统是否存在
2. 检查工作区是否已创建
3. 创建新工作区
4. 启动 Agent
5. 更新工作区清单

```bash
!cops:start-subsystem 财务
# 或简写
!cops:start 财务
!cops:startsub 财务
```

### cops:broadcast

向所有工作区广播消息：

```bash
!cops:broadcast "系统将于今晚 10 点进行维护"
```

## 数据流

### 子系统注册

子系统信息保存在 `subsystems/_registry.json`：

```json
{
  "version": "1.0.0",
  "subsystems": [
    {
      "id": "财务",
      "name": "财务管理",
      "status": "active",
      "type": "function"
    }
  ]
}
```

### 工作区状态

工作区信息保存在 `.system/workspaces.json`：

```json
{
  "version": "1.0.0",
  "updated_at": "2026-04-15T10:00:00Z",
  "workspaces": [
    {
      "id": "orchestrator",
      "name": "Orchestrator",
      "subsystem": null,
      "path": "company-ops",
      "cmux_surface": "0",
      "status": "running"
    },
    {
      "id": "财务",
      "name": "财务",
      "subsystem": "财务",
      "path": "subsystems/财务",
      "cmux_surface": "1",
      "status": "running"
    }
  ]
}
```

## 依赖

- [cmux](https://github.com/think-next-generation/cmux) 终端 >= 0.60.0
- [Claude Code](https://claude.com/claude-code) 或 [Codex](https://codex.ai)
- Git（用于克隆项目）
- jq（用于 JSON 处理）

## 故障排除

### 插件不生效

```bash
# 重启 Claude Code
# 或重新加载配置
```

### 工作区创建失败

```bash
# 检查 cmux 是否运行
cmux list-surfaces

# 手动创建
cmux new-window -n "财务" -d "cd ai_run_company_with_docs/subsystems/财务"
```

### Agent 启动失败

```bash
# 检查环境变量
echo $COMPANY_OPS_AGENT_COMMAND

# 手动设置
export COMPANY_OPS_AGENT_COMMAND="claude"
```

## 相关文档

- [cops 工具](https://github.com/think-next-generation/cops)
- [llm-wiki](https://github.com/think-next-generation/llm-wiki)
- [cmux 终端](https://github.com/think-next-generation/cmux)

## LICENSE

MIT License

---

> 最后更新：2026-04-15