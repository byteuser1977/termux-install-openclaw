# Termux Install OpenClaw

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Termux](https://img.shields.io/badge/Termux-Install-blue)](https://termux.com)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-AI-Assistant-green)](https://github.com/OpenClaw/OpenClaw)

**在 Android Termux 环境中自动化安装和运行 OpenClaw（AI 智能助手系统）**

---

## 📖 关于本项目

### 什么是 Termux？

**Termux** 是一款强大的 Android 终端模拟器和 Linux 环境应用，它提供了一个完整的包管理器和命令行工具链，无需 root 权限即可在手机上运行 Linux 软件。Termux 支持：

- 完整的 Bash/Zsh  Shell
- 包管理器（apt-like `pkg`）
- 编译工具链（gcc, clang, make, cmake）
- 版本控制（git, svn）
- 脚本语言（Python, Node.js, Ruby, Lua 等）
- 网络工具（ssh, curl, wget, netcat）

通过 Termux，Android 设备可以变身为便携式开发 workstation。

### 什么是 OpenClaw？

**OpenClaw** 是一款开源的 AI 智能助手系统，支持私有化部署。它提供：
- 多渠道消息接入（WhatsApp、Telegram、Slack、Discord、Signal、iMessage、飞书、钉钉、企业微信、QQ）
- 语音交互能力（macOS/iOS/Android 语音唤醒）
- Canvas 可视化工作区
- 技能扩展系统（内置 + 自定义）
- 完整中文本地化（OpenClaw-CN 版本）

OpenClaw-CN-Termux 是针对 Android Termux 环境的定制安装方案，让您可以在手机上运行完整的 AI 助手系统。

官方网站：https://clawd.org.cn  
GitHub 仓库：https://github.com/jiulingyun/openclaw-cn  
上游项目：https://github.com/openclaw/openclaw

### OpenClaw-CN-Termux 定制版本

本仓库提供 **OpenClaw-CN-Termux**，是针对 Android Termux 环境的定制安装方案，包含：

- 自动化编译脚本（适配 Termux 环境）
- 中文文档和本地化说明
- Android 特定的配置和优化
- 软件渲染支持（无 GPU 加速设备）
- 触摸屏和手柄控制优化

**源码来源**: 基于 [OpenClaw/OpenClaw](https://github.com/OpenClaw/OpenClaw) 官方仓库，保持同步更新。

---

## 🚀 快速开始

```bash
# 1. 克隆本项目
git clone https://github.com/yourusername/termux-install-openclaw.git
cd termux-install-openclaw

# 2. 赋予执行权限
chmod +x install.sh

# 3. 运行安装
./install.sh

# 4. 启动游戏
openclaw
```

**预计耗时**: 20-60 分钟（取决于设备性能）

---

## 📖 文档导航

本项目文档采用分层结构，主 README 提供概览，详细内容见 `document/` 目录：

| 文档 | 说明 | 适合人群 |
|------|------|----------|
| **[installation.md](document/installation.md)** | 完整安装流程（前置检查、依赖安装、编译、配置） | 首次安装用户、需要理解流程的高级用户 |
| **[troubleshooting.md](document/troubleshooting.md)** | 故障排查（编译错误、运行问题、性能优化） | 遇到问题的用户 |
| **[faq.md](document/faq.md)** | 常见问题（20+ 问答，覆盖资源、存档、手柄等） | 快速查找常见解答 |

---

## ✨ 核心特性

- ✅ **一键自动化**: `install.sh` 处理依赖、下载、编译、安装全流程
- ✅ **架构检测**: 自动识别 ARM64/ARM，选择合适编译参数
- ✅ **依赖管理**: 自动安装所有必需库（SDL2 全家桶、cmake、gcc 等）
- ✅ **配置预置**: 提供默认配置，开箱即用
- ✅ **完整文档**: 安装手册 + 故障排查 + FAQ
- ✅ **软件渲染支持**: 无 GPU 加速设备也可运行
- ✅ **服务脚本**: `start-service.sh` / `stop-service.sh` 支持后台运行
- ✅ **依赖检查**: `check-deps.sh` 快速诊断环境问题

---

## 📦 前置要求

### 最低配置

| 项目 | 要求 |
|------|------|
| Android 版本 | 7.0 (API 24) |
| CPU 架构 | ARM64 (aarch64) |
| RAM | 2 GB（推荐 4 GB+） |
| 存储空间 | 1 GB 可用空间 |
| Termux 版本 | F-Droid 版（≥ 0.101.0）|

### 软件依赖（自动安装）

```
git, curl, wget, ca-certificates
build-essential (gcc, make, binutils)
cmake, pkg-config
sdl2, sdl2_image, sdl2_mixer, sdl2_ttf, sdl2_gfx
libiconv, zlib
```

---

## 📂 项目结构

```
termux-install-openclaw/
├── LICENSE                 # MIT 许可证
├── README.md               # 本文件（项目导航）
├── install.sh              # 主安装脚本（自动化流程）
│
├── document/               # 详细文档目录
│   ├── installation.md     # 完整安装手册
│   ├── troubleshooting.md  # 故障排查指南
│   └── faq.md              # 常见问题解答
│
├── config/                 # 默认配置文件
│   ├── config.ini          # 图形/音频/性能配置
│   └── controls.ini        # 键盘/触摸/手柄映射
│
├── scripts/                # 辅助脚本
│   ├── install.sh          # 主安装逻辑（由顶层 install.sh 调用）
│   ├── start-service.sh    # 后台启动 OpenClaw
│   ├── stop-service.sh     # 停止 OpenClaw 服务
│   └── check-deps.sh       # 依赖检查工具
│
├── release/                # 预编译二进制包和安装包
│   ├── termux-app_v0.119.0-beta.3+apt-android-7-github-debug_arm64-v8a.apk  # Termux APK（调试版）
│   └── openclaw-android-arm64.tar.gz  # OpenClaw 预编译包（规划中）
│
└── patches/                # Android/Termux 专用补丁
    └── README.md           # 补丁使用说明
```

---

## 🔧 配置说明

### 配置文件位置

| 类型 | 路径 | 说明 |
|------|------|------|
| 系统默认 | `$PREFIX/etc/openclaw/config.ini` | 安装时复制，全局生效 |
| 用户覆盖 | `~/.openclaw/config.ini` | 个人设置，优先级高 |
| 控制映射 | `~/.openclaw/controls.ini` | 按键/触摸映射 |

### 常用配置项（示例）

```ini
[graphics]
width=1280
height=720
fullscreen=false
vsync=true
texture_quality=high

[audio]
enabled=true
music_volume=80
sfx_volume=100

[controls]
touch_enabled=true
keyboard_enabled=true
gamepad_enabled=true

[performance]
max_fps=60
render_driver=auto
```

详细配置说明见 [installation.md](document/installation.md) 第 6 节。

---

## 🎮 基本使用

### 启动游戏

```bash
# 标准启动
openclaw

# 调试模式（输出日志）
OPENCLAW_DEBUG=1 openclaw

# 强制软件渲染（无 GPU 加速）
SDL_RENDER_DRIVER=software openclaw

# 指定分辨率
openclaw --res=800x480
```

### 控制方式

| 动作 | 触摸屏 | 键盘 | 手柄 |
|------|--------|------|------|
| 移动 | 虚拟方向键 | WASD / 方向键 | 左摇杆 |
| 跳跃 | 按钮 A | 空格 / J | 按钮 A |
| 攻击 | 按钮 B | K / L | 按钮 B |
| 暂停 | 菜单键 | P / ESC | START |

自定义映射: 编辑 `~/.openclaw/controls.ini`

### 存档管理

- **位置**: `~/.openclaw/saves/`
- **自动存档**: 每关结束后
- **手动存档**: 游戏内菜单
- **备份**: 复制整个 `saves/` 目录

---

## 📦 版本信息

### 当前项目

| 项目 | 版本 | 说明 |
|------|------|------|
| termux-install-openclaw | **v1.0.0-alpha** | 初始版本，基础自动化安装 |
| OpenClaw-CN-Termux | master (latest) | 基于官方 OpenClaw 的 Termux 定制版 |
| 上游 OpenClaw 源码 | master (latest) | 跟踪官方主线 |
| Termux 最低要求 | v0.101.0 | 包管理器支持 |
| Android API Level | 24+ | 最低 Android 7.0 |

### 版本号规则

- `alpha` - 内部测试，功能未稳定
- `beta` - 公开测试，接近完成
- `rc` - 发布候选
- `vX.Y.Z` - 稳定版（语义化版本）

---

## 🐛 问题排查

### 快速索引

| 问题 | 查看 |
|------|------|
| 编译失败（SDL2 not found） | [troubleshooting.md](document/troubleshooting.md) - 安装阶段 |
| 黑屏/闪退 | [troubleshooting.md](document/troubleshooting.md) - 运行阶段 |
| 无声音 | [troubleshooting.md](document/troubleshooting.md) - 音频问题 |
| 触摸无效 | [troubleshooting.md](document/troubleshooting.md) - 输入问题 |
| 性能卡顿 | [troubleshooting.md](document/troubleshooting.md) - 性能优化 |
| 其他问题 | [faq.md](document/faq.md) |

### 基本检查

```bash
# 1. 查看版本和架构
termux-info
uname -m

# 2. 检查依赖
pkg list-installed | grep sdl2

# 3. 验证安装
which openclaw
openclaw --version 2>/dev/null || echo "未安装或路径问题"

# 4. 调试运行
OPENCLAW_DEBUG=1 openclaw 2>&1 | tee ~/openclaw-debug.log
```

### 服务管理

安装完成后，可以使用服务脚本以后台方式运行 OpenClaw：

```bash
# 启动服务（后台运行，日志输出到 ~/.openclaw/service.log）
$PREFIX/share/openclaw/scripts/start-service.sh

# 停止服务
$PREFIX/share/openclaw/scripts/stop-service.sh

# 或使用本地副本
cd /path/to/termux-install-openclaw
./scripts/start-service.sh
./scripts/stop-service.sh
```

### 依赖检查

遇到问题时，运行依赖检查脚本获取诊断信息：

```bash
$PREFIX/share/openclaw/scripts/check-deps.sh
# 或
./scripts/check-deps.sh
```

---

## 🤝 贡献

我们欢迎社区贡献！请先阅读 [CONTRIBUTING.md](CONTRIBUTING.md)（待补充）。

### 贡献方式

- 🐛 报告 Bug（提供设备信息、日志、复现步骤）
- 📖 改进文档（安装手册、FAQ、翻译）
- 🧪 测试脚本（自动化测试、CI 配置）
- 🔧 新功能（服务管理、监控工具）
- 🌍 本地化（多语言支持）

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

- **OpenClaw 团队** - 原游戏重制项目
- **Termux 开发者** - Android 上的 Linux 环境
- **SDL 社区** - 跨平台多媒体库

---

**维护者**: byteuser1977  
**最后更新**: 2026-03-22  
**项目状态**: Alpha (内部测试)

---

*如果这个项目对您有帮助，请给我们 ⭐️ Star 支持！*