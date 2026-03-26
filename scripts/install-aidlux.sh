#!/usr/bin/env bash
# AidLux 一键安装 OpenClaw-CN 脚本
# 在 AidLux 环境中运行

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

is_interactive() {
    [ -t 0 ] || return 1
}

read_input() {
    local prompt="$1"
    local var_name="$2"
    local default="$3"
    if is_interactive; then
        read -p "$prompt" "$var_name"
    else
        log_warn "非交互环境，使用默认值: $default"
        eval "$var_name=$default"
    fi
}

# 检查是否在 Linux 环境中
if ! command -v apt &>/dev/null; then
    log_error "请在 Linux (AidLux) 环境中运行此脚本"
    exit 1
fi

log_info "=========================================="
log_info " OpenClaw-Termux 一键安装脚本"
log_info "=========================================="
echo ""

# 1. 更新系统
log_info "1/4 更新系统包..."
apt update -y
log_ok "系统已更新"

# 当前用户就是 aidlux 用户
log_ok "当前用户: $USER"
log_ok "家目录: $HOME"

# 2. 安装 nvm 和 Node.js
echo ""
log_info "2/4 安装 nvm 和 Node.js..."

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

# 3. 安装 OpenClaw-CN
log_info "3/4 安装 OpenClaw-CN-Termux..."

# 配置 npm 镜像（国内用户加速）
echo "是否使用国内 npm 镜像加速下载？"
read_input "使用国内镜像？(Y/n): " use_mirror "Y"
if [[ ! "$use_mirror" =~ ^[Nn]$ ]]; then
    npm config set registry https://registry.npmmirror.com
    log_ok "npm 镜像已设置为国内"
fi

# 选择包管理器
echo "选择包管理器:"
echo "  1) pnpm (推荐，更快)"
echo "  2) npm"
read_input "选择 [1-2]: " pm_choice "2"

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

# 安装 strip-ansi 工具
$PKG_CMD strip-ansi  

# 执行安装
log_info "正在安装 openclaw-cn-termux..."
if $PKG_CMD openclaw-cn-termux@0.1.9-beta.8; then
    log_ok "OpenClaw-CN-Termux 安装成功"
else
    log_error "安装失败，请检查网络或 npm 配置"
    exit 1
fi

# 验证安装
log_info "验证安装..."
if command -v openclaw-termux &>/dev/null; then
    OPENCLAW_CMD="openclaw-termux"
elif command -v openclaw-cn-termux &>/dev/null; then
    OPENCLAW_CMD="openclaw-cn-termux"
else
    log_error "无法找到 openclaw-termux 命令"
    exit 1
fi

OPENCLAW_VER=$($OPENCLAW_CMD --version 2>&1 || echo "unknown")
log_ok "命令: $OPENCLAW_CMD"
log_ok "版本: $OPENCLAW_VER"

# 创建配置目录
mkdir -p "$HOME/.openclaw"

# 4. 完成
log_info "4/4 配置完成"

cat <<EOF

${GREEN}╔══════════════════════════════════════════════╗${NC}
${GREEN}║   OpenClaw-AidLux 安装成功！                   ║${NC}
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
   ${BLUE}$OPENCLAW_CMD tui${NC}

4. **后台运行** (可选):
   nohup $OPENCLAW_CMD gateway > ~/.openclaw/gateway.log 2>&1 &

更多帮助:
   ${BLUE}$OPENCLAW_CMD --help${NC}

祝你好运！🎉

EOF
