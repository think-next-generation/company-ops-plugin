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
cd "$PROJECT_DIR"
if [ -d .git ]; then
    rm -rf .git
    echo "  Removed cloned .git"
fi

echo "[4/5] Installing llm-wiki skill..."
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
