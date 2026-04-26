---
description: "设置当前工作区为 Orchestrator（公司总调度）"
allowed-tools: [Bash]
---

Run the orchestrator setup script:

```bash
echo "=== Pre-flight checks ==="

# Check cops installation
COPS_PATH=""
if command -v cops &> /dev/null; then
    COPS_PATH="cops"
elif [ -x "$HOME/.cops/cops" ]; then
    COPS_PATH="$HOME/.cops/cops"
fi

if [ -n "$COPS_PATH" ] && $COPS_PATH --help &> /dev/null; then
    echo "[OK] cops is installed: $($COPS_PATH --version 2>/dev/null | head -1 || $COPS_PATH --help 2>&1 | head -1)"
elif [ -n "$COPS_PATH" ]; then
    echo "[ERROR] cops binary found but --help failed. Please reinstall."
    exit 1
else
    echo "[ERROR] cops not found. Please install cops CLI first."
    echo "  macOS arm64: Follow cops installation guide in cops-init"
    exit 1
fi

# Check cc-connect installation
CC_CONNECT_PATH=""
if command -v cc-connect &> /dev/null; then
    CC_CONNECT_PATH="cc-connect"
elif [ -x "$HOME/.cc-connect/cc-connect" ]; then
    CC_CONNECT_PATH="$HOME/.cc-connect/cc-connect"
fi

if [ -z "$CC_CONNECT_PATH" ]; then
    echo "[ERROR] cc-connect not found. Follow https://raw.githubusercontent.com/chenhg5/cc-connect/refs/heads/main/INSTALL.md to install and configure cc-connect."
    exit 1
fi

if ! $CC_CONNECT_PATH --help &> /dev/null; then
    echo "[ERROR] cc-connect is installed but --help failed. Please check installation."
    exit 1
fi

# Check cc-connect daemon status
if $CC_CONNECT_PATH status &> /dev/null; then
    CC_STATUS=$($CC_CONNECT_PATH status 2>&1 | head -3)
    if echo "$CC_STATUS" | grep -qi "running\|started\|active"; then
        echo "[OK] cc-connect daemon is running"
    else
        echo "[WARN] cc-connect daemon may not be running: $CC_STATUS"
        echo "  Try: $CC_CONNECT_PATH start"
    fi
else
    # Fallback: check if process is running
    if pgrep -x "cc-connect" &> /dev/null; then
        echo "[OK] cc-connect process is running"
    else
        echo "[WARN] cc-connect daemon not detected. Try: $CC_CONNECT_PATH start"
    fi
fi

echo ""
echo "=== Starting Orchestrator ==="
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cops-orchestrator.sh"
```
