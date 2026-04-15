#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-.}"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "错误: 目标目录不存在"; exit 1; }

REPO="https://github.com/think-next-generation/ai_run_company_with_docs.git"
WIKI_REPO="https://github.com/think-next-generation/llm-wiki.git"
PROJECT="ai_run_company_with_docs"

echo "=== cops:init 开始 ==="
echo "目标目录: $TARGET"

# --- 1. 克隆项目 ---
PROJECT_DIR="$TARGET/$PROJECT"
if [ -d "$PROJECT_DIR" ]; then
    echo "[跳过] $PROJECT_DIR 已存在"
else
    echo "[1/5] 克隆项目..."
    git clone "$REPO" "$PROJECT_DIR"
fi

cd "$PROJECT_DIR"

# --- 2. 初始化 subsystems ---
echo "[2/5] 初始化 subsystems..."
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
    echo "  已创建 subsystems/_registry.json"
else
    echo "  [跳过] _registry.json 已存在"
fi

# --- 3. 删除 .git 并初始化本地仓库 ---
echo "[3/5] 初始化本地 Git 仓库..."
cd "$PROJECT_DIR"
if [ -d .git ]; then
    rm -rf .git
    echo "  已删除克隆的 .git"
fi
git init
git add .
git commit -m "Initial: company-ops workspace" --allow-empty

# --- 4. 安装 llm-wiki 到 company-ops/ 下 ---
echo "[4/5] 安装 llm-wiki skill..."
GLOBAL_WIKI="$HOME/.claude/skills/llm-wiki"
LOCAL_WIKI="$PROJECT_DIR/company-ops/.claude/skills/llm-wiki"

if [ -d "$LOCAL_WIKI" ]; then
    echo "  [跳过] company-ops 下 llm-wiki 已存在"
elif [ -d "$GLOBAL_WIKI" ]; then
    mkdir -p "$PROJECT_DIR/company-ops/.claude/skills"
    git clone "$WIKI_REPO" "$LOCAL_WIKI"
    echo "  已克隆 llm-wiki 到 company-ops/.claude/skills/（全局已安装）"
else
    mkdir -p "$HOME/.claude/skills"
    git clone "$WIKI_REPO" "$GLOBAL_WIKI"
    mkdir -p "$PROJECT_DIR/company-ops/.claude/skills"
    cp -r "$GLOBAL_WIKI" "$LOCAL_WIKI"
    echo "  已安装 llm-wiki（全局 + company-ops 本地副本）"
fi

# --- 5. 输出结果 ---
echo ""
echo "========================================"
echo "  初始化完成！"
echo "========================================"
echo ""
echo "  项目位置: $PROJECT_DIR"
echo "  Orchestrator: $PROJECT_DIR/company-ops/"
echo "  子系统: $PROJECT_DIR/subsystems/"
echo ""
echo "下一步:"
echo "  1. cd $PROJECT_DIR/company-ops"
echo "  2. /cops-orchestrator 设置为总调度"
