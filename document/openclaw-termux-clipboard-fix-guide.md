# OpenClaw-CN Termux 剪贴板模块问题修复指南

## 问题描述

在 Termux (Android) 环境下启动 `openclaw-termux` 时，遇到以下错误：

```
[openclaw-termux] os.networkInterfaces() method has been overloaded
[openclaw-termux] os.networkInterfaces() method has been overloaded
启动CLI失败： Error: Cannot find module '@mariozechner/clipboard-android-arm64'
Require stack:
- /data/data/com.termux/files/usr/lib/node_modules/openclaw-cn-termux/node_modules/@mariozechner/clipboard/index.js
    at Module._resolveFilename (node:internal/modules/cjs/loader:1475:15)
    at wrapResolveFilename (node:internal/modules/cjs/loader:1048:27)
    ...
```

## 问题根源

### 1. 原生模块缺失

`@mariozechner/clipboard` 是一个使用 NAPI-RS 构建的跨平台剪贴板库。它为不同的操作系统和架构提供预编译的原生二进制模块：

- Windows (win32-x64-msvc, win32-ia32-msvc, win32-arm64-msvc)
- macOS (darwin-universal, darwin-x64, darwin-arm64)
- Linux (linux-x64-gnu, linux-x64-musl, linux-arm64-gnu, linux-arm64-musl, ...)
- FreeBSD (freebsd-x64)

**但是**，对于 Android arm64 架构，该库声明需要 `@mariozechner/clipboard-android-arm64` 包，**这个包从未发布到 npm**。

查看 `@mariozechner/clipboard/package.json` 的 `binary` 配置：

```json
{
  "binary": {
    "module_name": "clipboard",
    "host": "android-arm64",
    "extra_files": ["clipboard.android-arm64.node"],
    "fallback_to_build": false
  }
}
```

它尝试加载一个不存在的 npm 包，导致 `MODULE_NOT_FOUND` 错误。

### 2. /tmp 目录问题（次要）

openclaw-cn-termux 的日志系统默认使用硬编码路径 `/tmp/clawdbot`，但在 Termux 中 `/tmp` 可能不存在或只读，会导致 `ENOENT` 错误。

**注**：此问题通常已在配置文件中修复，使用 `~/.openclaw/logs/clawdbot.log`。

## 失败尝试

### 尝试 1：手动安装缺失包

```bash
npm install -g @mariozechner/clipboard-android-arm64
```

**结果**：npm 返回 404 Not Found，包不存在。

### 尝试 2：使用 Linux 版本替代

```bash
npm install -g @mariozechner/clipboard-linux-arm64-gnu
```

**结果**：安装成功，但运行时失败：

```
Error: libgcc_s.so.1: cannot open shared object file: No such file or directory
```

原因：Linux 二进制文件依赖 glibc，而 Termux/Termux-X11 使用 musl libc，不兼容。

## 最终解决方案

### 核心思路

放弃依赖原生二进制模块，将 Android arm64 的实现替换为使用 **Termux 命令**：

- `termux-clipboard-get` —— 获取剪贴板文本
- `termux-clipboard-set` —— 设置剪贴板文本

这两个命令由 `termux-api` 包提供，在 Termux 中稳定可用。

### 前置条件

确保已安装 `termux-api`：

```bash
pkg install termux-api -y
```

验证命令存在：

```bash
which termux-clipboard-get
which termux-clipboard-set
```

应返回：

- `/data/data/com.termux/files/usr/bin/termux-clipboard-get`
- `/data/data/com.termux/files/usr/bin/termux-clipboard-set`

### 修复步骤

#### 步骤 1：定位目标文件

被修改的文件路径：

```
/data/data/com.termux/files/usr/lib/node_modules/openclaw-cn-termux/node_modules/@mariozechner/clipboard/index.js
```

#### 步骤 2：备份原始文件（可选但建议）

```bash
cp /data/data/com.termux/files/usr/lib/node_modules/openclaw-cn-termux/node_modules/@mariozechner/clipboard/index.js{,.bak}
```

#### 步骤 3：修改代码

找到 `switch (platform)` 中的 `case 'android':` 下的 `case 'arm64':` 代码块（第 34-45 行）。

**原始代码**：

```javascript
case 'arm64':
  localFileExisted = existsSync(join(__dirname, 'clipboard.android-arm64.node'))
  try {
    if (localFileExisted) {
      nativeBinding = require('./clipboard.android-arm64.node')
    } else {
      nativeBinding = require('@mariozechner/clipboard-android-arm64')
    }
  } catch (e) {
    loadError = e
  }
  break
```

**替换为**：

```javascript
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
      // 图片/HTML/RTF 等功能返回 null 或抛出错误（Termux 不支持）
      getImageBinary: async () => null,
      getImageBase64: async () => null,
      setImageBinary: async () => { throw new Error('Clipboard image not supported on Android/Termux') },
      setImageBase64: async () => { throw new Error('Clipboard image not supported on Android/Termux') },
      hasImage: async () => false,
      getHtml: async () => null,
      setHtml: async () => { throw new Error('Clipboard HTML not supported on Android/Termux') },
      hasHtml: async () => false,
      getRtf: async () => null,
      setRtf: async () => { throw new Error('Clipboard RTF not supported on Android/Termux') },
      hasRtf: async () => false,
      clear: async () => { throw new Error('Clipboard clear not supported on Android/Termux') },
      watch: (callback) => { return () => {} },
      callThreadsafeFunction: () => {}
    }
  } catch (e) {
    loadError = e
  }
  break
```

**修改说明**：

- 不再尝试加载原生二进制模块
- 使用 `child_process.execFile` 调用 Termux 命令
- 实现 `clipboard` 模块的全部 API，但仅支持文本功能
- 图片、HTML、RTF 等功能返回 `null` 或抛出错误（Termux 不支持）
- `watch` 返回空函数（无实时监控能力）

#### 步骤 4：验证语法

使用 Node.js 检查语法：

```bash
node -c /data/data/com.termux/files/usr/lib/node_modules/openclaw-cn-termux/node_modules/@mariozechner/clipboard/index.js
```

无输出表示语法正确。

### 验证修复

#### 1. 测试 CLI 启动

```bash
openclaw-termux --version
```

应输出版本号，不再报错。

#### 2. 测试 Gateway 启动

```bash
# 前台运行 3 秒后自动退出
timeout 3 openclaw-termux gateway

# 或直接运行（需手动 Ctrl+C 停止）
openclaw-termux gateway
```

应正常启动，无异常崩溃。

#### 3. 测试剪贴板功能

在 openclaw-termux 中执行：

```bash
# 打开 TUI 界面测试
openclaw-termux tui

# 或在 agent 轮次中测试复制粘贴
```

或在 Node.js REPL 中直接测试：

```javascript
const clipboard = require("@mariozechner/clipboard");
await clipboard.setText("Hello from Termux!");
const text = await clipboard.getText();
console.log(text); // 输出: Hello from Termux!
```

## 注意事项

### 1. 临时性修改

此修复直接修改 `node_modules` 中的文件，**升级 openclaw-cn-termux 时会重置**。升级后需重新应用本方案。

**建议**：

- 保存本指南和修改片段
- 或在 `~/.openclaw/` 创建补丁脚本，升级后自动重打

### 2. 功能限制

Termux 环境下剪贴板仅支持**纯文本**：

- ❌ 图片复制/粘贴
- ❌ HTML 富文本
- ❌ RTF 格式
- ❌ 实时监控 (`watch` 无效)

如需图片等功能，需在支持原生模块的设备上运行（如桌面或服务器）。

### 3. 上游修复建议

期望 `@mariozechner/clipboard` 或 `openclaw-cn-termux` 上游能：

1. 为 Android 发布原生二进制包，或
2. 在检测到 Android 环境时自动降级到系统命令实现，或
3. 使用纯 JavaScript 实现（如 `clipboardy` 已有 Android 支持）

### 4. 日志目录配置

确保 `~/.openclaw/openclaw.json` 包含：

```json
{
  "logging": {
    "level": "info",
    "file": "/data/data/com.termux/files/home/.openclaw/logs/clawdbot.log"
  }
}
```

避免使用 `/tmp` 路径。

## 相关资源

- `@mariozechner/clipboard` 仓库：https://github.com/mariozechner/clipboard-rs
- Termux API 文档：https://wiki.termux.com/wiki/Termux:API
- OpenClaw-CN 文档：https://docs.clawd.bot/cli

## 故障排除

| 症状                                      | 可能原因           | 解决方法                                                     |
| ----------------------------------------- | ------------------ | ------------------------------------------------------------ |
| `termux-clipboard-get: command not found` | termux-api 未安装  | `pkg install termux-api`                                     |
| 修改后仍报 module not found               | 修改位置错误       | 确认修改的是 `node_modules/@mariozechner/clipboard/index.js` |
| Gateway 启动后立即退出                    | 其他配置错误       | 查看日志 `~/.openclaw/logs/clawdbot.log`                     |
| 剪贴板返回空字符串                        | 剪贴板为空或无权限 | 先在其他应用复制文本，再测试                                 |

---

**文档版本**：1.0.0  
**创建日期**：2026-04-13  
**适用环境**：Termux + openclaw-cn-termux v0.2.1-beta.0  
**Hermes Agent 记录**：Hermes (Nous Research)
