# Termux Install OpenClaw

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Termux](https://img.shields.io/badge/Termux-Install-blue)](https://termux.com)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-AI-Assistant-green)](https://github.com/OpenClaw/OpenClaw)

**在 Android Termux 环境中通过 Ubuntu proot-distro 安装 OpenClaw（AI 智能助手系统）**

---

## 📖 关于本项目

### 什么是 Termux？

**Termux** 是一款强大的 Android 终端模拟器和 Linux 环境应用，提供完整的包管理器和命令行工具链，无需 root 权限即可在手机上运行 Linux 软件。

### 什么是 OpenClaw？

**OpenClaw** 是一款开源的 AI 智能助手系统，支持多渠道消息接入（WhatsApp、Telegram、Slack、Discord、飞书、钉钉、企业微信、QQ），提供语音交互、Canvas 工作区、技能扩展等能力。

本项目提供 **Termux + Ubuntu proot-distro 安装指南**，帮助你在 Android 设备上快速部署 OpenClaw-CN 社区版。

官方网站：https://clawd.org.cn  
项目仓库：https://github.com/jiulingyun/openclaw-cn  
上游项目：https://github.com/openclaw/openclaw

---

## 🚀 快速开始（概览）

详细步骤请阅读 [installation.md](document/installation.md)，以下是概要流程：

```bash
# 1️⃣ 在 Termux 中准备环境
apt update && apt upgrade -y
apt install proot-distro -y
termux-setup-storage

# 2️⃣ 安装 Ubuntu 22.04
proot-distro install ubuntu-22.04
proot-distro login ubuntu-22.04

# 3️⃣ 在 Ubuntu 中安装软件
apt update && apt upgrade -y
apt install -y sudo ssh nginx curl wget git build-essential python3-pip

# 4️⃣ 创建 openclaw 用户
adduser openclaw
su - openclaw

# 5️⃣ 使用 nvm 安装 Node.js 24
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install --lts
nvm alias default 24

# 6️⃣ 安装 OpenClaw-CN
npm install -g openclaw-cn-termux@latest
# 或使用 pnpm 加速
npm install -g pnpm
pnpm add -g openclaw-cn-termux@latest

# 7️⃣ 配置并启动
openclaw-cn-termux onboard  # 交互式配置
openclaw-cn-termux gateway  # 启动网关

# 8️⃣ 访问 Web UI
# 浏览器打开: http://localhost:1880
```

**预计耗时**: 30-60 分钟（依赖网络和设备性能）

---

## 📋 前置要求

| 项目 | 要求 |
|------|------|
| Android 版本 | 7.0 (API 24) 或更高 |
| CPU 架构 | ARM64 (aarch64) 推荐 |
| RAM | 2 GB+（推荐 4 GB+） |
| 存储空间 | 3 GB 可用（包含 Ubuntu rootfs） |
| Termux 版本 | F-Droid 最新版（≥ 0.101.0） |
| 网络 | 可访问 GitHub 和 npm registry |

---

## 📂 项目结构

```
termux-install-openclaw/
├── install.sh              # 可选：快速环境检查脚本
├── scripts/
│   └── install.sh         # 辅助安装脚本（非必需）
├── config/
│   └── openclaw.json.example  # OpenClaw 配置模板
├── document/
│   ├── installation.md    # ⭐ 详细安装手册（必读）
│   ├── troubleshooting.md # 故障排查
│   └── faq.md             # 常见问题
├── README.md              # 本文件（快速指引）
└── LICENSE                # MIT 许可证
```

---

## 🔗 核心文档

| 文档 | 说明 |
|------|------|
| **[installation.md](document/installation.md)** | ⭐ **完整安装流程**（10 章，从 Termux 到运行） |
| **[faq.md](document/faq.md)** | 常见问题（24+ Q&A，覆盖安装、配置、插件、性能） |
| **[troubleshooting.md](document/troubleshooting.md)** | 故障排查（网络、权限、端口、内存等问题） |

**请务必先阅读 [installation.md](document/installation.md) 再开始安装！**

---

## ✨ 为什么选择 proot-distro + Ubuntu？

| 对比项 | Termux 原生 | proot-distro + Ubuntu |
|--------|-------------|----------------------|
| 环境兼容性 | 一般（库版本可能不符） | ⭐⭐⭐⭐⭐ 与生产环境一致 |
| 安装难度 | 简单 | 中等（多一步） |
| 稳定性 | 可能有兼容问题 | ⭐⭐⭐⭐⭐ 最稳定 |
| 维护性 | 一般 | ⭐⭐⭐⭐⭐ 与服务器部署相同 |
| 推荐度 | ⚠️ 不推荐 | ✅ **强烈推荐** |

**结论**: 虽然多一步安装 Ubuntu，但能保证 OpenClaw 完全正常工作，避免各种库依赖问题。这是最稳定、最接近生产环境的方案。

---

## ⚙️ 安装流程概览

### 阶段 1: Termux 基础配置

```bash
apt update && apt upgrade -y
apt install termux-services termux-tools termux-api proot-distro -y
termux-setup-storage
```

### 阶段 2: 安装 Ubuntu

```bash
proot-distro install ubuntu-22.04  # 或 ubuntu-24.04
proot-distro login ubuntu-22.04
apt update && apt upgrade -y
apt install sudo ssh nginx curl wget git build-essential python3-pip -y
```

### 阶段 3: 创建用户并安装 Node.js

```bash
adduser openclaw
su - openclaw
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh \| bash
\. "$HOME/.nvm/nvm.sh"
nvm install --lts  # Node.js 24
nvm alias default 24
```

### 阶段 4: 安装 OpenClaw-CN

```bash
npm install -g openclaw-cn-termux@latest
# 或使用 pnpm 加速
npm install -g pnpm
pnpm add -g openclaw-cn-termux@latest
```

### 阶段 5: 配置与启动

```bash
openclaw-cn-termux onboard  # 交互配置
openclaw-cn-termux gateway  # 启动
# 访问 http://localhost:1880
```

---

## 🎯 验证安装

```bash
# 查看 OpenClaw 版本
openclaw-cn-termux --version

# 检查进程
ps aux \| grep openclaw

# 测试网关健康检查
curl http://localhost:18789/health
# 应返回: {"status":"ok"}

# 访问 Web UI
# 浏览器打开: http://localhost:1880
```

---

## 🔧 基本使用

### 启动与停止

```bash
# 启动网关（前台）
openclaw-cn-termux gateway

# 后台运行
nohup openclaw-cn-termux gateway > ~/.openclaw/gateway.log 2>&1 &

# 停止
pkill -f "openclaw.*gateway"

# 使用 systemd（推荐）
sudo systemctl start openclaw
sudo systemctl enable openclaw
```

### 查看日志

```bash
tail -f ~/.openclaw/gateway.log
```

### 更新配置

编辑 `~/.openclaw/openclaw.json` 后重启服务。

---

## ⚙️ 配置文件

### 位置

- **用户配置**: `~/.openclaw/openclaw.json`
- **配置模板**: `termux-install-openclaw/config/openclaw.json.example`

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
    "token": "random-generated-token",
    "bind": "lan"
  },
  "locale": "zh-CN"
}
```

**必填项**:
- `agent.apiKey` - AI 模型的 API Key
- `agent.model` - 使用的模型名称
- `gateway.token` - 访问令牌

---

## 🤝 贡献

本项目是 OpenClaw-CN 的 Termux 安装指南集合。欢迎提交 Issue 和 PR 改进文档。

如果你发现安装流程有问题，请反馈到：
https://github.com/byteuser1977/termux-install-openclaw/issues

---

## 📚 参考资源

- **OpenClaw 官网**: https://clawd.org.cn
- **中文文档**: https://clawd.org.cn/docs
- **GitHub**: https://github.com/jiulingyun/openclaw-cn
- **上游项目**: https://github.com/openclaw/openclaw
- **Discord**: https://discord.gg/clawd
- **Termux Wiki**: https://wiki.termux.com
- **proot-distro**: https://github.com/termux/proot-distro

---

## 📄 许可证

[MIT](LICENSE) - 与 OpenClaw 主项目一致

---

**注意**: 本仓库仅包含安装指南和辅助脚本，不包含 OpenClaw 源码。OpenClaw 代码遵循其自身的 MIT 许可证。请阅读 [installation.md](document/installation.md) 开始安装。
