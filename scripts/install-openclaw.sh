#!/usr/bin/env bash
# Ubuntu 一键安装 OpenClaw-CN 脚本
# 在 Ubuntu (proot-distro) 环境中运行

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC} $*" >&2; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $*" >&2; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
log_error() { echo -e "${RED}[ERR]${NC} $*" >&2; }

# 检查是否在 Ubuntu 中
if ! command -v apt &>/dev/null; then
    log_error "请在 Ubuntu 环境中运行此脚本"
    log_error "先执行: proot-distro login ubuntu"
    exit 1
fi

log_info "=========================================="
log_info " OpenClaw-Termux 一键安装脚本"
log_info "=========================================="
echo ""

# 1. 更新系统
log_info "1/7 更新系统包..."
apt update -y
apt upgrade -y
log_ok "系统已更新"

# 2. 安装必要软件
log_info "2/7 安装必要软件包..."
apt install -y \
    sudo \
    ssh \
    nginx \
    curl \
    wget \
    ca-certificates \
    jq \
    locales \
    language-pack-zh-hans
log_ok "软件包安装完成"

# 3. 配置中文 locale
log_info "3/7 配置中文环境..."
if ! locale -a | grep -q "zh_CN.utf8"; then
    locale-gen zh_CN.UTF-8
fi
update-locale LANG=zh_CN.UTF-8
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
log_ok "中文环境已配置"

# 4. 创建 openclaw 用户（如果不存在）
log_info "4/7 检查 openclaw 用户..."
if ! id "openclaw" &>/dev/null; then
    log_info "创建 openclaw 用户..."
    adduser --disabled-password --gecos "" openclaw
    usermod -aG sudo openclaw
    log_ok "用户 openclaw 已创建"
else
    log_ok "用户 openclaw 已存在"
fi

# 5. 检查并切换到 openclaw 用户
echo ""
log_info "5/7 检查用户环境"

# 检查当前用户
if [ "$USER" = "root" ]; then
    # root 用户需要切换到 openclaw
    log_info "当前为 root 用户，需要切换到 openclaw 用户继续安装"
    echo "建议在 openclaw 用户下运行 OpenClaw。"
    read -p "是否切换到 openclaw 用户继续安装？(Y/n): " switch_user
    
    if [[ "$switch_user" =~ ^[Nn]$ ]]; then
        log_warn "将在 root 用户下安装（不推荐）"
    else
        log_info "切换到 openclaw 用户..."
        # 使用 su 切换用户并重新执行脚本
        # 获取脚本的绝对路径
        SCRIPT_PATH="$(readlink -f "$0")"
        su - openclaw -c "bash '$SCRIPT_PATH'"
        exit 0
    fi
elif [ "$USER" = "openclaw" ]; then
    log_ok "当前用户已是 openclaw，继续安装"
else
    log_warn "当前用户为 $USER，建议在 openclaw 用户下运行"
fi

# 现在应该在正确的用户下
log_ok "当前用户: $USER"
log_ok "家目录: $HOME"

# 6. 安装 nvm 和 Node.js
echo ""
log_info "6/7 安装 nvm 和 Node.js..."

# 检查是否已安装 Node.js
if command -v node &>/dev/null && [[ $(node --version) =~ ^v2[4-9] ]]; then
    log_ok "Node.js $(node --version) 已安装，跳过"
else
    log_info "安装 nvm 和 Node.js..."

    # 下载并安装 nvm
    export NVM_DIR="$HOME/.nvm"
    if [ -d "$NVM_DIR" ]; then
        log_info "nvm 已存在，跳过安装"
    else
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    fi

    # 加载 nvm
    \. "$NVM_DIR/nvm.sh"

    # 安装 Node.js 24
    nvm install 24
    nvm alias default 24
    nvm use 24

    log_ok "Node.js 安装完成: $(node --version)"
    log_ok "npm 版本: $(npm --version)"
fi

# 7. 安装 OpenClaw-Termux
log_info "7/7 安装 OpenClaw-Cn-Termux..."

# 配置 npm 镜像（国内用户加速）
echo "是否使用国内 npm 镜像加速下载？"
read -p "使用国内镜像？(Y/n): " use_mirror
if [[ ! "$use_mirror" =~ ^[Nn]$ ]]; then
    npm config set registry https://registry.npmmirror.com
    log_ok "npm 镜像已设置为国内"
fi

# 选择包管理器
echo "选择包管理器:"
echo "  1) pnpm (推荐，更快)"
echo "  2) npm"
read -p "选择 [1-2]: " pm_choice

case "$pm_choice" in
    1)
        # 安装 pnpm
        if ! command -v pnpm &>/dev/null; then
            npm install -g pnpm
        fi
        PKG_CMD="pnpm add -g"
        ;;
    2)
        PKG_CMD="npm install -g"
        ;;
    *)
        log_warn "无效选择，默认使用 npm"
        PKG_CMD="npm install -g"
        ;;
esac

# 执行安装
log_info "正在安装 openclaw-cn-termux..."
if $PKG_CMD openclaw-cn-termux@latest; then
    log_ok "OpenClaw-CN 安装成功"
else
    log_error "安装失败，请检查网络或 npm 配置"
    exit 1
fi

# 验证安装
log_info "验证安装..."
if command -v openclaw-termux &>/dev/null; then
    OPENCLAW_CMD="openclaw-termux"
elif command -v openclaw-cn-termux &>/dev/null; then
    OPENCLAW_CMD="openclaw-termux"
else
    log_error "无法找到 openclaw-termux 命令"
    exit 1
fi

OPENCLAW_VER=$($OPENCLAW_CMD --version 2>&1 || echo "unknown")
log_ok "命令: $OPENCLAW_CMD"
log_ok "版本: $OPENCLAW_VER"

# 创建配置目录
mkdir -p "$HOME/.openclaw"

# 完成
cat <<EOF

${GREEN}╔══════════════════════════════════════════════╗${NC}
${GREEN}║   OpenClaw-Termux 安装成功！                   ║${NC}
${GREEN}╚══════════════════════════════════════════════╝${NC}

安装信息:
  - 用户: $USER
  - 家目录: $HOME
  - 命令: $OPENCLAW_CMD
  - 版本: $OPENCLAW_VER
  - 配置目录: \$HOME/.openclaw/

下一步操作:

1. **运行配置向导**:
   ${BLUE}$OPENCLAW_CMD onboard${NC}

   或手动编辑配置文件:
   ${BLUE}nano $HOME/.openclaw/openclaw.json${NC}

   最小配置示例:
   {
     "agent": {
       "model": "anthropic/claude-sonnet-4-5",
       "apiKey": "sk-your-api-key"
     },
     "gateway": {
       "port": 18789,
       "token": "your-token"
     }
   }

2. **启动 Gateway**:
   ${BLUE}$OPENCLAW_CMD gateway${NC}

3. **访问 Web 控制界面**:
   http://localhost:18789  
  或 ***访问openclaw-termux tui***：
   openclaw-termux tui

4. **后台运行** (可选):
   nohup $OPENCLAW_CMD gateway > ~/.openclaw/gateway.log 2>&1 &

更多帮助:
   ${BLUE}$OPENCLAW_CMD --help${NC}

祝你好运！🎉

EOF
