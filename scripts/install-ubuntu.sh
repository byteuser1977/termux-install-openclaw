#!/data/data/com.termux/files/usr/bin/bash
# Termux 一键安装 Ubuntu 脚本
# 在 Termux 环境中运行，自动完成环境配置和 Ubuntu 安装

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERR]${NC} $*"; }

# 是否在 Termux 中
if [ -z "$PREFIX" ]; then
    log_error "请在 Termux 中运行此脚本"
    exit 1
fi

log_info "=========================================="
log_info " Termux Ubuntu 一键安装脚本"
log_info "=========================================="
echo ""

# 1. 更新包管理器
log_info "1/5 更新包管理器..."
apt update -y
apt upgrade -y
log_ok "包管理器已更新"

# 2. 安装基础工具
log_info "2/5 安装基础工具..."
apt install -y \
    termux-services \
    termux-tools \
    termux-api \
    proot-distro \
    curl \
    wget \
    ca-certificates
log_ok "基础工具安装完成"

# 3. 授权存储访问
log_info "3/5 配置存储权限..."
if [ ! -L "$HOME/storage/shared" ]; then
    termux-setup-storage
    log_ok "存储权限已配置"
else
    log_ok "存储权限已配置（跳过）"
fi

# 4. 设置镜像加速（可选）
log_info "4/5 镜像配置（可选）"
echo "是否使用国内镜像加速 Ubuntu 下载？"
echo "  1) 清华镜像 (推荐)"
echo "  2) 官方源"
echo "  3) 跳过"
read -p "选择 [1-3]: " mirror_choice

case "$mirror_choice" in
    1)
        export PROOT_DISTRO_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/termux/proot-distro"
        log_ok "已设置清华镜像"
        ;;
    2)
        unset PROOT_DISTRO_MIRROR
        log_ok "使用官方源"
        ;;
    3)
        unset PROOT_DISTRO_MIRROR
        log_ok "跳过镜像配置"
        ;;
    *)
        log_warn "无效选择，使用官方源"
        unset PROOT_DISTRO_MIRROR
        ;;
esac

# 5. 安装 Ubuntu
log_info "5/5 安装 Ubuntu（这需要 10-20 分钟）..."
echo ""
log_info "正在执行: proot-distro install ubuntu"
echo "下载大小: ~200-300 MB"
echo "请耐心等待..."
echo ""

if proot-distro install ubuntu; then
    log_ok "Ubuntu 安装成功！"
else
    log_error "Ubuntu 安装失败，请检查网络连接"
    exit 1
fi

# 完成
cat <<EOF

${GREEN}╔══════════════════════════════════════════════╗${NC}
${GREEN}║   Ubuntu 安装完成！                       ║${NC}
${GREEN}╚══════════════════════════════════════════════╝${NC}

下一步操作：

1. **登录 Ubuntu**:
   ${BLUE}proot-distro login ubuntu${NC}

2. **在 Ubuntu 中运行 OpenClaw 安装脚本**:
   进入 Ubuntu 后，执行:
   ${BLUE}cd ~ && curl -fsSL https://raw.githubusercontent.com/byteuser1977/termux-install-openclaw/main/scripts/install-openclaw.sh | bash${NC}

   或如果已克隆本项目:
   ${BLUE}./scripts/install-openclaw.sh${NC}

3. **配置并启动 OpenClaw**:
   安装完成后，在 Ubuntu 中:
   ${BLUE}openclaw-cn-termux onboard${NC}  # 配置
   ${BLUE}openclaw-cn-termux gateway${NC} # 启动

4. **访问 Web UI**:
   http://localhost:1880

查看详细文档:
   ${BLUE}cat termux-install-openclaw/document/installation.md${NC}

祝你好运！🎉

EOF
