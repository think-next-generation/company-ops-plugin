---
description: "设置当前工作区为 Orchestrator（公司总调度）"
allowed-tools: [Bash]
---

Run the orchestrator setup script:

```bash
echo "=== Pre-flight checks ==="

# Check cops installation
if command -v cops &> /dev/null && cops --help &> /dev/null; then
    echo "[OK] cops is installed: $(cops --version 2>/dev/null | head -1 || cops --help 2>&1 | head -1)"
else
    echo "[ERROR] cops not found. Please install cops CLI first."
    echo "  macOS arm64: Follow cops installation guide in cops-init"
    exit 1
fi

# Check cc-connect installation
if ! command -v cc-connect &> /dev/null; then
    echo "[ERROR] cc-connect not found. Follow https://raw.githubusercontent.com/chenhg5/cc-connect/refs/heads/main/INSTALL.md to install and configure cc-connect."
    exit 1
fi

if ! cc-connect --help &> /dev/null; then
    echo "[ERROR] cc-connect is installed but --help failed. Please check installation."
    exit 1
fi

# Check cc-connect daemon status
if cc-connect status &> /dev/null; then
    CC_STATUS=$(cc-connect status 2>&1 | head -3)
    if echo "$CC_STATUS" | grep -qi "running\|started\|active"; then
        echo "[OK] cc-connect daemon is running"
    else
        echo "[WARN] cc-connect daemon may not be running: $CC_STATUS"
        echo "  Try: cc-connect start"
    fi
else
    # Fallback: check if process is running
    if pgrep -x "cc-connect" &> /dev/null; then
        echo "[OK] cc-connect process is running"
    else
        echo "[WARN] cc-connect daemon not detected. Try: cc-connect start"
    fi
fi

echo ""
echo "=== Starting Orchestrator ==="
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cops-orchestrator.sh"
```
