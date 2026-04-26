---
description: "初始化 company-ops 完整运行环境"
allowed-tools: [Bash]
---

Initialize the company-ops runtime environment. The argument is the target directory (default: current directory).

Execute this single script block. Do NOT split it into separate steps:

```bash
TARGET="${ARGUMENTS:-.}"
[ "$TARGET" = "" ] && TARGET="."
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "Error: target directory does not exist"; exit 1; }

REPO="https://github.com/think-next-generation/ai_run_company_with_docs.git"
WIKI_REPO="https://github.com/think-next-generation/llm-wiki.git"
PROJECT="ai_run_company_with_docs"

echo "=== cops:init starting ==="
echo "Target: $TARGET"

PROJECT_DIR="$TARGET/$PROJECT"
if [ -d "$PROJECT_DIR" ]; then
    echo "[skip] $PROJECT_DIR already exists"
else
    echo "[1/5] Cloning project..."
    git clone "$REPO" "$PROJECT_DIR"
fi

cd "$PROJECT_DIR"

echo "[2/5] Initializing subsystems..."
mkdir -p "$PROJECT_DIR/subsystems"
if [ ! -f "$PROJECT_DIR/subsystems/_registry.json" ]; then
    cat > "$PROJECT_DIR/subsystems/_registry.json" <<REGEOF
{
  "version": "1.0.0",
  "updated_at": "$(date -Iseconds)",
  "subsystems": []
}
REGEOF
    touch "$PROJECT_DIR/subsystems/.gitkeep"
    echo "  Created subsystems/_registry.json"
else
    echo "  [skip] _registry.json exists"
fi

echo "[3/5] Initializing local Git repo..."
if [ -d .git ]; then
    rm -rf .git
    echo "  Removed cloned .git"
fi

echo "[4/5] Installing cops CLI..."
if [[ "$(uname)" != "Darwin" ]]; then
    echo "  [skip] cops only supports macOS (darwin-arm64)"
elif [[ "$(uname -m)" != "arm64" ]]; then
    echo "  [skip] cops only supports arm64 (Apple Silicon)"
else
    COPS_VERSION=$(curl -s https://api.github.com/repos/think-next-generation/cops/releases/latest | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)
    if [ -z "$COPS_VERSION" ]; then
        echo "  [skip] Could not fetch latest cops version"
    else
        COPS_URL="https://github.com/think-next-generation/cops/releases/download/v${COPS_VERSION}/cops-${COPS_VERSION}-darwin-arm64.tar.gz"
        COPS_TMP=$(mktemp -d)
        echo "  Downloading cops v${COPS_VERSION}..."
        curl -sL "$COPS_URL" -o "$COPS_TMP/cops.tar.gz"
        tar -xzf "$COPS_TMP/cops.tar.gz" -C "$COPS_TMP"
        "$COPS_TMP/cops-*/install.sh"
        rm -rf "$COPS_TMP"
        echo "  Installed cops v${COPS_VERSION}"
    fi
fi

echo "[5/5] Installing llm-wiki skill..."
GLOBAL_WIKI="$HOME/.claude/skills/llm-wiki"
LOCAL_WIKI="$PROJECT_DIR/company-ops/.claude/skills/llm-wiki"

if [ -d "$LOCAL_WIKI" ]; then
    echo "  [skip] llm-wiki already exists under company-ops/"
elif [ -d "$GLOBAL_WIKI" ]; then
    mkdir -p "$PROJECT_DIR/company-ops/.claude/skills"
    git clone "$WIKI_REPO" "$LOCAL_WIKI"
    echo "  Cloned llm-wiki to company-ops/.claude/skills/ (global already installed)"
else
    mkdir -p "$HOME/.claude/skills"
    git clone "$WIKI_REPO" "$GLOBAL_WIKI"
    mkdir -p "$PROJECT_DIR/company-ops/.claude/skills"
    cp -r "$GLOBAL_WIKI" "$LOCAL_WIKI"
    echo "  Installed llm-wiki (global + company-ops local copy)"
fi

echo "[6/6] Checking cc-connect..."
if command -v cc-connect &> /dev/null; then
    echo "  cc-connect is installed: $(cc-connect --version 2>/dev/null || cc-connect --help 2>&1 | head -1)"
else
    echo "  cc-connect not found. Install from:"
    echo "    https://raw.githubusercontent.com/chenhg5/cc-connect/refs/heads/main/INSTALL.md"
fi

echo ""
echo "========================================"
echo "  Initialization complete!"
echo "========================================"
echo ""
echo "  Project: $PROJECT_DIR"
echo "  Orchestrator: $PROJECT_DIR/company-ops/"
echo "  Subsystems: $PROJECT_DIR/subsystems/"
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_DIR/company-ops"
echo "  2. /cops-orchestrator"
```
