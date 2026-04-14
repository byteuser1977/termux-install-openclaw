#!/data/data/com.termux/files/usr/bin/bash
# Termux 一键安装 OpenClaw-cn-termux 脚本
# 在 Termux 环境中运行

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志输出函数
log_info()  { echo -e "${BLUE}[INFO]${NC} $*" >&2; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $*" >&2; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
log_error() { echo -e "${RED}[ERR]${NC} $*" >&2; }

# 检查是否为交互式终端
is_interactive() {
    [ -t 0 ] || return 1
}

# 读取用户输入（支持默认值）
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

# 检查是否在 Termux 环境中
check_termux_env() {
    if [ -z "$PREFIX" ] || [[ ! "$PREFIX" == *"com.termux"* ]]; then
        log_warn "未检测到 Termux 环境变量 PREFIX"
        log_warn "此脚本专为 Termux 设计，建议在 Termux 中运行"
        echo ""
        read_input "是否继续？(y/N): " force_continue "N"
        if [[ ! "$force_continue" =~ ^[Yy]$ ]]; then
            log_info "安装已取消"
            exit 0
        fi
    else
        log_ok "Termux 环境已确认: $PREFIX"
    fi
}

# 修复 Termux 剪贴板兼容性问题
fix_clipboard_for_termux() {
    local CLIPBOARD_INDEX_PATH="$PREFIX/lib/node_modules/openclaw-cn-termux/node_modules/@mariozechner/clipboard/index.js"
    local FIX_APPLIED=false
    
    if [ ! -f "$CLIPBOARD_INDEX_PATH" ]; then
        log_warn "未找到剪贴板模块，跳过修复"
        echo "false"
        return
    fi
    
    log_info "检测到剪贴板模块，应用 Termux 兼容修复..."
    
    # 备份原始文件
    if [ ! -f "$CLIPBOARD_INDEX_PATH.bak" ]; then
        cp "$CLIPBOARD_INDEX_PATH" "$CLIPBOARD_INDEX_PATH.bak"
        log_ok "已备份原始文件"
    fi
    
    # 检查是否已经修复过
    if grep -q "termux-clipboard-get" "$CLIPBOARD_INDEX_PATH" 2>/dev/null; then
        log_ok "剪贴板模块已修复，跳过"
        echo "true"
        return
    fi
    
    # 创建修复后的文件内容
    cat > "$CLIPBOARD_INDEX_PATH" << 'CLIPBOARD_EOF'
const { existsSync, readFileSync } = require('fs')
const { join } = require('path')

const { platform, arch } = process

let nativeBinding = null
let localFileExisted = false
let loadError = null

function isMusl() {
  let musl = false
  if (platform === 'linux') {
    musl = isMuslFromFilesystem()
    if (musl === null) {
      musl = isMuslFromReport()
    }
    if (musl === null) {
      musl = isMuslFromChildProcess()
    }
  }
  return musl
}

function isMuslFromFilesystem() {
  try {
    return readFileSync('/usr/bin/ldd', 'utf-8').includes('musl')
  } catch {
    return null
  }
}

function isMuslFromReport() {
  const report = typeof process.report.getReport === 'function' ? process.report.getReport() : null
  if (!report) {
    return null
  }
  if (report.header && report.header.glibcVersionRuntime) {
    return false
  }
  if (Array.isArray(report.sharedObjects)) {
    if (report.sharedObjects.some(isMuslSharedObject)) {
      return true
    }
  }
  return false
}

function isMuslFromChildProcess() {
  try {
    require('child_process').execSync('ldd --version', { encoding: 'utf-8' }).includes('musl')
  } catch {
    return true
  }
  return false
}

function isMuslSharedObject(a) {
  return a.includes('libc.musl-') || a.includes('ld-musl-')
}

switch (platform) {
  case 'android':
    switch (arch) {
      case 'arm64':
        // Use Termux clipboard commands for Android
        try {
          const { execFile } = require('child_process')
          const { promisify } = require('util')
          const execFileAsync = promisify(execFile)
          nativeBinding = {
            availableFormats: ['text/plain'],
            getText: async () => {
              try {
                const { stdout } = await execFileAsync('termux-clipboard-get')
                return stdout.toString().replace(/\n$/, '')
              } catch (e) {
                throw new Error('Failed to get clipboard text: ' + e.message)
              }
            },
            setText: async (text) => {
              try {
                await execFileAsync('termux-clipboard-set', [text])
              } catch (e) {
                throw new Error('Failed to set clipboard text: ' + e.message)
              }
            },
            hasText: async () => {
              try {
                await execFileAsync('termux-clipboard-get')
                return true
              } catch {
                return false
              }
            },
            getImageBinary: async () => null,
            getImageBase64: async () => null,
            setImageBinary: async () => { throw new Error('Clipboard image not supported') },
            setImageBase64: async () => { throw new Error('Clipboard image not supported') },
            hasImage: async () => false,
            getHtml: async () => null,
            setHtml: async () => { throw new Error('Clipboard HTML not supported') },
            hasHtml: async () => false,
            getRtf: async () => null,
            setRtf: async () => { throw new Error('Clipboard RTF not supported') },
            hasRtf: async () => false,
            clear: async () => { throw new Error('Clipboard clear not supported') },
            watch: (callback) => { return () => {} },
            callThreadsafeFunction: () => {}
          }
        } catch (e) {
          loadError = e
        }
        break
      default:
        throw new Error(`Unsupported architecture on Android: ${arch}`)
    }
    break
  default:
    throw new Error(`Unsupported OS: ${platform}, architecture: ${arch}`)
}

if (!nativeBinding) {
  if (loadError) {
    throw loadError
  }
  throw new Error(`Failed to load native binding`)
}

const { 
  availableFormats,
  getText,
  getImageBinary,
  getImageBase64,
  getHtml,
  getRtf,
  setText,
  setImageBinary,
  setImageBase64,
  setHtml,
  setRtf,
  clear,
  hasText,
  hasImage,
  hasHtml,
  hasRtf,
  watch,
  callThreadsafeFunction
} = nativeBinding

module.exports.availableFormats = availableFormats
module.exports.getText = getText
module.exports.getImageBinary = getImageBinary
module.exports.getImageBase64 = getImageBase64
module.exports.getHtml = getHtml
module.exports.getRtf = getRtf
module.exports.setText = setText
module.exports.setImageBinary = setImageBinary
module.exports.setImageBase64 = setImageBase64
module.exports.setHtml = setHtml
module.exports.setRtf = setRtf
module.exports.clear = clear
module.exports.hasText = hasText
module.exports.hasImage = hasImage
module.exports.hasHtml = hasHtml
module.exports.hasRtf = hasRtf
module.exports.watch = watch
module.exports.callThreadsafeFunction = callThreadsafeFunction
CLIPBOARD_EOF
    
    # 验证修复
    if grep -q "termux-clipboard-get" "$CLIPBOARD_INDEX_PATH" 2>/dev/null; then
        log_ok "剪贴板模块修复成功"
        FIX_APPLIED=true
    else
        log_warn "自动修复可能未完全成功，请手动参考文档修复"
        FIX_APPLIED=false
    fi
    
    echo "$FIX_APPLIED"
}

# ==================== 主程序开始 ====================

log_info "=========================================="
log_info " OpenClaw-Termux 一键安装脚本"
log_info "=========================================="
echo ""

# 检查环境
check_termux_env

# 显示当前用户信息
log_ok "当前用户: $USER"
log_ok "家目录: $HOME"
log_ok "PREFIX: $PREFIX"

# ========== 第1步：更新 Termux 包 ==========
echo ""
log_info "1/7 更新 Termux 包..."
pkg update -y
pkg upgrade -y
log_ok "Termux 包已更新"

# ========== 第2步：安装必要依赖 ==========
echo ""
log_info "2/7 安装必要依赖..."
pkg install -y \
    git \
    curl \
    wget \
    openssl \
    python \
    nodejs \
    openssh \
    2>/dev/null || {
        log_warn "部分包可能已安装，继续..."
    }
log_ok "依赖安装完成"

# ========== 第3步：安装 Node.js 工具 ==========
echo ""
log_info "3/7 安装 Node.js 工具..."

# 显示 Node.js 版本
log_ok "Node.js 版本: $(node --version)"
log_ok "npm 版本: $(npm --version)"

# 安装 pnpm 和 nrm
npm install -g pnpm nrm
log_ok "pnpm 和 nrm 已安装"

# ========== 第4步：安装 OpenClaw-cn-Termux ==========
echo ""
log_info "4/7 安装 OpenClaw-CN-Termux..."

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
        # 确保 pnpm 已安装
        if ! command -v pnpm &>/dev/null; then
            log_info "安装 pnpm..."
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
log_info "安装 strip-ansi..."
$PKG_CMD strip-ansi 2>/dev/null || log_warn "strip-ansi 可能已安装"

# 执行 OpenClaw 安装
log_info "正在安装 openclaw-cn-termux..."
if $PKG_CMD openclaw-cn-termux@0.2.1-beta.1; then
    log_ok "OpenClaw-CN-Termux 安装成功"
else
    log_error "安装失败，请检查网络或 npm 配置"
    exit 1
fi

# ========== 第5步：创建配置目录和配置文件 ==========
echo ""
log_info "5/7 配置 OpenClaw..."

# 创建配置目录
mkdir -p "$HOME/.openclaw"

# 创建默认配置文件（如果不存在）
if [ ! -f "$HOME/.openclaw/openclaw.json" ]; then
    log_info "创建默认配置文件..."
    
    # 生成随机 gateway token
    if command -v openssl &>/dev/null; then
        TOKEN=$(openssl rand -hex 32)
    elif command -v python3 &>/dev/null; then
        TOKEN=$(python3 -c "import secrets; print(secrets.token_hex(32))")
    else
        TOKEN=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c64)
    fi
    
    cat > "$HOME/.openclaw/openclaw.json" <<EOF
{
  "agent": {
    "model": "anthropic/claude-sonnet-4-5",
    "apiKey": "sk-your-api-key"
  },
  "gateway": {
    "port": 18789,
    "token": "$TOKEN"
  }
}
EOF
    log_ok "配置文件已创建: $HOME/.openclaw/openclaw.json"
else
    log_warn "配置文件已存在，跳过创建"
fi

# 创建其他必要目录
mkdir -p "$HOME/.openclaw/data" "$HOME/.openclaw/memory" "$HOME/.openclaw/logs"

# ========== 第6步：修复 Termux 剪贴板问题 ==========
echo ""
log_info "6/7 修复 Termux 剪贴板兼容性问题..."

CLIPBOARD_FIX_APPLIED=$(fix_clipboard_for_termux)

# ========== 第7步：验证安装 ==========
echo ""
log_info "7/7 验证安装..."

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

# ========== 安装完成 ==========
echo ""
log_info "=========================================="
log_info " 安装完成！"
log_info "=========================================="

# 显示剪贴板修复状态
if [ "$CLIPBOARD_FIX_APPLIED" = true ]; then
    log_ok "✓ Termux 剪贴板兼容性修复已应用"
fi

cat <<EOF

${GREEN}╔══════════════════════════════════════════════╗${NC}
${GREEN}║   OpenClaw-Termux 安装成功！                   ║${NC}
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
   或 ***访问 openclaw-termux tui***：
   ${BLUE}$OPENCLAW_CMD tui${NC}

4. **后台运行** (可选):
   nohup $OPENCLAW_CMD gateway > ~/.openclaw/gateway.log 2>&1 &

5. **Termux 保活建议**:
   - 在 Termux 设置中开启 "Acquire Wakelock"
   - 使用 termux-wake-lock 保持 CPU 唤醒
   - 考虑使用 systemd 或 termux-services 管理后台进程

更多帮助:
   ${BLUE}$OPENCLAW_CMD --help${NC}

祝你好运！🎉

EOF
