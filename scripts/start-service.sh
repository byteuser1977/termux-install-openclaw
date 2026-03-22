#!/data/data/com.termux/files/usr/bin/bash
# OpenClaw 服务启动脚本
# 将 OpenClaw 作为后台服务运行（适用于 Termux）

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
OPENCLAW_BIN="$PREFIX/bin/openclaw"
PID_FILE="$HOME/.openclaw/openclaw.pid"
LOG_FILE="$HOME/.openclaw/service.log"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_info()  { log "${BLUE}[INFO]${NC} $*"; }
log_ok()    { log "${GREEN}[OK]${NC} $*"; }
log_warn()  { log "${YELLOW}[WARN]${NC} $*"; }
log_error() { log "${RED}[ERR]${NC} $*"; }

# 检查是否已安装
if [ ! -x "$OPENCLAW_BIN" ]; then
    log_error "OpenClaw 未安装或不可执行: $OPENCLAW_BIN"
    log_error "请先运行 install.sh 完成安装"
    exit 1
fi

# 检查是否已经在运行
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        log_warn "OpenClaw 已在运行 (PID: $OLD_PID)"
        log_warn "如需重启，请先运行: $SCRIPT_DIR/stop-service.sh"
        exit 0
    else
        log_info "清理僵死进程记录..."
        rm -f "$PID_FILE"
    fi
fi

# 准备用户配置目录
mkdir -p "$HOME/.openclaw"

# 设置环境变量
export OPENCLAW_CONFIG="${OPENCLAW_CONFIG:-$HOME/.openclaw/config.ini}"
export OPENCLAW_DEBUG="${OPENCLAW_DEBUG:-0}"
export SDL_RENDER_DRIVER="${SDL_RENDER_DRIVER:-auto}"
export DISPLAY="${DISPLAY:-:0}"

# 记录启动信息
log "========================================="
log " starting OpenClaw service"
log " binary: $OPENCLAW_BIN"
log " config: $OPENCLAW_CONFIG"
log " log: $LOG_FILE"
log "========================================="

# 启动 OpenClaw
# 注意：-Termux 环境可能需要 X11 支持
# 如果使用 X11，确保 termux-x11 正在运行

# 获取当前脚本的绝对路径作为工作目录
cd "$PROJECT_DIR"

# 启动并重定向输出
if [ "$OPENCLAW_DEBUG" = "1" ]; then
    log_info "调试模式已启用，详细日志将输出到 $LOG_FILE"
    "$OPENCLAW_BIN" 2>&1 | tee -a "$LOG_FILE" &
else
    "$OPENCLAW_BIN" > "$LOG_FILE" 2>&1 &
fi

# 保存 PID
OPENCLAW_PID=$!
echo "$OPENCLAW_PID" > "$PID_FILE"

log_ok "OpenClaw 已启动 (PID: $OPENCLAW_PID)"
log ""
log " 查看日志: tail -f $LOG_FILE"
log " 停止服务: $SCRIPT_DIR/stop-service.sh"
log " 检查状态: $SCRIPT_DIR/check-deps.sh"
log ""

exit 0
