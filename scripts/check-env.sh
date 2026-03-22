#!/data/data/com.termux/files/usr/bin/bash
# OpenClaw 环境检查脚本
# 验证 Termux 环境是否满足 OpenClaw 运行条件

set -e

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
HOME_DIR="${HOME}"

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
echo " OpenClaw 环境检查"
echo "=========================================="
echo ""

# 1. Termux 环境
info "1. Termux 环境"
if [ -n "$PREFIX" ] && [ -d "$PREFIX" ]; then
    check_pass "Termux 环境检测到 (PREFIX=$PREFIX)"
else
    check_warn "未检测到标准 Termux 环境"
    ((WARNINGS++))
fi

# 2. Android API Level
info "2. Android API Level"
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

# 3. 磁盘空间
info "3. 磁盘空间"
AVAIL_SPACE=$(df -k $HOME 2>/dev/null | tail -1 | awk '{print $4}')
if [ -n "$AVAIL_SPACE" ]; then
    AVAIL_MB=$((AVAIL_SPACE / 1024))
    if [ $AVAIL_MB -ge 2048 ]; then
        check_pass "可用空间: ${AVAIL_MB} MB"
    elif [ $AVAIL_MB -ge 1024 ]; then
        check_warn "可用空间: ${AVAIL_MB} MB (建议 ≥ 2GB)"
        ((WARNINGS++))
    else
        check_fail "可用空间: ${AVAIL_MB} MB (不足)"
        ((ERRORS++))
    fi
else
    check_warn "无法获取磁盘空间信息"
    ((WARNINGS++))
fi

# 4. Node.js
info "4. Node.js 环境"
if command_exists node; then
    NODE_VER=$(node --version 2>&1 | head -1)
    MAJOR=$(echo "$NODE_VER" | sed 's/v\([0-9]*\).*/\1/')
    if [ "$MAJOR" -ge 22 ]; then
        check_pass "Node.js: $NODE_VER"
    else
        check_warn "Node.js 版本过低: $NODE_VER (需要 ≥ 22)"
        ((WARNINGS++))
    fi
else
    check_fail "Node.js 未安装"
    ((ERRORS++))
fi

# 5. pnpm
info "5. pnpm 包管理器"
if command_exists pnpm; then
    check_pass "pnpm: $(pnpm --version 2>&1 | head -1)"
else
    check_warn "pnpm 未安装（安装脚本会自动安装）"
    ((WARNINGS++))
fi

# 6. Git
info "6. Git"
if command_exists git; then
    check_pass "git: $(git --version 2>&1 | head -1)"
else
    check_fail "git 未安装"
    ((ERRORS++))
fi

# 7. 安装状态
info "7. OpenClaw 安装状态"
INSTALL_DIR="${OPENCLAW_INSTALL_DIR:-$(pwd)/openclaw}"
if [ -f "$INSTALL_DIR/dist/index.js" ]; then
    check_pass "OpenClaw 已构建"
    if [ -f "$HOME/.openclaw/openclaw.json" ]; then
        check_pass "配置文件存在"
    else
        check_warn "配置文件缺失"
        ((WARNINGS++))
    fi
else
    check_warn "OpenClaw 未构建（运行 install.sh 安装）"
    ((WARNINGS++))
fi

# 8. 端口检查（可选）
info "8. 端口可用性检查（18789, 1880）"
for port in 18789 1880; do
    if lsof -i :$port >/dev/null 2>&1; then
        log_warn "端口 $port 已被占用"
    else
        check_pass "端口 $port 可用"
    fi
done

# 9. 网络连接
info "9. 网络连接"
if ping -c 1 -W 2 github.com >/dev/null 2>&1; then
    check_pass "可访问 GitHub"
else
    check_warn "无法访问 GitHub（可能影响下载）"
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
    echo "下一步："
    echo "  1. 编辑 ~/.openclaw/openclaw.json，配置 API Key"
    echo "  2. 运行: cd openclaw && pnpm start:gateway"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}发现 $WARNINGS 个警告${NC}"
    echo "系统基本可用，但建议处理上述警告项。"
    echo "运行 ./install.sh 开始安装"
    exit 0
else
    echo -e "${RED}发现 $ERRORS 个错误, $WARNINGS 个警告${NC}"
    echo "请解决上述问题后再尝试安装。"
    echo "建议："
    echo "  - pkg update -y"
    echo "  - pkg install -y nodejs git"
    exit 1
fi
