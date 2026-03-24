# 长期记忆 - OpenClaw Agent

## 🎯 核心信息

### 项目状态
- **工作区**: `d:\workspace\git\termux-install-openclaw`
- **项目性质**: 在 Android 设备上部署 OpenClaw-CN 的完整安装指南
- **OpenClaw 本质**: AI 智能助手系统（非游戏）
- **支持平台**: Termux + Ubuntu, AidLux
- **最新版本**: 2026-03-23 (支持 AidLux)

### 关键命令流程

#### 方式 A: Termux + Ubuntu（推荐，兼容性最佳）
```bash
# 在 Termux 中
apt update && apt upgrade -y
apt install proot-distro -y
termux-setup-storage
proot-distro install ubuntu
proot-distro login ubuntu

# 在 Ubuntu 中
apt update && apt upgrade -y
apt install -y sudo ssh nginx curl wget git
adduser openclaw
usermod -aG sudo openclaw
su - openclaw

# 安装 Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install --lts  # Node.js 24
nvm alias default 24

# 安装 OpenClaw
npm install -g openclaw-cn-termux@latest
# 或使用 pnpm 加速
npm install -g pnpm
pnpm add -g openclaw-cn-termux@latest

# 配置启动
openclaw-cn-termux onboard
openclaw-cn-termux gateway
```

#### 方式 B: AidLux（更简单，适合初学者）
```bash
# 在 AidLux 终端中
apt update -y

# 使用一键脚本（推荐）
git clone https://github.com/byteuser1977/termux-install-openclaw.git
cd termux-install-openclaw
bash scripts/install-aidlux.sh

# 或手动安装：
# 1. 安装 nvm 和 Node.js 24
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 24
nvm alias default 24

# 2. 安装 OpenClaw
npm install -g openclaw-cn-termux@latest
# 或
pnpm add -g openclaw-cn-termux@latest

# 3. 配置并启动
openclaw-termux onboard
openclaw-termux gateway
```

#### 便捷脚本（两种方式都适用）
```bash
# Termux 一键安装 Ubuntu（在 Termux 中运行）
./scripts/install-ubuntu.sh

# Ubuntu/AidLux 一键安装 OpenClaw（在 Ubuntu/AidLux 中运行）
./scripts/install-openclaw.sh
```

---

## 📚 文档体系

### 主要文档

| 文件 | 用途 | 状态 | 适用平台 |
|------|------|------|---------|
| `README.md` | 快速开始，指引阅读详细手册 | ✅ 最新 | 通用 |
| `document/installation.md` | 10章节完整安装手册 | ✅ 最新 | Termux + Ubuntu |
| `document/aidlux-installation.md` | AidLux 详细安装手册 | ✅ 最新 | AidLux |
| `document/faq.md` | 24+ 常见问题 | ✅ 最新 | 通用 |
| `document/troubleshooting.md` | 按阶段故障排查 | ✅ 最新 | 通用 |
| `config/openclaw.json.example` | OpenClaw 配置模板 | ✅ 最新 | 通用 |

### 文档对比：Termux vs AidLux

| 对比项 | Termux + Ubuntu | AidLux |
|--------|-----------------|--------|
| 安装难度 | 中等（需配置 proot-distro） | ⭐⭐⭐⭐⭐ 简单直接 |
| 环境兼容性 | ⭐⭐⭐⭐⭐ 与生产环境一致 | ⭐⭐⭐⭐⭐ 完整 Linux 环境 |
| 安装耗时 | 30-60 分钟 | 15-20 分钟 |
| 桌面环境 | 无（纯终端） | ⭐⭐⭐⭐⭐ 完整 Linux 桌面 |
| 资源占用 | 较轻 | 中等 |
| 推荐度 | ✅ 推荐 | ✅ **初学者更推荐** |

---

## 🔧 技术要点

### Node.js 环境
- **最低版本**: Node.js 22
- **推荐版本**: Node.js 24 LTS
- **包管理器**: pnpm (推荐，速度更快) 或 npm
- **版本管理**: nvm (Node Version Manager)

### 配置文件
- **位置**: `~/.openclaw/openclaw.json`
- **模板**: `config/openclaw.json.example`
- **关键字段**:
  - `agent.apiKey` (必填) - AI 模型的 API Key
  - `agent.model` - 使用的模型名称（如 `anthropic/claude-sonnet-4-5`）
  - `agent.provider` - 提供商（默认 `openai-compatible`）
  - `gateway.port` (默认 18789)
  - `gateway.token` - 访问令牌（必填）
  - `gateway.bind` (建议 "lan" 或 "0.0.0.0")
  - `gateway.logLevel` (默认 "info")
  - `ui.port` (默认 1880 - Web 控制界面)
  - `locale` (推荐 "zh-CN")

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
  "ui": {
    "enabled": true,
    "port": 1880
  },
  "locale": "zh-CN"
}
```

### 服务端口
- **Gateway API**: 18789
- **Web UI**: 1880

### 环境变量支持（新功能）
配置文件支持环境变量替换：
- `${OPENCLAW_API_KEY}` - API Key
- `${OPENCLAW_GATEWAY_TOKEN}` - 网关令牌
- `${HOME}` - 用户家目录

示例：`"apiKey": "${OPENCLAW_API_KEY}"`

### 插件安装
如需使用特定渠道插件（如飞书、Telegram），需额外安装：
```bash
pnpm install --filter @larksuiteoapi/feishu-openclaw-plugin
# 或
npm install -g @larksuiteoapi/feishu-openclaw-plugin
```

---

## 📝 工作记录

### 2025-06-17 - 项目全面重构（已完成）

**背景**: 初始版本错误地将 OpenClaw 描述为 SDL2 游戏，配置文件和脚本完全不适用。

**行动**:
1. 阅读 `openclaw-cn-termux` 仓库源码和 package.json，确认 OpenClaw 是 Node.js AI 助手
2. 基于用户提供的真实安装流程，重写所有文档
3. 删除游戏相关配置（config.ini, controls.ini）
4. 创建正确的配置模板（openclaw.json.example）
5. 保留并简化服务脚本（start-gateway.sh, stop-gateway.sh, check-env.sh）
6. 统一所有命令中的 `proot-distro install ubuntu`（不指定版本号）

**文档对齐**:
- README.md: 重写为简明指南，强调必须阅读 installation.md
- installation.md: 10章节详细流程（Termux → Ubuntu → Node.js → OpenClaw）
- faq.md: 24个Q&A，覆盖安装、配置、插件、性能、更新
- troubleshooting.md: 按阶段分类，包含网络、权限、端口、内存等问题

**提交历史** (推送到远程 `origin/main`):
- `bfc3322` - **feat: 添加 AidLux 安装支持并更新文档** (最新) ✅
  - 新增 `document/aidlux-installation.md` (579 行)
  - 新增 `scripts/install-aidlux.sh` (175 行)
  - 更新 README.md 包含 AidLux 安装选项
  - 更新 `scripts/install-openclaw.sh` 提示信息
- `f22cab5` - feat: add one-click install scripts for Ubuntu and OpenClaw
- `298ca00` - (original commit, rebased)
- `e3f8738` - refactor(install): 简化安装脚本并更新文档
- `9c7b276` - docs(scripts): 更新安装脚本中的项目名称
- `9dbcfaa` - docs: 更新项目仓库链接和安装文档内容
- `df068f6` - docs: use 'proot-distro install ubuntu' in boot script example
- `01a3084` - docs: update to use 'proot-distro install ubuntu' (no version suffix)
- `74deb8f` - docs: align all docs with final installation.md (proot-distro method)
- `45bf360` - docs: rewrite installation guide for proot-distro Ubuntu method
- `074887e` - refactor: rewrite project for OpenClaw AI assistant (not game)

**总计**: 12 个提交，持续迭代完善

---

### 2026-03-23 - 添加 AidLux 安装支持（最新）

**用户手动修改内容**:

用户添加了完整的 AidLux 安装路径，使项目同时支持两种 Android 平台：

**新增文件**:
- `document/aidlux-installation.md` - AidLux 详细安装手册（579 行，7 章节）
- `scripts/install-aidlux.sh` - AidLux 一键安装脚本（175 行）

**更新文件**:
- `README.md` - 增加 AidLux 安装方式和对比表格
- `scripts/install-openclaw.sh` - 优化安装提示信息

**AidLux 优势** (相比 Termux + Ubuntu):
- ✅ 安装更简单（无需 proot-distro，直接 Linux 环境）
- ✅ 提供完整 Linux 桌面体验
- ✅ 安装时间更短（15-20 分钟 vs 30-60 分钟）
- ✅ 适合初学者

**AidLux 劣势**:
- 需要额外安装 AidLux App
- 资源占用略高
- 环境与标准 Ubuntu 有差异（但兼容性仍很好）

**提交详情** (`bfc3322`):
```
4 files changed, 845 insertions(+), 18 deletions(-)
 - README.md: +105/-18 行
 - document/aidlux-installation.md: 新增 579 行
 - scripts/install-aidlux.sh: 新增 175 行
 - scripts/install-openclaw.sh: +4/-3 行
```

**项目当前状态**: ✅ 支持双平台安装，文档齐全，脚本自动化程度高

---

## ⚠️ 关键注意事项

1. **项目本质**: OpenClaw 是 **AI 助手系统**，不是游戏。避免添加图形配置、手柄控制等无关内容。
2. **安装方式**: 必须使用 `proot-distro + Ubuntu`，不推荐在 Termux 直接安装。
3. **版本号**: `proot-distro install ubuntu` 不指定版本，自动获取最新版。
4. **Node.js**: 必须 ≥ 22，推荐 24 LTS，使用 nvm 管理。
5. **必填配置**: `agent.apiKey`（AI 模型 API Key）。
6. **国内用户**: 需要配置镜像加速（`PROOT_DISTRO_MIRROR` 或 npm 淘宝镜像）。

---

## 🎯 使用流程（用户视角）

```bash
# 1. 克隆本项目
git clone https://github.com/byteuser1977/termux-install-openclaw.git
cd termux-install-openclaw

# 2. 阅读详细安装手册
cat document/installation.md

# 3. 按手册步骤操作（Termux → Ubuntu → Node.js → OpenClaw）

# 4. 启动服务
openclaw-cn-termux gateway

# 5. 访问 Web UI: http://localhost:1880
```

---

## 🔗 重要链接

- **本项目**: `d:\workspace\git\termux-install-openclaw`
- **远程仓库**: `https://github.com/byteuser1977/termux-install-openclaw`
- **OpenClaw 官网**: https://clawd.org.cn
- **OpenClaw-CN**: https://github.com/jiulingyun/openclaw-cn
- **Termux 应用**: https://github.com/termux/termux-app/releases
- **proot-distro**: https://github.com/termux/proot-distro

---

## 📊 项目统计

### 文件结构
- **文档文件**: 5 个
  - `README.md` - 项目快速指南
  - `document/installation.md` - Termux + Ubuntu 安装手册（10 章）
  - `document/aidlux-installation.md` - AidLux 安装手册（7 章）⭐ 新增
  - `document/faq.md` - 常见问题（24+ Q&A）
  - `document/troubleshooting.md` - 故障排查指南
- **配置文件**: 1 个
  - `config/openclaw.json.example` - 配置模板（支持环境变量）
- **脚本文件**: 7 个
  - `scripts/install-ubuntu.sh` - Termux 一键安装 Ubuntu
  - `scripts/install-openclaw.sh` - Ubuntu/AidLux 一键安装 OpenClaw
  - `scripts/install-aidlux.sh` - AidLux 专用安装脚本 ⭐ 新增
  - `scripts/start-gateway.sh` - 启动网关服务
  - `scripts/stop-gateway.sh` - 停止服务
  - `scripts/check-env.sh` - 环境诊断工具
  - `install.sh` - 快速环境检查（可选）
- **示例文件**: 1 个
  - `release/termux-app_v0.119.0-beta.3.apk` - Termux 应用（备用下载）

### Git 提交历史
```
bfc3322 feat: 添加 AidLux 安装支持并更新文档 (最新) ✅
9dbcfaa docs: 更新项目仓库链接和安装文档内容
9c7b276 docs(scripts): 更新安装脚本中的项目名称
e3f8738 refactor(install): 简化安装脚本并更新文档
f22cab5 feat: add one-click install scripts for Ubuntu and OpenClaw
... (共 12 个提交，持续优化)
```

### 代码规模（最新提交 bfc3322）
- **总变更**: +845 行插入, -18 行删除
- **核心贡献**:
  - AidLux 文档: 579 行
  - AidLux 脚本: 175 行
  - README 更新: +105/-18 行

---

**最后更新**: 2026-03-23
**状态**: ✅ 完整支持 Termux + Ubuntu 和 AidLux 双平台，文档齐全，一键脚本完善
**远程仓库**: https://github.com/byteuser1977/termux-install-openclaw
