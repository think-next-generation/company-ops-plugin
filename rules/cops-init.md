# cops:init 命令实现

> 初始化 company-ops 完整运行环境

## 执行步骤

### 1. 检查当前目录

```bash
pwd
# 应该在 company-ops/ 或其他目标目录
```

### 2. 初始化 ai_run_company_with_docs 项目

```bash
# 如果目录不存在或为空
if [ ! -d "ai_run_company_with_docs" ]; then
    git clone https://github.com/think-next-generation/ai_run_company_with_docs.git
fi

cd ai_run_company_with_docs
```

### 3. 删除 .git 目录（关键步骤）

```bash
# 删除克隆的 git 仓库，使其成为本地工作目录
rm -rf .git

# 验证删除成功
ls -la .git 2>/dev/null || echo ".git 已删除"
```

### 4. 初始化为本地 Git 仓库

```bash
# 初始化新的本地 Git 仓库
git init

# 添加远程（如果需要）
# git remote add origin <your-repo-url>

# 首次提交（可选）
git add .
git commit -m "Initial: company-ops workspace"
```

### 5. 安装全局 llm-wiki skill（如果未安装）

```bash
# 检查是否已安装
ls ~/.claude/skills/llm-wiki 2>/dev/null || echo "未安装"

# 如果未安装，克隆
if [ ! -d ~/.claude/skills/llm-wiki ]; then
    git clone https://github.com/think-next-generation/llm-wiki.git ~/.claude/skills/llm-wiki
fi
```

### 6. 安装 cops 工具（如果需要）

```bash
# 检查是否已安装
which cops 2>/dev/null || echo "未安装"

# 如果未安装，获取最新 release
if ! which cops >/dev/null 2>&1; then
    COPS_VERSION=$(curl -sL https://api.github.com/repos/think-next-generation/cops/releases/latest | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4)
    
    PLATFORM=$(uname -s)-$(uname -m)
    case $PLATFORM in
        Darwin\ arm64) ARCH="aarch64-apple-darwin" ;;
        Darwin\ x86_64) ARCH="x86_64-apple-darwin" ;;
        Linux\ x86_64) ARCH="x86_64-unknown-linux-gnu" ;;
    esac
    
    curl -sL "https://github.com/think-next-generation/cops/releases/download/${COPS_VERSION}/cops-${ARCH}.tar.gz" -o /tmp/cops.tar.gz
    tar -xzf /tmp/cops.tar.gz -C /tmp
    chmod +x /tmp/cops
    
    # 安装到全局
    sudo mv /tmp/cops /usr/local/bin/
    
    # 配置环境变量
    echo 'export COPS_DATA_DIR="~/ai_run_company_with_docs/company-ops/.system"' >> ~/.zshrc
    source ~/.zshrc
fi
```

### 7. 测试安装

```bash
cops --version
cops status
```

### 8. 最终输出

```
========================================
初始化完成！
========================================

📁 项目位置：~/ai_run_company_with_docs
📂 Orchestrator：company-ops/
📂 子系统：subsystems/

下一步：
1. 重新打开 cmux 终端
2. cd ai_run_company_with_docs/company-ops
3. 运行 !cops:orchestrator 设置为总调度

取消 cmux 通知重排序：
  cmux 配置 → 通知 → 取消勾选"收到通知时重新排序"

Agent 启动配置：
  export COMPANY_OPS_AGENT_COMMAND="claude"
```