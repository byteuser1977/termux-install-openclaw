#!/usr/bin/env bash
# Ubuntu 一键安装 OpenClaw-CN 脚本 - Part 1
# 在 Ubuntu (proot-distro) 环境中以 root 身份运行
# 完成系统配置后，切换到 openclaw 用户执行 Part 2

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
log_info " OpenClaw-Termux 安装脚本 - 系统配置阶段"
log_info "=========================================="
echo ""

# 1. 更新系统
log_info "1/4 更新系统包..."
apt update -y
apt upgrade -y
log_ok "系统已更新"

# 2. 安装必要软件
log_info "2/4 安装必要软件包..."
apt install -y \
    sudo \
    ssh \
    nginx \
    curl \
    wget \
    ca-certificates \
    jq \
    locales \
    language-pack-zh-hans \
    git
log_ok "软件包安装完成"

# 3. 配置中文 locale
log_info "3/4 配置中文环境..."
if ! locale -a | grep -q "zh_CN.utf8"; then
    locale-gen zh_CN.UTF-8
fi
update-locale LANG=zh_CN.UTF-8
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
log_ok "中文环境已配置"

# 4. 创建 openclaw 用户（如果不存在）
log_info "4/4 检查 openclaw 用户..."
if ! id "openclaw" &>/dev/null; then
    log_info "创建 openclaw 用户..."
    adduser --disabled-password --gecos "" openclaw
    usermod -aG sudo openclaw
    log_ok "用户 openclaw 已创建"
else
    log_ok "用户 openclaw 已存在"
fi

echo ""
log_info "=========================================="
log_info " 系统配置完成！"
log_info "=========================================="
echo ""

# 切换到 openclaw 用户执行 Part 2
log_info "即将切换到 openclaw 用户继续安装..."
echo ""
echo "你可以选择以下方式继续："
echo ""
echo "方式 1: 自动下载并执行安装脚本（推荐）"
echo "  脚本将自动切换到 openclaw 用户并继续安装"
echo ""
echo "方式 2: 手动切换用户后执行"
echo "  执行: su - openclaw"
echo "  然后运行安装脚本"
echo ""

read -p "选择方式 [1/2]: " choice

case "$choice" in
    1)
        log_info "切换到 openclaw 用户并下载执行安装脚本..."
        # 使用 su 切换到 openclaw 用户，然后通过 curl 下载执行 Part 2
        exec su - openclaw -c "curl -fsSL https://raw.githubusercontent.com/byteuser1977/termux-install-openclaw/main/scripts/install-openclaw-user.sh | bash"
        ;;
    2)
        echo ""
        log_info "请在 openclaw 用户下执行以下命令："
        echo ""
        echo "  su - openclaw"
        echo "  curl -fsSL https://raw.githubusercontent.com/byteuser1977/termux-install-openclaw/main/scripts/install-openclaw-user.sh | bash"
        echo ""
        log_info "或者使用本地脚本（如果已下载）："
        echo "  su - openclaw"
        echo "  bash install-openclaw-user.sh"
        echo ""
        exit 0
        ;;
    *)
        log_warn "无效选择，默认使用方式 1"
        exec su - openclaw -c "curl -fsSL https://raw.githubusercontent.com/byteuser1977/termux-install-openclaw/main/scripts/install-openclaw-user.sh | bash"
        ;;
esac
