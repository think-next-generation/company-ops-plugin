# Company Operations System - Cloud Code Plugin

This plugin provides multi-workspace orchestration for company-ops using cmux.

## Architecture

```
┌─────────────────────────────────────────────┐
│ cmux Application                            │
├─────────────────────────────────────────────┤
│ Workspace 1: orchestrator (总调度)          │
│   - Cloud Code: Claude Code                 │
│   - Role: Coordinate all subsystems        │
│   - Path: company-ops/                     │
├─────────────────────────────────────────────┤
│ Workspace 2: 财务                           │
│   - Cloud Code: Claude Code                 │
│   - Role: Financial management             │
│   - Path: company-ops/subsystems/财务/     │
├─────────────────────────────────────────────┤
│ Workspace 3: 法务                           │
│   - Cloud Code: Claude Code                 │
│   - Role: Legal & compliance               │
│   - Path: company-ops/subsystems/法务/     │
└─────────────────────────────────────────────┘
```

## Workspace Types

### Orchestrator (工作区 1)
- **Purpose**: Company-wide coordination, task distribution, cross-subsystem communication
- **Environment Variables**:
  - `WORKSPACE_TYPE=orchestrator`
  - `WORKSPACE_ROOT=/path/to/company-ops`
  - `CMUX_WORKSPACE_ID` (set by cmux)
- **Capabilities**:
  - Create/delete subsystem workspaces
  - Broadcast messages to all workspaces
  - Monitor all subsystem status
  - Coordinate cross-subsystem tasks

### Subsystem Workspaces (工作区 2+)
- **Purpose**: Domain-specific operations
- **Environment Variables**:
  - `WORKSPACE_TYPE=subsystem`
  - `SUBSYSTEM_ID=<subsystem-name>`
  - `CMUX_WORKSPACE_ID`
- **Capabilities**:
  - Local domain operations
  - Send messages to orchestrator
  - Query local knowledge graph

## Commands

### Orchestrator Commands

| Command | Description |
|---------|-------------|
| `/company-ops:cops-orchestrator` | Initialize current workspace as orchestrator |
| `/company-ops:cops-new-subsystem <name>` | Create new subsystem workspace |
| `/company-ops:cops-list-workspaces` | List all workspaces |
| `/company-ops:cops-broadcast <message>` | Send message to all workspaces |
| `/company-ops:cops-status` | Show system status |

### Subsystem Commands

| Command | Description |
|---------|-------------|
| `!report <message>` | Send report to orchestrator |
| `/company-ops:cops-status` | Show local subsystem status |

## Creating a New Subsystem Workspace

When `/company-ops:cops-new-subsystem <name>` is executed in orchestrator:

1. **Create workspace in cmux**:
   ```bash
   cmux new-workspace --name "<subsystem>" --cwd "company-ops/subsystems/<subsystem>"
   ```

2. **Create first terminal pane**:
   ```bash
   cmux new-pane --type terminal --workspace workspace:N
   ```

3. **Launch Cloud Code** with initialization:
   ```bash
   cmux send --surface surface:N "claude --name <subsystem>-agent"
   cmux send-key --surface surface:N "Return"
   ```

4. **Send initialization message** with subsystem context:
   ```bash
   cmux send --surface surface:N "You are now the <subsystem> agent. Your role is to handle all <subsystem>-related tasks. Refer to company-ops/subsystems/<subsystem>/ for specifications."
   cmux send-key --surface surface:N "Return"
   ```

## Inter-Workspace Communication

### From Subsystem to Orchestrator

```bash
# Send message to orchestrator
cmux send --surface <surface-id> "Report: <message>"
cmux send-key --surface <surface-id> "Return"

# Or use the messaging file system
echo "<message>" > ../outbox/orchestrator msg.json
```

### From Orchestrator to Subsystem

```bash
# Broadcast to specific workspace
cmux send --surface surface:2 "Task from orchestrator: <task>"
cmux send-key --surface surface:2 "Return"
```

### Using inbox/outbox (File-based messaging)

Each subsystem has:
- `inbox/` - Receive messages from other workspaces
- `outbox/` - Send messages to other workspaces

Message format (JSON):
```json
{
  "from": "orchestrator",
  "to": "财务",
  "type": "task",
  "content": "Process invoice #12345",
  "timestamp": "2026-04-06T10:30:00Z"
}
```

## Configuration

The plugin is configured via `.claude-plugin/plugin.json`:

```json
{
  "config": {
    "command": "claude",
    "commandArgs": ["--dangerously-skip-permissions"],
    "workspaceRoot": "company-ops",
    "subsystems": ["财务", "法务"]
  }
}
```

### Configurable Options

| Option | Description | Default |
|--------|-------------|---------|
| `command` | Cloud Code command | `claude` |
| `commandArgs` | Additional arguments | `[]` |
| `workspaceRoot` | Root directory | `company-ops` |
| `subsystems` | Initial subsystems | `[]` |

## Cloud Code Initialization

When a new subsystem workspace is created, the Cloud Code session is initialized with:

1. **Role definition**: "You are the <subsystem> agent"
2. **Context loading**: Load `subsystems/<subsystem>/SPEC.md`
3. **Knowledge graph**: Initialize local-graph.json
4. **Capabilities**: Load CAPABILITIES.yaml

## Best Practices

1. **Always use `cmux send` + `cmux send-key`** - Never forget to press Enter
2. **Name your Cloud Code sessions** - Use `--name` flag for identification
3. **Monitor with `cmux tree`** - Verify all agents are running
4. **Use status indicators** - `cmux set-status` for progress
5. **Clean up** - Close unused panes with `cmux close-surface`

## Environment Variables

| Variable | Description |
|----------|-------------|
| `CMUX_WORKSPACE_ID` | Current workspace reference |
| `CMUX_SURFACE_ID` | Current pane/surface reference |
| `WORKSPACE_TYPE` | `orchestrator` or `subsystem` |
| `WORKSPACE_ROOT` | Root path of company-ops |
| `SUBSYSTEM_ID` | Current subsystem (if subsystem) |
