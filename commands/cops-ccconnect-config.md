---
description: "为子系统配置 cc-connect 双机器人连接"
allowed-tools: [Bash, Read, Write, Glob, AskUserQuestion]
model: sonnet
---

# cops:ccconnect-config - 配置 cc-connect 双机器人

为指定子系统配置 cc-connect，使其拥有独立的飞书机器人。项目将添加到 `~/.cc-connect/config.toml`。

## 参数

子系统名称，默认为 `Subsystem`。

## 执行流程

### 1. 询问用户

使用 AskUserQuestion 询问以下信息：

**Q1: 请提供第二个飞书机器人的 app_id：**
- 选项：用户输入

**Q2: 请提供第二个飞书机器人的 app_secret：**
- 选项：用户输入

### 2. 读取当前 config.toml

```bash
CURRENT_CONFIG=$(cat ~/.cc-connect/config.toml 2>/dev/null || echo "")
echo "$CURRENT_CONFIG" > /tmp/ccconnect_current.toml
```

### 3. 确定工作目录

```bash
SUBSYSTEM_NAME="${ARGUMENTS:-Subsystem}"
WORK_DIR="/Users/mac/Develop/gitstore/ai/ai_run_company_with_docs/subsystems/$SUBSYSTEM_NAME"
echo "子系统工作目录: $WORK_DIR"
```

### 4. 生成新项目配置

将以下内容追加到 config.toml：

```toml
# =============================================================================
# Project: Subsystem ($SUBSYSTEM_NAME)
# =============================================================================
[[projects]]
name = "$SUBSYSTEM_NAME"

[projects.agent]
type = "claudecode"

[projects.agent.options]
work_dir = "$WORK_DIR"
mode = "default"
model = "MiniMax-M2.7"

[[projects.platforms]]
type = "feishu"

[projects.platforms.options]
app_id = "$APP_ID"
app_secret = "$APP_SECRET"
```

### 5. 写入 config.toml

```bash
cat >> ~/.cc-connect/config.toml << EOF

# =============================================================================
# Project: Subsystem ($SUBSYSTEM_NAME)
# =============================================================================
[[projects]]
name = "$SUBSYSTEM_NAME"

[projects.agent]
type = "claudecode"

[projects.agent.options]
work_dir = "$WORK_DIR"
mode = "default"
model = "MiniMax-M2.7"

[[projects.platforms]]
type = "feishu"

[projects.platforms.options]
app_id = "$APP_ID"
app_secret = "$APP_SECRET"
EOF
```

### 6. 验证并重启 cc-connect

```bash
echo ""
echo "=== 验证配置 ==="
cc-connect config format --config ~/.cc-connect/config.toml 2>&1 || true

echo ""
echo "=== 重启 cc-connect ==="
cc-connect daemon restart
sleep 3
cc-connect daemon status
```

### 7. 输出结果

告知用户配置完成：
- 项目名称
- 工作目录
- 飞书机器人 app_id（部分隐藏）
