# Termux OpenClaw 详细安装手册

> **版本**: v1.0.0-alpha (refactored)
> **最后更新**: 2026-03-22

## 📋 目录

1. [概述](#概述)
2. [前置检查](#前置检查)
3. [依赖安装](#依赖安装)
4. [运行安装脚本](#运行安装脚本)
5. [配置说明](#配置说明)
6. [启动服务](#启动服务)
7. [后续管理](#后续管理)
8. [故障排查](#故障排查)

---

## 📝 概述

本手册提供在 Android Termux 环境中安装 OpenClaw-CN（AI 智能助手系统）的完整步骤。OpenClaw 是一个基于 Node.js 的多渠道 AI 助手，支持 WhatsApp、Telegram、飞书、钉钉等平台。

### 预期时间

| 步骤 | 预计时长 | 影响因素 |
|------|----------|----------|
| 环境准备 | 5-10 分钟 | 网络速度、设备性能 |
| 依赖下载 | 10-30 分钟 | 网络速度 |
| 构建 | 5-15 分钟 | CPU 性能 |

**总计**: 约 20-60 分钟

---

## 🔍 前置检查

### 2.1 检查 Termux 版本

```bash
termux-info
```

确保符合要求：
- **Termux 版本**: ≥ 0.101.0（建议从 F-Droid 安装）
- **API Level**: ≥ 24 (Android 7.0)
- **架构**: ARM64 (aarch64) 推荐

### 2.2 检查存储权限

```bash
termux-setup-storage
```

首次运行需要手动授权存储权限。

### 2.3 检查磁盘空间

```bash
df -h $HOME
```

建议：剩余空间 ≥ 2 GB

### 2.4 预检查环境

可以运行本项目的检查脚本：

```bash
cd d:\workspace\git\termux-install-openclaw
./scripts/check-env.sh
```

---

## 📦 依赖安装

### 3.1 更新包管理器

```bash
pkg update -y
pkg upgrade -y
```

### 3.2 安装基础工具

```bash
pkg install -y git curl wget ca-certificates
```

安装脚本会自动安装 Node.js ≥ 22，但也可以手动安装：

```bash
pkg install -y nodejs
```

验证：
```bash
node --version  # 应显示 v22.x 或更高
npm --version
```

---

## 🚀 运行安装脚本

### 4.1 克隆或准备项目

如果你还没有本项目：

```bash
# 在 Termux 中克隆
git clone https://github.com/yourusername/termux-install-openclaw.git
cd termux-install-openclaw
```

### 4.2 赋予执行权限

```bash
chmod +x scripts/*.sh
chmod +x install.sh
```

### 4.3 执行安装

```bash
./install.sh
```

安装脚本会：
1. ✅ 检查并安装 Node.js（如果不足 v22）
2. ✅ 安装 pnpm 包管理器
3. ✅ 克隆 OpenClaw-CN 源码到 `openclaw/` 目录
4. ✅ 运行 `pnpm install` 安装依赖
5. ✅ 运行 `pnpm build` 和 `pnpm ui:build` 构建项目
6. ✅ 创建配置文件 `~/.openclaw/openclaw.json`
7. ✅ 创建必要的数据目录

### 4.4 验证构建

```bash
cd openclaw
ls -lh dist/index.js
```

应看到编译后的 JavaScript 文件。

---

## ⚙️ 配置说明

### 5.1 编辑配置文件

安装完成后，编辑 `~/.openclaw/openclaw.json`：

```bash
nano ~/.openclaw/openclaw.json
```

**关键配置项**：

```json
{
  "agent": {
    "model": "anthropic/claude-sonnet-4-5",      // AI 模型
    "apiKey": "sk-...",                          // 你的 API Key
    "baseUrl": "https://api.openai.com"         // API 端点
  },
  "gateway": {
    "port": 18789,                               // 网关端口
    "token": "随机生成的安全令牌",                // 访问令牌
    "bind": "lan"                               // 绑定地址
  },
  "plugins": {
    "feishu": { "enabled": false },             // 飞书配置
    "telegram": { "enabled": false }            // Telegram 配置
  }
}
```

详细配置参考：[官方配置文档](https://clawd.org.cn/docs)

### 5.2 Docker 配置（可选）

如果你更喜欢 Docker 部署，可以使用项目中的 `docker-compose.yml` 示例：

```bash
# 在 openclaw-cn-termux 根目录
docker-compose up -d
```

---

## 🎯 启动服务

### 6.1 使用服务脚本（推荐）

```bash
# 启动 Gateway 服务（后台运行）
./scripts/start-gateway.sh

# 查看日志
tail -f ~/.openclaw/gateway.log

# 停止服务
./scripts/stop-gateway.sh
```

### 6.2 直接使用 pnpm

```bash
cd openclaw

# 启动 Gateway（Web 控制台）
pnpm start:gateway

# 或启动 CLI 交互模式
pnpm start

# 生产模式
pnpm start:prod
```

### 6.3 验证运行

```bash
# 检查进程
ps aux | grep openclaw

# 测试健康检查
curl http://localhost:18789/health

# 打开控制界面（Termux 内部或局域网）
# Termux 内部: http://localhost:1880
# 局域网访问: http://<你的设备IP>:1880
```

---

## 🔧 后续管理

### 7.1 更新 OpenClaw

```bash
cd openclaw
pnpm update
pnpm build
pnpm ui:build
```

### 7.2 查看日志

```bash
# Gateway 日志（如果使用服务脚本）
tail -f ~/.openclaw/gateway.log

# 应用日志
tail -f ~/.openclaw/logs/*.log
```

### 7.3 卸载

```bash
# 停止服务
./scripts/stop-gateway.sh

# 删除安装目录
rm -rf openclaw

# 删除配置和数据（谨慎！）
rm -rf ~/.openclaw
```

---

## 🐛 故障排查

### Node.js 版本过低

```bash
pkg install -y nodejs
# 或
pkg upgrade nodejs
```

### pnpm 命令找不到

```bash
npm install -g pnpm
# 或
corepack enable && corepack prepare pnpm@latest --activate
```

### 端口被占用

编辑 `~/.openclaw/openclaw.json`，修改 `gateway.port` 为其他端口（如 18790）。

### 构建失败

清理后重试：
```bash
cd openclaw
rm -rf node_modules dist .pnpm-store
pnpm install
pnpm build
```

### 无法访问 Web UI

确保网关正在运行：
```bash
./scripts/start-gateway.sh
```

并检查防火墙：Termux 允许局域网访问（gateway.bind 配置）。

### 插件无法启用

检查插件配置是否正确，并确保已安装对应依赖：
```bash
cd openclaw
pnpm install --filter @larksuiteoapi/feishu-openclaw-plugin
```

---

## 📚 参考资源

- 官方网站: https://clawd.org.cn
- 中文文档: https://clawd.org.cn/docs
- GitHub: https://github.com/jiulingyun/openclaw-cn
- 上游项目: https://github.com/openclaw/openclaw
- 社区交流: https://discord.gg/clawd
