#!/data/data/com.termux/files/usr/bin/bash
# OpenClaw Gateway 停止脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$HOME/.openclaw/gateway.pid"
LOG_FILE="$HOME/.openclaw/gateway.log"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log_info()  { log "${BLUE}[INFO]${NC} $*"; }
log_ok()    { log "${GREEN}[OK]${NC} $*"; }
log_warn()  { log "${YELLOW}[WARN]${NC} $*"; }
log_error() { log "${RED}[ERR]${NC} $*"; }

# 检查 PID 文件
if [ ! -f "$PID_FILE" ]; then
    log_warn "PID 文件不存在，OpenClaw 可能未运行"
    exit 0
fi

PID=$(cat "$PID_FILE")

# 检查进程是否存在
if kill -0 "$PID" 2>/dev/null; then
    log_info "正在停止 OpenClaw Gateway (PID: $PID)..."
    kill "$PID"

    # 等待进程退出（最多 10 秒）
    TIMEOUT=10
    while [ $TIMEOUT -gt 0 ]; do
        if ! kill -0 "$PID" 2>/dev/null; then
            break
        fi
        sleep 1
        TIMEOUT=$((TIMEOUT - 1))
    done

    if kill -0 "$PID" 2>/dev/null; then
        log_warn "进程未在 10 秒内退出，强制终止..."
        kill -9 "$PID" 2>/dev/null || true
    fi

    # 清理 PID 文件
    rm -f "$PID_FILE"

    log_ok "OpenClaw Gateway 已停止"
else
    log_warn "进程 $PID 不存在，清理 PID 文件..."
    rm -f "$PID_FILE"
fi

exit 0
