# cops:init 命令实现

> 初始化 company-ops 完整运行环境

## 执行步骤

### 1. 检查当前目录

```bash
pwd
# 应该是 ~/Develop/gitstore/ai/ai_run_company_with_docs
```

### 2. 安装全局 llm-wiki skill

```bash
# 检查是否已安装
ls ~/.claude/skills/llm-wiki 2>/dev/null || echo "not found"

# 如果未安装，克隆
git clone https://github.com/think-next-generation/llm-wiki.git ~/.claude/skills/llm-wiki
```

### 3. 拉取 ai_run_company_with_docs 项目

```bash
# 检查是否已存在
if [ ! -d "ai_run_company_with_docs" ]; then
    git clone https://gitee.com/think_next_generation/ai_run_company_with_docs.git
fi

cd ai_run_company_with_docs
```

### 4. 安装 cops 工具

```bash
# 获取最新 release 版本
COPS_VERSION=$(curl -sL https://api.github.com/repos/think-next-generation/cops/releases/latest | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4)

# 下载对应平台的包
PLATFORM=$(uname -s)-$(uname -m)
case $PLATFORM in
    Darwin arm64) ARCH="aarch64-apple-darwin" ;;
    Darwin x86_64) ARCH="x86_64-apple-darwin" ;;
    Linux*86_64) ARCH="x86_64-unknown-linux-gnu" ;;
esac

curl -sL "https://github.com/think-next-generation/cops/releases/download/${COPS_VERSION}/cops-${ARCH}.tar.gz" -o cops.tar.gz
tar -xzf cops.tar.gz
chmod +x cops

# 安装到全局
sudo mv cops /usr/local/bin/

# 配置环境变量
echo 'export COPS_DATA_DIR="~/ai_run_company_with_docs/company-ops/.system"' >> ~/.zshrc
```

### 5. 测试安装

```bash
cops --version
cops status
```

### 6. 最终提示

```
========================================
初始化完成！
========================================

下一步：
1. 重新打开 cmux 终端
2. 切换到 ai_run_company_ops/ 目录
3. 运行 !orchestrator 设置为总调度

取消 cmux 通知重排序：
cmux 配置 → 通知 → 取消勾选"收到通知时重新排序"
```