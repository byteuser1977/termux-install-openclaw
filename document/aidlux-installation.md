# AidLux OpenClaw 详细安装手册

> **版本**: v1.0.0-alpha
> **最后更新**: 2026-03-23

## ⚠️ 重要说明

本文档介绍在 **AidLux** 环境中安装 OpenClaw-CN。AidLux 是一个基于 Android 的 Linux 发行版，提供完整的 Linux 桌面环境。

---

## 📋 目录

1. [概述](#概述)
2. [AidLux 环境准备](#aidlux-环境准备)
3. [安装 Node.js](#安装-nodejs)
4. [安装 OpenClaw-cn-termux](#安装-openclaw-cn-termux)
5. [首次配置](#首次配置)
6. [启动服务](#启动服务)
7. [故障排查](#故障排查)

---

## 📝 概述

OpenClaw是一个开源的 AI 智能助手系统，支持多渠道消息接入和灵活的技能扩展。在 AidLux 上，我们可以直接在 Linux 环境中安装 OpenClaw-cn-termux，享受完整的 Linux 体验。

### 预期时间

| 步骤            | 预计时长 |
| --------------- | -------- |
| AidLux 环境准备 | 2 分钟   |
| Node.js 安装    | 2-5 分钟 |
| OpenClaw 安装   | 2-5 分钟 |

**总计**: 约 15-20 分钟

---

## 📦 AidLux 环境准备

### 1.1 安装 AidLux

从以下渠道获取 AidLux：
- **官方网站**: https://www.aidlux.com
- **APK 下载**: https://file.aidlux.com/repo/apk/aidlux_2.0.0_latest_release.apk

### 1.2 更新包管理器

打开 AidLux 终端，执行：

```bash
apt update -y
```

### 1.3 检查环境

```bash
# 验证 apt 包管理器
apt --version

# 检查当前用户
whoami
# 应该是 aidlux

# 检查家目录
echo $HOME
# 应该是 /home/aidlux
```

---

## 🚀 使用自动化脚本安装（推荐）

本项目提供了一键安装脚本，一行命令即可完成全部安装过程。

### 一键安装命令

```bash
curl -fsSL https://raw.githubusercontent.com/byteuser1977/termux-install-openclaw/main/scripts/install-aidlux.sh | bash
```

脚本会自动完成：
- 更新系统包
- 安装 nvm 和 Node.js 24
- 配置 npm 镜像（可选）
- 安装 OpenClaw-CN-Termux
- 验证安装

### 安装完成后

```bash
# 配置 OpenClaw
openclaw-termux onboard

# 启动网关
openclaw-termux gateway

# 访问 Web UI
# http://localhost:18789
```

### 手动安装

如果需要分步安装或自定义配置，请继续阅读下一章节的手动安装指南。

---

## 📦 手动安装步骤

如果您想手动安装，请按照以下步骤操作。

### 3.1 安装 nvm 和 Node.js

OpenClaw 需要 Node.js 22 或更高版本。我们使用 nvm（Node Version Manager）安装。

```bash
# 下载并安装 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# 立即加载 nvm（不用重登录）
. "$HOME/.nvm/nvm.sh"
```

验证 nvm 是否加载成功：

```bash
command -v nvm
# 应输出 nvm
```

### 3.2 安装 Node.js

```bash
# 安装 Node.js 24
nvm install 24

# 设置默认版本
nvm alias default 24
nvm use 24
```

### 3.3 验证安装

```bash
node --version
# 应输出 v24.x.x

npm --version
# 应输出 11.x.x

nvm current
# 应输出 24.x.x
```

### 3.4 配置 npm（可选）

```bash
# 设置 npm 使用国内镜像（加速下载）
npm config set registry https://registry.npmmirror.com

# 检查配置
npm config get registry
```

---

## 🤖 安装 OpenClaw-CN-Termux

### 4.1 选择包管理器

推荐使用 pnpm（速度更快）：

```bash
# 安装 pnpm
npm install -g pnpm
```

### 4.2 安装 npm 包

使用 pnpm：

```bash
pnpm add -g openclaw-cn-termux@latest
```

或使用 npm：

```bash
npm install -g openclaw-cn-termux@latest
```

安装过程需要 5-10 分钟，取决于网络速度。

### 4.3 验证安装

```bash
# 检查命令是否可执行
which openclaw-termux || which openclaw-cn-termux || echo "命令未安装"

# 查看版本
openclaw-termux --version
# 或
openclaw-cn-termux --version
# 应输出类似 v0.1.7

# 查看帮助
openclaw-termux --help
```

**注意**: 命令名可能是 `openclaw-cn-termux` 或简称 `openclaw-termux`，取决于 npm 包的 bin 配置。两者功能相同。

---

## ⚙️ 首次配置

### 5.1 运行配置向导

OpenClaw-CN 提供了交互式配置向导：

```bash
openclaw-termux onboard
```

或：

```bash
openclaw-cn-termux onboard
```

向导会引导你完成：
1. 选择语言（中文/English）
2. 配置网关端口（默认 18789）
3. 设置管理员 token
4. 选择启用的渠道插件
5. 配置 AI 模型（API Key、模型名称）

### 5.2 手动编辑配置

如果跳过向导或需要修改配置，直接编辑：

```bash
nano ~/.openclaw/openclaw.json
```

**最小配置示例**：

```json
{
  "$schema": "https://clawd.org.cn/schema/openclaw-config.json",
  "version": 1,
  "agent": {
    "model": "anthropic/claude-sonnet-4-5",
    "provider": "openai-compatible",
    "apiKey": "sk-your-api-key-here",
    "baseUrl": "https://api.openai.com"
  },
  "gateway": {
    "port": 18789,
    "token": "your-random-token-here",
    "bind": "lan",
    "logLevel": "info"
  },
  "ui": {
    "enabled": true,
    "port": 1880
  },
  "locale": "zh-CN"
}
```

**关键字段说明**：
- `agent.apiKey`: AI 模型的 API Key（必填）
- `agent.model`: 使用的模型名称
- `gateway.port`: 网关监听端口（默认 18789）
- `gateway.token`: 访问网关的令牌（用于客户端连接）
- `gateway.bind`: 绑定地址，`lan` 表示监听所有网络接口

### 5.3 启用渠道插件

如需使用特定渠道（如飞书、Telegram），在 `plugins` 部分配置：

```json
{
  "plugins": {
    "feishu": {
      "enabled": true,
      "appId": "your-app-id",
      "appSecret": "your-app-secret",
      "encryptionKey": "your-encryption-key"
    }
  }
}
```

并安装对应的插件包：

```bash
cd ~
pnpm install --filter @larksuiteoapi/feishu-openclaw-plugin
```

详细插件配置参考官方文档：https://clawd.org.cn/channels/

---

## 🚀 启动服务

### 6.1 启动方式选择

#### 方式 A：直接命令行启动

```bash
openclaw-termux gateway
```

或：

```bash
openclaw-cn-termux gateway
```

这将启动网关服务（前台运行），日志输出到控制台。

按 `Ctrl+C` 停止。

#### 方式 B：后台运行（推荐）

使用 `nohup` 或 `screen` 让服务在后台持续运行：

```bash
# 使用 nohup
nohup openclaw-termux gateway > ~/.openclaw/gateway.log 2>&1 &

# 查看进程
ps aux | grep openclaw

# 停止服务
pkill -f "openclaw.*gateway"
```

或使用 `screen`/`tmux`：

```bash
# 安装 screen
apt install screen

# 创建会话
screen -S openclaw

# 启动服务
openclaw-termux gateway restart

# 分离会话：Ctrl+A, 然后按 D
# 重新连接：screen -r openclaw
```

### 6.2 验证运行

```bash
# 检查进程
ps aux | grep openclaw

# 测试网关健康检查端点
curl http://localhost:18789/health

# 应返回 {"status":"ok"}
```

### 6.3 访问 Web 控制界面

默认 UI 运行在端口 **1880**：

- **AidLux 内部**: `http://localhost:1880`
- **局域网其他设备**: `http://<你的AidLux设备IP>:1880`

查看设备 IP：

```bash
hostname -I
# 或
ip addr show eth0 | grep inet
```

---

## 🔧 高级配置

### 7.1 开机自启动（AidLux 方式）

AidLux 支持在启动时自动运行脚本：

1. 创建启动脚本 `~/.aidlux/start-openclaw.sh`

```bash
#!/bin/bash
# 加载 nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 启动 OpenClaw
cd ~
nohup openclaw-termux gateway > ~/.openclaw/gateway.log 2>&1 &
```

2. 授权：

```bash
chmod +x ~/.aidlux/start-openclaw.sh
```

3. 在 AidLux 启动设置中添加此脚本

---

## 🐛 故障排查

### 问题 1: 命令 `openclaw-termux` 找不到

**原因**: npm 全局 bin 目录不在 PATH 中。

**解决**:

```bash
# 查看 npm 全局安装位置
npm config get prefix
# 通常是 /home/aidlux/.npm-global 或 /usr/local

# 添加到 PATH（编辑 ~/.bashrc）
export PATH="$HOME/.npm-global/bin:$PATH"
# 或
export PATH="/usr/local/bin:$PATH"

# 重新加载
source ~/.bashrc

# 重试
which openclaw-cn-termux
```

---

### 问题 2: 端口被占用

**原因**: 端口 18789 已被其他进程占用。

**解决**:

```bash
# 查看占用进程
lsof -i :18789

# 杀死进程
kill <PID>

# 或修改配置，使用其他端口
# 编辑 ~/.openclaw/openclaw.json
```

---

### 问题 3: 无法访问 Web UI（从其他设备）

**原因**:
- gateway.bind 设置为 "localhost"
- 防火墙限制
- AidLux 网络配置问题

**解决**:

1. 确保配置中 `"bind": "lan"` 或 `"bind": "0.0.0.0"`
2. 检查 AidLux 设备 IP 并确保可访问：

```bash
hostname -I
```

3. 如有防火墙，开放端口：

```bash
apt install ufw
ufw allow 18789
ufw allow 1880
```

---

### 问题 4: 插件无法加载

**症状**: 日志中显示 `Cannot find module '@xxx/plugin'`

**原因**: 插件依赖未安装。

**解决**:

```bash
cd ~
pnpm install --filter @larksuiteoapi/feishu-openclaw-plugin
# 或对应插件名
```

---

### 问题 5: 内存不足导致崩溃

AidLux 内存不足时，Node.js 可能被 OOM kill。

**解决**:

1. 关闭不必要的应用
2. 增加 swap 空间：

```bash
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
# 加入 /etc/fstab 永久生效
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

3. 限制 Node.js 内存：

```bash
export NODE_OPTIONS="--max-old-space-size=1024"
```

---

### 问题 6: 网络超时（安装阶段）

**原因**: 国内网络访问 npm registry 较慢或受限。

**解决**:

```bash
# 使用淘宝镜像
npm config set registry https://registry.npmmirror.com
# pnpm config set registry https://registry.npmmirror.com

# 清理缓存重试
pnpm store prune
cd ~
rm -rf node_modules
pnpm install -g openclaw-cn-termux@latest
```

---

## 📦 更新与维护

### 8.1 更新 OpenClaw

```bash
cd ~
pnpm update -g openclaw-cn-termux
# 或
npm update -g openclaw-cn-termux
```

### 8.2 备份配置

```bash
# 打包配置和数据
tar -czf ~/openclaw-backup-$(date +%Y%m%d).tar.gz ~/.openclaw/

# 恢复
tar -xzf ~/openclaw-backup-*.tar.gz -C ~/
```

---

## 📚 参考资料

- **OpenClaw 官网**: https://clawd.org.cn
- **中文文档**: https://clawd.org.cn/docs
- **GitHub**: https://github.com/byteuser/openclaw-cn-termux
- **上游项目**: https://github.com/openclaw/openclaw
- **Discord**: https://discord.gg/clawd
- **AidLux 官网**: https://www.aidlux.com

---

## 🙏 致谢

- **OpenClaw 团队** - byteuser
- **AidLux 开发者** - 强大的 Android Linux 环境

---

**遇到问题？** 查看 [troubleshooting.md](./troubleshooting.md) 或提交 [GitHub Issue](https://github.com/byteuser1977/termux-install-openclaw/issues)。
