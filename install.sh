#!/data/data/com.termux/files/usr/bin/bash
# Termux OpenClaw 安装脚本入口
# 实际安装逻辑位于 scripts/install.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/scripts/install.sh" "$@"
