#!/data/data/com.termux/files/usr/bin/bash
# OpenClaw-CN-Termux 自动化安装脚本
# 项目: termux-install-openclaw
# 版本: 1.0.0-alpha (refactored)
# 许可证: MIT

set -e

# -------------------- 配置变量 --------------------
OPENCLAW_REPO="${OPENCLAW_REPO:-https://github.com/jiulingyun/openclaw-cn.git}"
OPENCLAW_BRANCH="${OPENCLAW_BRANCH:-main}"
INSTALL_DIR="${OPENCLAW_INSTALL_DIR:-${PWD}/openclaw}"
HOME_DIR="${HOME}"
CONFIG_DIR="${PWD}/config"
DOCUMENT_DIR="${PWD}/document"

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

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查并安装 Node.js
install_nodejs() {
    log_info "检查 Node.js 环境..."

    if command_exists node; then
        NODE_VERSION=$(node --version | awk '{print $1}' | sed 's/v//')
        MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
        if [ "$MAJOR" -ge 22 ]; then
            log_ok "Node.js 版本: $NODE_VERSION (满足 ≥22 要求)"
            return 0
        else
            log_warn "Node.js 版本过低: $NODE_VERSION (需要 ≥22)"
        fi
    fi

    log_info "通过 pkg 安装 Node.js..."
    pkg update -y
    pkg install -y nodejs

    if command_exists node; then
        log_ok "Node.js 安装完成: $(node --version)"
    else
        log_error "Node.js 安装失败"
        return 1
    fi
}

# 安装 pnpm
install_pnpm() {
    log_info "安装 pnpm 包管理器..."

    if command_exists pnpm; then
        log_ok "pnpm 已存在: $(pnpm --version)"
        return 0
    fi

    # 使用 corepack（Node.js 自带）
    if command_exists corepack; then
        corepack enable
        corepack prepare pnpm@latest --activate
    else
        #  fallback: npm 全局安装
        npm install -g pnpm
    fi

    if command_exists pnpm; then
        log_ok "pnpm 安装完成: $(pnpm --version)"
    else
        log_error "pnpm 安装失败"
        return 1
    fi
}

# 获取 OpenClaw 源码
fetch_source() {
    log_info "获取 OpenClaw-CN 源码 (branch: $OPENCLAW_BRANCH)..."

    if [ -d "$INSTALL_DIR" ]; then
        log_warn "安装目录已存在，将重新克隆"
        rm -rf "$INSTALL_DIR"
    fi

    git clone --depth 1 --branch "$OPENCLAW_BRANCH" "$OPENCLAW_REPO" "$INSTALL_DIR"

    log_ok "源码已获取到: $INSTALL_DIR"
}

# 安装依赖
install_dependencies() {
    log_info "安装项目依赖（这可能需要几分钟）..."

    cd "$INSTALL_DIR"

    # 设置 pnpm 配置（可选：加速下载）
    pnpm config set store-dir "$HOME/.pnpm-store"

    # 安装依赖
    pnpm install --frozen-lockfile

    log_ok "依赖安装完成"
}

# 构建项目
build_project() {
    log_info "构建 OpenClaw..."

    cd "$INSTALL_DIR"

    # 构建主程序和 UI
    pnpm build
    pnpm ui:build

    log_ok "构建完成"
}

# 配置系统
configure_system() {
    log_info "配置用户环境..."

    # 创建配置目录
    mkdir -p "$HOME/.openclaw"

    # 如果用户配置不存在，复制示例配置
    if [ ! -f "$HOME/.openclaw/openclaw.json" ]; then
        log_info "创建默认配置文件..."
        cp "$CONFIG_DIR/openclaw.json.example" "$HOME/.openclaw/openclaw.json"

        # 生成随机 gateway token
        if command_exists openssl; then
            TOKEN=$(openssl rand -hex 32)
        elif command_exists python3; then
            TOKEN=$(python3 -c "import secrets; print(secrets.token_hex(32))")
        else
            TOKEN=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c64)
        fi

        # 替换 token
        sed -i "s/\${OPENCLAW_GATEWAY_TOKEN:-}/$TOKEN/" "$HOME/.openclaw/openclaw.json" 2>/dev/null || true

        log_ok "配置文件已创建: $HOME/.openclaw/openclaw.json"
    else
        log_warn "配置文件已存在，跳过: $HOME/.openclaw/openclaw.json"
    fi

    # 创建其他必要目录
    mkdir -p "$HOME/.openclaw/data" "$HOME/.openclaw/memory" "$HOME/.openclaw/logs"
}

# 验证安装
verify_installation() {
    log_info "验证安装..."

    if [ -f "$INSTALL_DIR/dist/index.js" ]; then
        log_ok "构建产物存在: $INSTALL_DIR/dist/index.js"
        return 0
    else
        log_error "构建产物缺失"
        return 1
    fi
}

# 显示完成信息
show_completion() {
    cat <<EOF

${GREEN}╔══════════════════════════════════════════════╗${NC}
${GREEN}║   OpenClaw 安装成功！                     ║${NC}
${GREEN}╚══════════════════════════════════════════════╝${NC}

使用方法：
  ${BLUE}cd $INSTALL_DIR${NC}
  ${BLUE}pnpm start:gateway${NC}      # 启动 gateway 服务
  ${BLUE}pnpm start${NC}                # 启动交互式 CLI

或使用全局命令（如果配置了 PATH）：
  ${BLUE}openclaw-cn gateway${NC}

配置文件：
  ${BLUE}$HOME/.openclaw/openclaw.json${NC}

默认配置：
  - Gateway 端口: 18789
  - UI 端口: 1880
  - 语言: 中文 (zh-CN)

文档：
  安装手册: ${DOCUMENT_DIR}/installation.md
  故障排除: ${DOCUMENT_DIR}/troubleshooting.md
  FAQ:      ${DOCUMENT_DIR}/faq.md

开始使用：
  1. 编辑配置文件，添加你的 AI 模型 API Key
  2. 运行: pnpm start:gateway
  3. 访问 http://localhost:1880 打开控制界面

祝你好运！🎉

EOF
}

# -------------------- 主流程 --------------------
main() {
    echo ""
    log_info "=========================================="
    log_info " Termux OpenClaw 安装脚本 v1.0.0-alpha"
    log_info "=========================================="
    echo ""

    # 检查 Termux 环境
    log_info "验证 Termux 环境..."
    if [ -z "$PREFIX" ]; then
        log_warn "未检测到 Termux 环境变量 PREFIX"
        log_warn "建议在 Termux 中运行此脚本"
    fi

    # 询问用户确认
    if [ -t 0 ]; then
        echo "即将执行以下操作："
        echo "  1. 安装/检查 Node.js ≥ 22"
        echo "  2. 安装 pnpm 包管理器"
        echo "  3. 下载 OpenClaw-CN 源码"
        echo "  4. 安装依赖并构建"
        echo "  5. 配置用户环境"
        echo ""
        read -p "确认继续？(y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info "安装已取消"
            exit 0
        fi
    fi

    # 执行安装步骤
    install_nodejs || exit 1
    install_pnpm || exit 1
    fetch_source
    install_dependencies
    build_project
    configure_system

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
