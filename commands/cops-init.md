---
description: "初始化 company-ops 完整运行环境：安装 llm-wiki、拉取项目、安装 cops、配置环境"
allowed-tools: [Bash, Write, Read, Glob]
model: sonnet
---

# cops:init - 初始化 company-ops 完整运行环境

初始化 company-ops 运行环境到指定目录。

## 执行步骤

### 1. 确定目标目录

参数 `target_dir` 默认为 `.`（当前目录）。

### 2. 拉取 ai_run_company_with_docs 项目

```bash
# 如果目标目录不存在或为空
TARGET="${target_dir:-.}"
if [ ! -d "$TARGET/ai_run_company_with_docs" ]; then
    git clone https://github.com/think-next-generation/ai_run_company_with_docs.git "$TARGET/ai_run_company_with_docs"
fi
```

### 3. 初始化 subsystems 目录

```bash
cd "$TARGET/ai_run_company_with_docs"

# 创建 subsystems 目录
mkdir -p subsystems

# 创建空的 _registry.json
cat > subsystems/_registry.json << 'EOF'
{
  "version": "1.0.0",
  "updated_at": "$(date -Iseconds)",
  "subsystems": []
}
EOF

touch subsystems/.gitkeep
```

### 4. 删除克隆的 .git 并初始化本地仓库

```bash
rm -rf .git
git init
git add .
git commit -m "Initial: company-ops workspace"
```

### 5. 安装 llm-wiki skill

```bash
GLOBAL_WIKI=~/.claude/skills/llm-wiki
LOCAL_WIKI=.claude/skills/llm-wiki

if [ -d "$GLOBAL_WIKI" ]; then
    # 全局已安装，克隆到本地使用
    mkdir -p .claude/skills
    git clone https://github.com/think-next-generation/llm-wiki.git "$LOCAL_WIKI"
elif [ -d "$LOCAL_WIKI" ]; then
    echo "本地 llm-wiki skill 已存在"
else
    # 全局没有安装，先安装到全局，再复制到本地
    git clone https://github.com/think-next-generation/llm-wiki.git "$GLOBAL_WIKI"
    mkdir -p .claude/skills
    cp -r "$GLOBAL_WIKI" "$LOCAL_WIKI"
fi
```

### 6. 输出结果

```
========================================
初始化完成！
========================================

项目位置：$TARGET/ai_run_company_with_docs
Orchestrator：company-ops/
子系统：subsystems/

下一步：
1. cd ai_run_company_with_docs/company-ops
2. 运行 !cops:orchestrator 设置为总调度
```
