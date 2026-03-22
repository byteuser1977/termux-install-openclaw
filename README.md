# Termux Install OpenClaw

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Termux](https://img.shields.io/badge/Termux-Install-blue)](https://termux.com)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-AI-Assistant-green)](https://github.com/OpenClaw/OpenClaw)

**在 Android Termux 环境中自动化安装和运行 OpenClaw（AI 智能助手系统）**

---

## 📖 关于本项目

### 什么是 Termux？

**Termux** 是一款强大的 Android 终端模拟器和 Linux 环境应用，提供完整的包管理器和命令行工具链，无需 root 权限即可在手机上运行 Linux 软件。

### 什么是 OpenClaw？

**OpenClaw** 是一款开源的 AI 智能助手系统，支持多渠道消息接入（WhatsApp、Telegram、Slack、Discord、飞书、钉钉、企业微信、QQ），提供语音交互、Canvas 工作区、技能扩展等能力。

本项目提供 **Termux 一键安装脚本**，帮助你在 Android 设备上快速部署 OpenClaw-CN 社区版。

官方网站：https://clawd.org.cn  
项目仓库：https://github.com/jiulingyun/openclaw-cn  
上游项目：https://github.com/openclaw/openclaw

---

## 🚀 快速开始

### 前置要求

| 项目 | 要求 |
|------|------|
| Android 版本 | 7.0 (API 24) |
| ARM64 架构 | 推荐 |
| RAM | 2 GB+ |
| 存储空间 | 2 GB 可用 |
| Termux 版本 | F-Droid 版 ≥ 0.101.0 |

### 一键安装

```bash
# 1. 克隆本项目（在 Termux 中）
git clone https://github.com/yourusername/termux-install-openclaw.git
cd termux-install-openclaw

# 2. 运行安装脚本
./install.sh

# 3. 编辑配置文件
nano ~/.openclaw/openclaw.json
# 添加 agent.apiKey 等必要设置

# 4. 启动服务（后台）
./scripts/start-gateway.sh

# 5. 访问控制界面
# Termux 内部: http://localhost:1880
# 局域网设备: http://<设备IP>:1880
```

**预计耗时**: 20-60 分钟（依赖网络和设备性能）

---

## 📂 项目结构

```
termux-install-openclaw/
├── install.sh              # 主安装脚本
├── scripts/
│   ├── install.sh         # 核心安装逻辑
│   ├── start-gateway.sh   # 启动 Gateway 服务
│   ├── stop-gateway.sh    # 停止服务
│   └── check-env.sh       # 环境诊断工具
├── config/
│   └── openclaw.json.example  # 配置文件模板
├── document/
│   ├── installation.md    # 详细安装手册
│   ├── troubleshooting.md # 故障排查
│   └── faq.md             # 常见问题
├── README.md              # 本文件
└── LICENSE                # MIT 许可证
```

---

## ✨ 特性

- ✅ **自动化安装**: 自动安装 Node.js ≥22、pnpm、OpenClaw 源码
- ✅ **配置预置**: 提供 `openclaw.json.example` 模板
- ✅ **服务管理**: 后台启动/停止脚本，支持 PID 管理
- ✅ **环境诊断**: 一键检查 Termux 环境、端口、依赖
- ✅ **完整文档**: 安装手册 + 故障排查 + FAQ
- ✅ **原生体验**: 无需 Docker，直接在 Termux 运行 Node.js

---

## 🔧 使用说明

### 安装流程

1. **运行安装脚本**
   ```bash
   ./install.sh
   ```
   脚本会自动：
   - 检查并安装 Node.js（如果缺失或版本不足）
   - 安装 pnpm 包管理器
   - 克隆 OpenClaw-CN 源码到 `openclaw/`
   - 执行 `pnpm install` 安装依赖
   - 执行 `pnpm build` 构建项目
   - 创建配置文件 `~/.openclaw/openclaw.json`

2. **编辑配置**
   打开 `~/.openclaw/openclaw.json`，配置：
   - `agent.apiKey` - 你的 AI 模型 API Key（必填）
   - `gateway.port` - 网关端口（默认 18789）
   - 需要的插件（如 `feishu`, `telegram` 等）

3. **启动服务**
   ```bash
   ./scripts/start-gateway.sh
   ```

4. **访问 Web UI**
   打开浏览器访问 `http://localhost:1880`

详细步骤见 [installation.md](document/installation.md)

---

### 服务管理

```bash
# 启动 Gateway（后台）
./scripts/start-gateway.sh

# 停止 Gateway
./scripts/stop-gateway.sh

# 检查环境
./scripts/check-env.sh

# 查看日志
tail -f ~/.openclaw/gateway.log
```

---

### 命令行直接运行

```bash
cd openclaw

# 启动 Gateway（Web UI）
pnpm start:gateway

# 启动 CLI 交互模式
pnpm start

# 构建项目
pnpm build
pnpm ui:build
```

---

## ⚙️ 配置说明

### 配置文件位置

| 类型 | 路径 |
|------|------|
| 用户配置 | `~/.openclaw/openclaw.json` |
| 示例配置 | `termux-install-openclaw/config/openclaw.json.example` |

### 最小配置示例

```json
{
  "agent": {
    "model": "anthropic/claude-sonnet-4-5",
    "apiKey": "sk-your-api-key"
  },
  "gateway": {
    "port": 18789,
    "token": "random-generated-token"
  }
}
```

更多配置选项见 [官方文档](https://clawd.org.cn/docs)

---

## 🐛 常见问题

### 安装失败怎么办？

```bash
# 清理后重试
cd openclaw
rm -rf node_modules dist .pnpm-store
cd ..
./install.sh
```

### 无法访问 Web UI？

- 确认 Gateway 已启动：`./scripts/start-gateway.sh`
- 检查端口是否被占用
- 确保配置中 `gateway.bind` 为 `"lan"` 或 `"0.0.0.0"`

### 插件无法使用？

- 确认依赖已安装：`cd openclaw && pnpm install --filter <plugin-name>`
- 检查配置中的 `plugins` 部分
- 查看日志中的错误信息

更多 Q&A 见 [faq.md](document/faq.md)  
详细故障排查见 [troubleshooting.md](document/troubleshooting.md)

---

## 🆚 与 Docker 版本对比

| 特性 | Termux 原生 | Docker |
|------|------------|--------|
| 权限要求 | 无需 root | 支持 root 或包含 Docker 的发行版 |
| 隔离性 | 一般 | 强 |
| 资源占用 | 较低 | 较高（含镜像） |
| 启动速度 | 快 | 较慢（容器启动） |
| 适用场景 | 单设备快速体验 | 服务器、多实例 |

---

## 📚 参考资源

- **官方网站**: https://clawd.org.cn
- **中文文档**: https://clawd.org.cn/docs
- **GitHub**: https://github.com/jiulingyun/openclaw-cn
- **上游项目**: https://github.com/openclaw/openclaw
- **Discord**: https://discord.gg/clawd
- **npm 包**: https://www.npmjs.com/package/openclaw-cn

---

## 🤝 贡献

本项目是 Termux 安装脚本集合，欢迎提交 Issue 和 PR 改进安装体验。

如果你发现文档或脚本有问题，请反馈到：
https://github.com/yourusername/termux-install-openclaw/issues

---

## 📄 许可证

[MIT](LICENSE) - 与 OpenClaw 主项目一致

---

**注意**: 本项目是 OpenClaw-CN 的第三方安装脚本，不包含 OpenClaw 源码本身。OpenClaw 代码遵循其自身的 MIT 许可证。
