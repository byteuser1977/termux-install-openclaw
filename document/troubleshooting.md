# Termux OpenClaw 故障排查

本指南帮助解决在 Termux 环境中安装和运行 OpenClaw 时遇到的常见问题。

## 📦 安装阶段问题

### ❌ pkg: command not found

**症状**: 执行 `pkg update` 报错  
**原因**: 未在 Termux 应用中运行  
**解决**: 确保你正在 Termux（而不是其他终端模拟器）中操作

---

### ❌ 无法安装 Node.js 或版本太低

**症状**: `pkg install nodejs` 安装的版本 < 22  
**原因**: Termux 仓库版本滞后  
**解决**:

```bash
# 方法1: 尝试更新源
pkg update -y
pkg install -y nodejs

# 方法2: 使用 nvm 安装（需额外步骤）
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22
```

---

### ❌ pnpm install 失败（网络超时）

**症状**: `pnpm install` 过程中卡住或超时  
**原因**: 国内网络访问 npm registry 较慢  
**解决**:

```bash
# 设置淘宝镜像
pnpm config set registry https://registry.npmmirror.com
# 或
npm config set registry https://registry.npmmirror.com

# 使用 pnpm store 加速
pnpm config set store-dir ~/.pnpm-store

# 重试
cd openclaw
pnpm install --frozen-lockfile
```

---

### ❌ git clone 失败（SSL certificate problem）

**症状**: `SSL certificate problem: unable to get local issuer certificate`  
**原因**: CA 证书未正确安装  
**解决**:

```bash
pkg install -y ca-certificates
update-ca-certificates
```

---

### ❌ 构建失败：JavaScript heap out of memory

**症状**: 编译时内存不足  
**原因**: Termux 内存限制，构建大型项目需要较多 RAM  
**解决**:

```bash
# 限制并发数
cd openclaw
export NODE_OPTIONS="--max-old-space-size=1024"
pnpm build --concurrency 1
```

或在手机上关闭其他应用释放内存。

---

## 🏃 运行阶段问题

### ❌ 命令 not found: pnpm start:gateway

**症状**: `pnpm start:gateway` 未找到  
**原因**: 未在项目根目录或 pnpm 未正确配置  
**解决**:

```bash
# 确认在 openclaw 目录
cd openclaw
ls -la package.json

# 检查 pnpm 是否可用
pnpm --version

# 使用直接命令
node dist/index.js gateway
```

---

### ❌ 端口已占用（EADDRINUSE）

**症状**: `Error: listen EADDRINUSE: address already in use :::18789`  
**原因**: 端口 18789 被其他进程占用  
**解决**:

1. 查找占用进程：
```bash
lsof -i :18789
# 或
netstat -tulpn | grep 18789
```

2. 杀死进程：
```bash
kill <PID>
```

3. 或修改端口：编辑 `~/.openclaw/openclaw.json`，更改 `gateway.port`

---

### ❌ Gateway 启动后立即退出

**症状**: 看到 PID 但进程很快消失  
**原因**: 配置错误或依赖缺失  
**解决**:

```bash
# 查看日志
cat ~/.openclaw/gateway.log

# 常见原因：
# - API Key 未配置（配置 agent.apiKey）
# - 端口权限不足（使用非特权端口 >1024）
# - 配置文件 JSON 格式错误（使用 jsonlint 检查）
```

---

### ❌ Web UI 无法访问（Connection refused）

**症状**: `curl: (7) Failed to connect`  
**原因**:
- Gateway 未启动
- 绑定地址为 localhost 而非 lan
- 防火墙阻止

**解决**:

```bash
# 1. 确认 Gateway 运行
ps aux | grep openclaw
# 或检查 PID 文件
cat ~/.openclaw/gateway.pid

# 2. 检查配置
cat ~/.openclaw/openclaw.json | grep -A2 '"gateway"'
# 确保 "bind": "lan" 或 "0.0.0.0"

# 3. 重启服务
./scripts/stop-gateway.sh
./scripts/start-gateway.sh

# 4. 检查防火墙（如使用 iptables）
iptables -L
```

---

### ❌ 插件加载失败（Cannot find module）

**症状**: `Cannot find module '@larksuiteoapi/feishu-openclaw-plugin'`  
**原因**: 插件依赖未安装  
**解决**:

```bash
cd openclaw
pnpm install --filter @larksuiteoapi/feishu-openclaw-plugin
pnpm build
```

如果问题持续，删除 `node_modules` 和 `dist` 后重装：
```bash
rm -rf node_modules dist
pnpm install
pnpm build
pnpm ui:build
```

---

### ❌ 中文乱码

**症状**: 日志或 Web UI 显示乱码  
**原因**: 环境没有正确设置 UTF-8 编码  
**解决**:

```bash
# 设置本地化环境
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

# 检查 Termux 本地化
locale
# 如未配置：
pkg install -y tzdata
termux-setup-storage
```

---

## 🐛 日志与诊断

### 启用调试日志

编辑 `~/.openclaw/openclaw.json`：

```json
{
  "gateway": {
    "logLevel": "debug"
  }
}
```

重启 Gateway 后查看详细日志：

```bash
tail -f ~/.openclaw/gateway.log
```

---

### 生成诊断报告

运行环境检查脚本：

```bash
./scripts/check-env.sh > env-check.txt 2>&1
```

收集以下信息并附带到 Issue：

- `termux-info` 输出
- `node --version`, `pnpm --version`
- `cat ~/.openclaw/openclaw.json`（脱敏 API Key）
- `tail -50 ~/.openclaw/gateway.log`

---

## 📦 卸载与重装

### 完全卸载

```bash
# 1. 停止服务
./scripts/stop-gateway.sh

# 2. 删除安装文件
cd ..
rm -rf openclaw

# 3. 删除配置和数据（确保不再需要）
rm -rf ~/.openclaw
```

### 重新安装

```bash
./install.sh
```

---

## 🆘 仍然无法解决？

1. 查阅 [OpenClaw 官方文档](https://clawd.org.cn/docs)
2. 搜索 [GitHub Issues](https://github.com/jiulingyun/openclaw-cn/issues)
3. 加入 [Discord 社区](https://discord.gg/clawd) 提问
4. 提交新的 Issue，提供：
   - 设备型号、Android 版本
   - Termux 版本
   - 错误日志（完整）
   - 配置文件（脱敏）
   - 操作复现步骤

---

**祝你好运！** 🎉
