# Termux 原生环境 OpenClaw 安装手册

> **版本**: v1.0.0
> **最后更新**: 2026-04-13

## ⚠️ 重要说明

本文档介绍在 **Termux 原生环境**（不通过 proot-distro）中直接安装 OpenClaw-cn-termux。这是更轻量、更快速的安装方式，适合希望简化安装流程的用户。

**与 Termux + Ubuntu 方式的区别**:

| 对比项 | Termux 原生 | Termux + Ubuntu |
|--------|-------------|-----------------|
| 安装复杂度 | ⭐ 简单 | 中等 |
| 系统资源占用 | ⭐ 更低 | 中等 |
| 环境隔离性 | 一般 | ⭐⭐⭐⭐⭐ 完整 Linux 环境 |
| 兼容性 | 良好 | ⭐⭐⭐⭐⭐ 最佳 |
| 推荐场景 | 快速体验、资源受限设备 | 生产环境、长期运行 |

---

## 📋 目录

1. [概述](#概述)
2. [环境要求](#环境要求)
3. [一键安装（推荐）](#一键安装推荐)
4. [手动安装](#手动安装)
5. [首次配置](#首次配置)
6. [启动服务](#启动服务)
7. [后台运行与保活](#后台运行与保活)
8. [故障排查](#故障排查)

---

## 📝 概述

OpenClaw 是一款开源的 AI 智能助手系统，支持多渠道消息接入和灵活的技能扩展。本安装方式直接在 Termux 原生环境中部署，无需额外的 Ubuntu 容器，安装更快速、资源占用更少。

### 预期时间

| 步骤 | 预计时长 |
|------|---------|
| 环境准备 | 2-3 分钟 |
| 依赖安装 | 3-5 分钟 |
| Node.js 工具安装 | 1-2 分钟 |
| OpenClaw 安装 | 2-5 分钟 |
| **总计** | **约 10-15 分钟** |

---

## 📦 环境要求

### 前置条件

| 项目 | 要求 |
|------|------|
| Android 版本 | 7.0 (API 24) 或更高 |
| CPU 架构 | ARM64 (aarch64) 推荐 |
| RAM | 2 GB+（推荐 4 GB+） |
| 存储空间 | 500 MB 可用 |
| Termux 版本 | F-Droid 最新版（≥ 0.119.0） |
| 网络 | 可访问 GitHub 和 npm registry |

### 安装 Termux

**从 F-Droid 下载最新版 Termux**: https://github.com/termux/termux-app/releases

⚠️ **不要使用 Google Play 版本**（已过时且不再维护）

本项目提供了 Termux 最新版下载：`release/termux-app_v0.119.0-beta.3+apt-android-7-github-debug_arm64-v8a.apk`

---

## 🚀 一键安装（推荐）

本项目提供了一键安装脚本，自动完成 Termux 环境准备到 OpenClaw 安装的完整流程。

### 一键安装命令

在 Termux 中执行以下命令：

```bash
curl -fsSL https://raw.githubusercontent.com/byteuser1977/termux-install-openclaw/main/scripts/install-termux.sh | bash
```

### 脚本执行流程

脚本会自动完成以下 5 个步骤：

1. **更新 Termux 包** - 执行 `pkg update -y` 和 `pkg upgrade -y`
2. **安装必要依赖** - git, curl, wget, openssl, python, nodejs, openssh
3. **安装 Node.js 工具** - 安装 pnpm 和 nrm
4. **安装 OpenClaw-CN-Termux** - 配置镜像、选择包管理器、安装软件
5. **配置 OpenClaw** - 创建配置目录和默认配置文件

### 交互式选项

脚本运行过程中会询问以下选项：

- **使用国内 npm 镜像？** (Y/n) - 默认是，加速国内下载
- **选择包管理器** (1-2) - 1) pnpm(推荐) 2) npm，默认 npm

### 安装完成后

```bash
# 配置 OpenClaw
openclaw-termux onboard

# 启动网关
openclaw-termux gateway

# 访问 Web UI
# http://localhost:18789

# 或使用 TUI 界面
openclaw-termux tui
```

---

## 🔧 手动安装

如果需要分步安装或自定义配置，请按照以下步骤操作。

### 步骤 1：更新 Termux 包

```bash
pkg update -y
pkg upgrade -y
```

### 步骤 2：安装必要依赖

```bash
pkg install -y \
    git \
    curl \
    wget \
    openssl \
    python \
    nodejs \
    openssh
```

### 步骤 3：安装 Node.js 工具

```bash
# 查看 Node.js 版本
node --version
npm --version

# 安装 pnpm 和 nrm
npm install -g pnpm nrm
```

### 步骤 4：安装 OpenClaw-CN-Termux

#### 4.1 配置 npm 镜像（国内用户推荐）

```bash
npm config set registry https://registry.npmmirror.com
```

#### 4.2 选择包管理器安装

**方式 A：使用 pnpm（推荐，更快）**

```bash
# 安装 pnpm
npm install -g pnpm

# 安装 OpenClaw
pnpm add -g openclaw-cn-termux@0.2.1-beta.0
```

**方式 B：使用 npm**

```bash
npm install -g openclaw-cn-termux@0.2.1-beta.0
```

#### 4.3 安装依赖工具

```bash
# 使用相同的包管理器安装 strip-ansi
pnpm add -g strip-ansi
# 或
npm install -g strip-ansi
```

#### 4.4 验证安装

```bash
# 检查命令是否可用
which openclaw-termux
# 或
which openclaw-cn-termux

# 查看版本
openclaw-termux --version
```

### 步骤 5：创建配置

```bash
# 创建配置目录
mkdir -p ~/.openclaw
mkdir -p ~/.openclaw/data ~/.openclaw/memory ~/.openclaw/logs

# 创建配置文件
cat > ~/.openclaw/openclaw.json <<EOF
{
  "agent": {
    "model": "anthropic/claude-sonnet-4-5",
    "apiKey": "sk-your-api-key"
  },
  "gateway": {
    "port": 18789,
    "token": "$(openssl rand -hex 32 2>/dev/null || cat /dev/urandom | tr -dc 'a-f0-9' | head -c64)"
  }
}
EOF
```

---

## ⚙️ 首次配置

### 使用交互式配置向导（推荐）

```bash
openclaw-termux onboard
```

向导会引导你完成：
- AI 模型选择和 API Key 配置
- Gateway 端口和 Token 设置
- 其他高级选项

### 手动编辑配置文件

```bash
nano ~/.openclaw/openclaw.json
```

### 最小配置示例

```json
{
  "$schema": "https://clawd.org.cn/schema/openclaw-config.json",
  "version": 1,
  "agent": {
    "model": "anthropic/claude-sonnet-4-5",
    "apiKey": "sk-your-api-key-here"
  },
  "gateway": {
    "port": 18789,
    "token": "your-random-token",
    "bind": "lan"
  },
  "locale": "zh-CN"
}
```

**必填项**:
- `agent.apiKey` - AI 模型的 API Key
- `agent.model` - 使用的模型名称
- `gateway.token` - 访问令牌（用于 API 认证）

---

## 🚀 启动服务

### 前台启动（调试使用）

```bash
openclaw-termux gateway
```

启动后会显示：
- Gateway 服务地址
- Web UI 访问地址
- 日志输出

按 `Ctrl+C` 停止服务。

### 访问 Web UI

打开浏览器访问：
- **Termux 内部**: http://localhost:18789
- **局域网其他设备**: http://<设备IP>:18789

查看设备 IP：
```bash
hostname -I
```

### 使用 TUI 界面

```bash
openclaw-termux tui
```

提供终端图形界面，适合在纯终端环境中使用。

---

## 🔄 后台运行与保活

### 方式 1：使用 nohup（简单）

```bash
nohup openclaw-termux gateway > ~/.openclaw/gateway.log 2>&1 &
```

查看日志：
```bash
tail -f ~/.openclaw/gateway.log
```

停止服务：
```bash
pkill -f "openclaw.*gateway"
```

### 方式 2：使用 termux-services（推荐）

```bash
# 安装 termux-services
pkg install termux-services -y

# 创建服务脚本
mkdir -p $PREFIX/var/service/openclaw
cat > $PREFIX/var/service/openclaw/run <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec openclaw-termux gateway 2>&1
EOF
chmod +x $PREFIX/var/service/openclaw/run

# 启动服务
sv up openclaw

# 查看状态
sv status openclaw

# 停止服务
sv down openclaw
```

### Termux 保活建议

由于 Android 系统会限制后台进程，建议进行以下设置：

1. **开启 Wake Lock**
   ```bash
   termux-wake-lock
   ```
   或在 Termux 通知栏中点击 "Acquire Wakelock"

2. **关闭电池优化**
   - 进入 Android 设置 → 应用 → Termux → 电池
   - 选择 "无限制" 或 "不优化"

3. **允许后台运行**
   - 进入 Android 设置 → 应用 → Termux
   - 开启 "允许后台活动"

4. **使用 termux-boot（开机自启）**
   ```bash
   pkg install termux-boot -y
   ```
   在 `~/.termux/boot/` 目录创建启动脚本

---

## 🐛 故障排查

### 安装失败

**问题**: npm 安装超时或失败

**解决**:
```bash
# 切换国内镜像
npm config set registry https://registry.npmmirror.com
# 或
nrm use taobao

# 重试安装
npm install -g openclaw-cn-termux@0.2.1-beta.0
```

### 命令找不到

**问题**: `openclaw-termux: command not found`

**解决**:
```bash
# 检查全局安装路径
npm root -g

# 确保路径在 PATH 中
export PATH="$PATH:$(npm bin -g)"

# 或使用完整路径
$(npm bin -g)/openclaw-termux --version
```

### 端口被占用

**问题**: `Error: Port 18789 is already in use`

**解决**:
```bash
# 查找占用端口的进程
lsof -i :18789

# 终止进程
kill -9 <PID>

# 或修改配置文件使用其他端口
# 编辑 ~/.openclaw/openclaw.json，修改 gateway.port
```

### 无法访问 Web UI

**问题**: 浏览器无法打开 http://localhost:18789

**解决**:
1. 确认服务已启动：`ps aux | grep openclaw`
2. 检查配置文件 `bind` 设置：
   - `"bind": "lan"` - 允许局域网访问
   - `"bind": "localhost"` - 仅本地访问
3. 检查防火墙（如有）

### 内存不足

**问题**: 安装或运行时提示内存不足

**解决**:
```bash
# 增加 Node.js 内存限制
export NODE_OPTIONS="--max-old-space-size=2048"

# 或使用 swap
pkg install swapspace -y
```

### 查看详细日志

```bash
# 前台运行查看详细输出
openclaw-termux gateway --verbose

# 或查看日志文件
cat ~/.openclaw/logs/gateway.log
```

---

## 📚 更多资源

- [OpenClaw 官方文档](https://github.com/OpenClaw/OpenClaw)
- [Termux 官方 Wiki](https://wiki.termux.com)
- [故障排查指南](troubleshooting.md)
- [常见问题 FAQ](faq.md)

---

## 📝 更新日志

### v1.0.0 (2026-04-13)
- 初始版本发布
- 支持 Termux 原生环境一键安装
- 提供手动安装详细步骤
- 包含后台运行和保活方案
