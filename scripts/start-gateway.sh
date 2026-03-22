#!/data/data/com.termux/files/usr/bin/bash
# OpenClaw Gateway 启动脚本
# 将 OpenClaw gateway 作为后台服务运行

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_DIR="${OPENCLAW_INSTALL_DIR:-$PROJECT_DIR/openclaw}"
PID_FILE="$HOME/.openclaw/gateway.pid"
LOG_FILE="$HOME/.openclaw/gateway.log"

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

# 检查安装
if [ ! -f "$INSTALL_DIR/dist/index.js" ]; then
    log_error "OpenClaw 未构建，请先运行 install.sh"
    exit 1
fi

# 检查是否已经运行
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        log_warn "OpenClaw Gateway 已在运行 (PID: $OLD_PID)"
        exit 0
    else
        log_info "清理僵死进程记录..."
        rm -f "$PID_FILE"
    fi
fi

# 准备日志和运行时目录
mkdir -p "$HOME/.openclaw/logs"

# 加载用户配置
CONFIG_FILE="${OPENCLAW_CONFIG:-$HOME/.openclaw/openclaw.json}"
if [ ! -f "$CONFIG_FILE" ]; then
    log_error "配置文件不存在: $CONFIG_FILE"
    log_error "请先运行安装或编辑 $HOME/.openclaw/openclaw.json"
    exit 1
fi

log "========================================="
log " starting OpenClaw Gateway"
log " config: $CONFIG_FILE"
log " log: $LOG_FILE"
log "========================================="

# 进入项目目录
cd "$INSTALL_DIR"

# 启动 gateway（后台）
# 使用 pnpm 确保正确的 PATH
pnpm start:gateway > "$LOG_FILE" 2>&1 &
OPENCLAW_PID=$!

# 保存 PID
echo "$OPENCLAW_PID" > "$PID_FILE"

# 等待几秒检查是否正常启动
sleep 3
if kill -0 "$OPENCLAW_PID" 2>/dev/null; then
    log_ok "Gateway 已启动 (PID: $OPENCLAW_PID)"

    # 读取端口信息
    if grep -q "Gateway listening on" "$LOG_FILE"; then
        PORT=$(grep -oP 'port \K\d+' "$LOG_FILE" | head -1)
        if [ -n "$PORT" ]; then
            log_ok "服务地址: http://localhost:$PORT"
        fi
    fi

    log ""
    log " 查看日志: tail -f $LOG_FILE"
    log " 停止服务: $SCRIPT_DIR/stop-gateway.sh"
    log " 检查状态: curl http://localhost:$PORT/health 2>/dev/null || echo '服务未就绪'"
    log ""
else
    log_error "Gateway 启动失败，查看日志:"
    tail -20 "$LOG_FILE" || true
    rm -f "$PID_FILE"
    exit 1
fi

exit 0
