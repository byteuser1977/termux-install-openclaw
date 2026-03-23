# Termux OpenClaw 详细安装手册

> **版本**: v1.0.0-alpha
> **最后更新**: 2026-03-22

## ⚠️ 重要说明

本文档介绍在 Termux 中通过 **proot-distro 运行 Ubuntu 系统**来安装 OpenClaw-CN。这是推荐的安装方式，可获得完整的 Linux 环境和更好的兼容性。

---

## 📋 目录

1. [概述](#概述)
2. [Termux 基础环境](#termux-基础环境)
3. [安装 Ubuntu 系统](#安装-ubuntu-系统)
4. [Ubuntu 软件安装](#ubuntu-软件安装)
5. [创建运行用户](#创建运行用户)
6. [安装 Node.js](#安装-nodejs)
7. [安装 OpenClaw-CN](#安装-openclaw-cn)
8. [首次配置](#首次配置)
9. [启动服务](#启动服务)
10. [故障排查](#故障排查)

---

## 📝 概述

OpenClaw是一个开源的 AI 智能助手系统，支持多渠道消息接入和灵活的技能扩展。在 Android 上，我们通过 Termux 应用配合 proot-distro 提供完整的 Linux 用户空间环境，实现与服务器部署相同的体验。

### 预期时间

| 步骤            | 预计时长 |
| --------------- | -------- |
| Termux 环境配置 | 5 分钟   |
| Ubuntu 安装     | 5 分钟   |
| 软件安装        | 2-3分钟  |
| Node.js 安装    | 2-5 分钟 |
| OpenClaw 安装   | 2-5 分钟 |

**总计**: 约 30 分钟

---

## 📦 Termux 基础环境

### 1.1 安装 Termux

**从 F-Droid 下载最新版 Termux**: https://github.com/termux/termux-app/releases

**不要使用 Google Play 版本**（已过时且不再维护）

本项目提供了termux最新版的下载：release/termux-app_v0.119.0-beta.3+apt-android-7-github-debug_arm64-v8a.apk

### 1.2 更新包管理器

打开 Termux，执行：

```bash
apt update && apt upgrade -y
```

### 1.3 安装基础工具

```bash
apt install termux-services -y
apt install termux-tools -y
apt install termux-api -y
apt install proot-distro -y
```

### 1.4 授权存储访问

```bash
termux-setup-storage
```

首次运行会弹出授权对话框，点击"允许"。

这会创建软链接：
- `~/storage/shared` # 手机共享存储
- `~/storage/downloads` # 下载目录
- `~/storage/dcim` # 相机目录

### 1.5 检查安装状态

```bash
# 验证 proot-distro
proot-distro --version

# 查看已安装的 Linux 发行版（应为空）
proot-distro list
```

---

## 🐧 安装 Ubuntu 系统

### 2.1 安装 Ubuntu

```bash
# 下载并安装 Ubuntu
proot-distro install ubuntu

# 安装过程需要 10-20 分钟，取决于网络速度
```

> 💡 **提示**: 首次安装会下载约 200-300 MB 的 rootfs 镜像。可以使用国内镜像加速：

### 2.3 进入 Ubuntu

```bash
proot-distro login ubuntu
```

成功后，提示符会变化（通常显示 `username@hostname:~$`，前面会有 `(proot)` 标识）。

### 2.4 更新 Ubuntu 系统

首次进入后，更新包列表和系统：

```bash
apt update && apt upgrade -y
```

---

## 🔧 Ubuntu 软件安装

### 3.1 安装必要软件包

在 Ubuntu 环境中执行：

```bash
apt install -y \
    sudo \
    ssh \
    nginx \
    curl \
    wget \
    git
```

### 3.2 验证安装

```bash
which git curl wget
git --version
node --version 2>/dev/null || echo "Node.js 还未安装"
```

---

## 👤 创建独立运行用户

为 OpenClaw 创建专用账户（安全最佳实践）：

```bash
# 添加用户
adduser openclaw

# 按照提示设置密码（记住这个密码）
# 可留空用户名、房间号、电话等字段

# 将用户加入 sudo 组（可选，如需权限）
usermod -aG sudo openclaw

# 验证
id openclaw
```

---

## 📦 安装 Node.js

OpenClaw 需要 Node.js 22 或更高版本。我们使用 nvm（Node Version Manager）安装，便于版本管理和更新。

### 5.1 切换到 openclaw 用户

```bash
su - openclaw
```

这会切换到 `openclaw` 用户的家目录 `/home/openclaw`。

### 5.2 安装 nvm

```bash
# 下载 nvm 安装脚本
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# 立即加载 nvm（不用重登录）
. "$HOME/.nvm/nvm.sh"
```

验证 nvm 是否加载成功：

```bash
command -v nvm
# 应输出 nvm
```

### 5.3 安装 Node.js

```bash
# 安装 LTS 版本
nvm install --lts

# 或指定版本
nvm install 24

# 设置默认版本
nvm alias default 24
```

### 5.4 验证安装

```bash
node --version
# 应输出 v24.x.x

npm --version
# 应输出 11.x.x

nvm current
# 应输出 24.x.x
```

### 5.5 配置 npm（可选）

```bash
# 设置 npm 使用国内镜像（加速下载）
npm config set registry https://registry.npmmirror.com

# 检查配置
npm config get registry
```

---

## 🤖 安装 OpenClaw-cn-termux

### 6.1 安装 npm 包

在 `openclaw` 用户下执行：

```bash
npm install -g openclaw-cn-termux@latest

# 或使用 pnpm（推荐，速度更快）：
npm install -g pnpm
pnpm add -g openclaw-cn-termux@latest
```

安装过程需要 5-10 分钟，取决于网络速度。

### 6.2 验证安装

```bash
# 检查命令是否可执行
which openclaw-termux || echo "命令未安装"

# 查看版本
openclaw-termux --version
# 应输出类似 v0.1.7

# 查看帮助
openclaw-termux --help
```

**注意**: 命令名可能是 `openclaw-cn-termux` 或简称 `openclaw-termux`，取决于 npm 包的 bin 配置。两者功能相同。

---

## ⚙️ 首次配置

### 7.1 运行配置向导

OpenClaw-CN 提供了交互式配置向导：

```bash
openclaw-termux onboard
```

向导会引导你完成：
1. 选择语言（中文/English）
2. 配置网关端口（默认 18789）
3. 设置管理员 token
4. 选择启用的渠道插件
5. 配置 AI 模型（API Key、模型名称）

### 7.2 手动编辑配置

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

### 7.3 启用渠道插件

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

### 8.1 启动方式选择

#### 方式 A：直接命令行启动

```bash
# 在 openclaw 用户下
cd ~
openclaw-cn-termux gateway
```

或：

```bash
openclaw-termux gateway
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

### 8.2 验证运行

```bash
# 检查进程
ps aux | grep openclaw

# 测试网关健康检查端点
curl http://localhost:18789/health

# 应返回 {"status":"ok"}
```

### 8.3 访问 Web 控制界面

默认 UI 运行在端口 **1880**：

- **Termux 内部**: `http://localhost:1880`
- **局域网其他设备**: `http://<你的Ubuntu容器IP>:1880`

查看容器 IP：

```bash
# 在 Ubuntu 环境中
hostname -I
# 或
ip addr show eth0 | grep inet
```

---

## 🔧 高级配置

### 10.1 开机自启动（Termux 方式）

Termux 使用 `termux-boot` 实现开机自启：

1. 在 Termux（主环境，非 Ubuntu）中安装：

```bash
pkg install termux-boot
```

2. 创建启动脚本 `~/.termux/boot/start-openclaw`

3. 编辑脚本内容：

```bash
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login ubuntu -c "cd /home/openclaw && openclaw-cn-termux gateway"
```

4. 授权：

```bash
chmod +x ~/.termux/boot/start-openclaw
```

5. 重启设备测试。

---

## 🐛 故障排查

### 问题 1: 命令 `openclaw-termux` 找不到

**原因**: npm 全局 bin 目录不在 PATH 中。

**解决**:

```bash
# 查看 npm 全局安装位置
npm config get prefix
# 通常是 /home/openclaw/.npm-global 或 /usr/local

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
- Ubuntu 容器网络配置问题

**解决**:

1. 确保配置中 `"bind": "lan"` 或 `"bind": "0.0.0.0"`
2. 检查 Ubuntu 容器 IP 并确保可访问：

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

Termux 和 Ubuntu 容器内存不足时，Node.js 可能被 OOM kill。

**解决**:

1. 关闭不必要的应用
2. 增加 swap 空间（在 Ubuntu 中）：

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

### 11.1 更新 OpenClaw

```bash
cd ~
pnpm update -g openclaw-cn-termux
# 或
npm update -g openclaw-cn-termux
```

### 11.2 备份配置

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
- **Termux Wiki**: https://wiki.termux.com

---

## 🙏 致谢

- **OpenClaw 团队** - byteuser
- **Termux 开发者** - 强大的 Android 终端环境
- **proot-distro** - 在 Android 上运行 Linux 发行版

---

**遇到问题？** 查看 [troubleshooting.md](./troubleshooting.md) 或提交 [GitHub Issue](https://github.com/jiulingyun/openclaw-cn/issues)。

## 🚀 使用自动化脚本（可选）

本项目提供了自动化脚本来简化安装过程：

### 使用 install-ubuntu.sh

在 Termux 环境中：

```bash
./scripts/install-ubuntu.sh
```

此脚本将自动完成 Termux 环境配置和 Ubuntu 安装。

### 使用 install-openclaw.sh

在 Ubuntu 环境中（openclaw 用户下）：

```bash
./scripts/install-openclaw.sh
```

此脚本将自动安装 Node.js、pnpm 和 OpenClaw-CN。

详细说明请参考脚本内部的注释信息。
