#!/data/data/com.termux/files/usr/bin/bash

# ============================================================================
# Termux OpenClaw 自动化安装脚本
# 项目: termux-install-openclaw
# 版本: 1.0.0-alpha
# 作者: byteuser1977
# 许可证: MIT
# ============================================================================

set -e  # 遇到错误立即退出
set -u  # 未定义变量报错

# -------------------- 配置变量 --------------------
OPENCLAW_REPO="${OPENCLAW_REPO:-https://github.com/OpenClaw/OpenClaw.git}"
OPENCLAW_BRANCH="${OPENCLAW_BRANCH:-master}"
INSTALL_PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
BUILD_DIR="${OPENCLAWDIR:-${PWD}/build}"
SOURCE_DIR="${OPENCLAWDIR:-${PWD}/src}"
PROJECT_DIR="${PWD}"
CONFIG_DIR="${PWD}/config"
DOCUMENT_DIR="${PWD}/document"
RELEASE_DIR="${PWD}/release"

# 日志颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# -------------------- 辅助函数 --------------------
log_info()   { echo -e "${BLUE}[INFO]${NC} $*" >&2; }
log_ok()     { echo -e "${GREEN}[OK]${NC} $*" >&2; }
log_warn()   { echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
log_error()  { echo -e "${RED}[ERR]${NC} $*" >&2; }

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查架构
check_architecture() {
    log_info "检查系统架构..."
    local arch=$(uname -m)
    case "$arch" in
        aarch64|arm64)
            log_ok "架构: $arch (ARM64) - 支持"
            OPENCLAW_ARCH="arm64"
            ;;
        armv7l|arm)
            log_warn "架构: $arch (ARM32) - 可能性能受限"
            OPENCLAW_ARCH="arm"
            ;;
        *)
            log_error "不支持的架构: $arch"
            exit 1
            ;;
    esac
}

# 检查 Termux 环境
check_termux() {
    log_info "验证 Termux 环境..."
    if [ ! -f "$PREFIX/termux-info" ] && ! command_exists termux-info; then
        log_warn "未检测到 Termux 环境，继续但可能遇到问题..."
    else
        log_ok "Termux 环境正常"
    fi
}

# 更新包管理器
update_packages() {
    log_info "更新包列表..."
    pkg update -y
    log_ok "包列表已更新"
}

# 安装构建依赖
install_dependencies() {
    log_info "安装编译依赖..."

    local deps=(
        git
        curl
        wget
        ca-certificates
        build-essential
        cmake
        pkg-config
        sdl2
        sdl2_image
        sdl2_mixer
        sdl2_ttf
        sdl2_gfx
        libiconv
        zlib
    )

    for dep in "${deps[@]}"; do
        if ! pkg list-installed 2>/dev/null | grep -q "^$dep/"; then
            log_info "安装: $dep"
            pkg install -y "$dep"
        else
            log_ok "已安装: $dep"
        fi
    done

    log_ok "所有依赖已就绪"
}

# 获取 OpenClaw 源码
fetch_source() {
    log_info "获取 OpenClaw 源码 (branch: $OPENCLAW_BRANCH)..."

    # 如果源码目录已存在，先清理
    if [ -d "$SOURCE_DIR" ]; then
        log_warn "源码目录已存在，将重新克隆"
        rm -rf "$SOURCE_DIR"
    fi

    # 如果已存在 release 目录的 tarball，优先使用
    if [ -f "$RELEASE_DIR/openclaw-latest.tar.gz" ]; then
        log_info "使用本地 release 包..."
        mkdir -p "$SOURCE_DIR"
        tar -xzf "$RELEASE_DIR/openclaw-latest.tar.gz" -C "$SOURCE_DIR" --strip-components=1
    else
        # 克隆仓库
        git clone --depth 1 --branch "$OPENCLAW_BRANCH" "$OPENCLAW_REPO" "$SOURCE_DIR"
    fi

    log_ok "源码已获取"
}

# 构建 OpenClaw
build_openclaw() {
    log_info "开始编译 OpenClaw..."

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    # 复制默认配置
    if [ -d "$CONFIG_DIR" ]; then
        log_info "复制配置文件..."
        cp -r "$CONFIG_DIR/." ./
    fi

    # CMake 配置
    log_info "运行 CMake 配置..."
    cmake \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
        -DCMAKE_BUILD_TYPE=Release \
        "$SOURCE_DIR"

    # 编译
    log_info "开始编译（这可能需要几分钟到几十分钟）..."
    local cpu_cores=$(nproc 2>/dev/null || echo 2)
    cmake --build . -- -j"$cpu_cores"

    log_ok "编译完成"
}

# 安装 OpenClaw
install_openclaw() {
    log_info "安装 OpenClaw 到 $INSTALL_PREFIX..."

    cd "$BUILD_DIR"
    cmake --install .

    # 安装 Termux 特定脚本
    log_info "安装 Termux 服务脚本..."
    local scripts_install_dir="$INSTALL_PREFIX/share/openclaw/scripts"
    mkdir -p "$scripts_install_dir"
    cp -r "$SCRIPT_DIR/." "$scripts_install_dir/"
    chmod +x "$scripts_install_dir"/*.sh

    # 创建用户配置目录
    mkdir -p "$HOME/.openclaw"

    log_ok "OpenClaw 已安装"
}

# 验证安装
verify_installation() {
    log_info "验证安装..."

    if [ -x "$INSTALL_PREFIX/bin/openclaw" ]; then
        log_ok "二进制文件存在: $INSTALL_PREFIX/bin/openclaw"

        # 检查版本信息
        if "$INSTALL_PREFIX/bin/openclaw" --version >/dev/null 2>&1; then
            "$INSTALL_PREFIX/bin/openclaw" --version || true
        fi

        return 0
    else
        log_error "安装验证失败：未找到 openclaw 可执行文件"
        return 1
    fi
}

# 显示完成信息
show_completion() {
    cat <<EOF

${GREEN}╔══════════════════════════════════════════════╗${NC}
${GREEN}║   OpenClaw 安装成功！                     ║${NC}
${GREEN}╚═══════════════════════════════════════════╝${NC}

使用方法：
  ${BLUE}$INSTALL_PREFIX/bin/openclaw${NC}
  或简写：
  ${BLUE}openclaw${NC}

配置文件：
  系统: $INSTALL_PREFIX/etc/openclaw/config.ini
  用户: $HOME/.openclaw/config.ini

服务脚本（后台运行）：
  启动: $INSTALL_PREFIX/share/openclaw/scripts/start-service.sh
  停止: $INSTALL_PREFIX/share/openclaw/scripts/stop-service.sh
  检查: $INSTALL_PREFIX/share/openclaw/scripts/check-deps.sh

  或直接运行（脚本会在安装目录）：
  ${BLUE}$PROJECT_DIR/scripts/start-service.sh${NC}

文档：
  安装手册: ${DOCUMENT_DIR}/installation.md
  故障排除: ${DOCUMENT_DIR}/troubleshooting.md
  FAQ:      ${DOCUMENT_DIR}/faq.md

享受游戏！🎮

EOF
}

# -------------------- 主流程 --------------------
main() {
    echo ""
    log_info "=========================================="
    log_info " Termux OpenClaw 安装脚本 v1.0.0-alpha"
    log_info "=========================================="
    echo ""

    # 确认在 Termux 环境
    check_termux

    # 检查架构
    check_architecture

    # 确认权限
    if [ "$(id -u)" -eq 0 ]; then
        log_warn "检测到 root 权限，Termux 通常不需要 root"
    fi

    # 询问用户（交互模式）
    if [ -t 0 ]; then
        echo "即将执行以下操作："
        echo "  1. 更新包管理器"
        echo "  2. 安装构建依赖 (约500MB空间)"
        echo "  3. 下载 OpenClaw 源码"
        echo "  4. 编译并安装"
        echo ""
        read -p "确认继续？(y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info "安装已取消"
            exit 0
        fi
    fi

    # 执行安装步骤
    update_packages
    install_dependencies
    fetch_source
    build_openclaw
    install_openclaw

    if verify_installation; then
        show_completion
        exit 0
    else
        log_error "安装失败，请检查上述日志"
        exit 1
    fi
}

# 捕获异常
trap 'log_error "安装过程中断，请查看日志"; exit 1' INT TERM

# 运行主函数
main "$@"