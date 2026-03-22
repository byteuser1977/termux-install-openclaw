#!/data/data/com.termux/files/usr/bin/bash
# OpenClaw 依赖检查脚本
# 验证系统环境是否满足 OpenClaw 运行/编译要求

set -e

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

check_pass()   { echo -e "${GREEN}[✓]${NC} $*"; }
check_fail()  { echo -e "${RED}[✗]${NC} $*"; }
check_warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
info()        { echo -e "${BLUE}[i]${NC} $*"; }

ERRORS=0
WARNINGS=0

echo "=========================================="
echo " OpenClaw 依赖检查"
echo "=========================================="
echo ""

# 1. 检查 Termux 环境
info "1. Termux 环境"

if [ -f "$PREFIX/termux-info" ] || command -v termux-info &>/dev/null; then
    check_pass "Termux 环境检测到"
    termux-info 2>/dev/null | head -5 || true
else
    check_fail "未检测到 Termux 环境"
    ((ERRORS++))
fi

# 2. 检查架构
info "2. 系统架构"
ARCH=$(uname -m)
case "$ARCH" in
    aarch64|arm64)
        check_pass "架构: $ARCH (推荐)"
        ;;
    armv7l|arm)
        check_warn "架构: $ARCH (32位，性能可能受限)"
        ((WARNINGS++))
        ;;
    *)
        check_fail "架构: $ARCH (不支持)"
        ((ERRORS++))
        ;;
esac

# 3. 检查 Android API Level
info "3. Android API Level"
if [ -f "/system/build.prop" ]; then
    API_LEVEL=$(getprop ro.build.version.sdk 2>/dev/null || echo "unknown")
    if [ "$API_LEVEL" -ge 24 ] 2>/dev/null; then
        check_pass "API Level: $API_LEVEL"
    else
        check_fail "API Level: $API_LEVEL (需要 ≥ 24)"
        ((ERRORS++))
    fi
else
    check_warn "无法检测 API Level"
    ((WARNINGS++))
fi

# 4. 检查磁盘空间
info "4. 磁盘空间"
AVAIL_SPACE=$(df -k $HOME 2>/dev/null | tail -1 | awk '{print $4}')
if [ -n "$AVAIL_SPACE" ]; then
    AVAIL_MB=$((AVAIL_SPACE / 1024))
    if [ $AVAIL_MB -ge 1024 ]; then
        check_pass "可用空间: ${AVAIL_MB} MB"
    elif [ $AVAIL_MB -ge 512 ]; then
        check_warn "可用空间: ${AVAIL_MB} MB (建议 ≥ 1GB)"
        ((WARNINGS++))
    else
        check_fail "可用空间: ${AVAIL_MB} MB (不足)"
        ((ERRORS++))
    fi
else
    check_warn "无法获取磁盘空间信息"
    ((WARNINGS++))
fi

# 5. 检查必需工具
info "5. 基础工具链"

check_cmd() {
    if command -v "$1" &>/dev/null; then
        VERSION=$($1 --version 2>&1 | head -1)
        check_pass "$1: $VERSION"
        return 0
    else
        check_fail "$1: 未安装"
        return 1
    fi
}

check_cmd git || ((ERRORS++))
check_cmd cmake || ((ERRORS++))
check_cmd make || ((ERRORS++))
check_cmd gcc || ((ERRORS++))
check_cmd pkg-config || ((ERRORS++))

# 6. 检查 SDL2 库
info "6. SDL2 多媒体库"

check_sdl2_pkg() {
    if pkg list-installed 2>/dev/null | grep -q "^$1/"; then
        check_pass "$1 已安装"
        return 0
    else
        check_fail "$1 未安装"
        return 1
    fi
}

check_sdl2_pkg sdl2 || ((ERRORS++))
check_sdl2_pkg sdl2_image || ((ERRORS++))
check_sdl2_pkg sdl2_mixer || ((ERRORS++))
check_sdl2_pkg sdl2_ttf || ((ERRORS++))
check_sdl2_pkg sdl2_gfx || ((ERRORS++))

# 7. 检查其他库
info "7. 运行时依赖"

pkg list-installed 2>/dev/null | grep -q "^libiconv/" && check_pass "libiconv" || { check_fail "libiconv"; ((ERRORS++)); }
pkg list-installed 2>/dev/null | grep -q "^zlib/" && check_pass "zlib" || { check_fail "zlib"; ((ERRORS++)); }

# 8. 检查 OpenClaw 二进制文件
info "8. OpenClaw 安装状态"
if [ -x "$PREFIX/bin/openclaw" ]; then
    check_pass "OpenClaw 已安装"
    if "$PREFIX/bin/openclaw" --version &>/dev/null; then
        VERSION=$("$PREFIX/bin/openclaw" --version 2>&1 | head -1)
        info "  版本: $VERSION"
    fi
else
    check_warn "OpenClaw 未安装或不在 PATH 中"
    ((WARNINGS++))
fi

# 9. 检查 X11 支持（可选）
info "9. X11 显示服务（可选）"
if command -v termux-x11 &>/dev/null; then
    check_pass "termux-x11 已安装"
    if pgrep -f termux-x11 >/dev/null 2>&1; then
        check_pass "X11 服务正在运行"
    else
        check_warn "X11 服务未运行"
        info "  启动: termux-x11 :0 &"
        ((WARNINGS++))
    fi
else
    check_warn "termux-x11 未安装（如需图形界面请安装）"
    info "  安装: pkg install x11-repo && pkg install termux-x11-nightly"
    ((WARNINGS++))
fi

# 10. 检查用户配置目录
info "10. 用户配置"
if [ -d "$HOME/.openclaw" ]; then
    check_pass "配置目录存在: $HOME/.openclaw"
else
    check_warn "配置目录不存在（首次运行会自动创建）"
    ((WARNINGS++))
fi

# 总结
echo ""
echo "=========================================="
echo " 检查完成"
echo "=========================================="
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}所有检查通过！系统已就绪。${NC}"
    echo "您可以通过以下命令启动 OpenClaw:"
    echo "  openclaw"
    echo "或使用服务脚本:"
    echo "  $PREFIX/share/openclaw/scripts/start-service.sh"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}发现 $WARNINGS 个警告${NC}"
    echo "系统基本可用，但建议处理上述警告项。"
    exit 0
else
    echo -e "${RED}发现 $ERRORS 个错误, $WARNINGS 个警告${NC}"
    echo "请解决上述问题后再尝试安装或运行 OpenClaw。"
    echo ""
    echo "快速修复建议："
    echo "  1. 更新包列表: pkg update -y"
    echo "  2. 安装依赖: pkg install -y git cmake sdl2 sdl2_image sdl2_mixer sdl2_ttf sdl2_gfx libiconv zlib"
    echo "  3. 重新运行检查: $0"
    exit 1
fi
