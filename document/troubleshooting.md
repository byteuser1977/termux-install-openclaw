# Termux OpenClaw 故障排查

本指南帮助解决在 Termux + Ubuntu 环境中安装和运行 OpenClaw-CN 时遇到的常见问题。

---

## 📦 安装阶段问题

### ❌ proot-distro: command not found

**症状**: 执行 `proot-distro` 报错  
**原因**: termux-tools 未安装或未授权  
**解决**:
```bash
# 在 Termux 中重新安装
apt update
apt install termux-tools -y
# 确保 Termux 有存储权限（termux-setup-storage 已执行）
```

---

### ❌ proot-distro install ubuntu 失败（网络超时或下载中断）

**原因**: 网络不稳定或镜像源不可用  
**解决**:

**方法1: 使用清华镜像（推荐）**

在 Termux 中设置环境变量：

```bash
export PROOT_DISTRO_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/termux/proot-distro"
proot-distro install ubuntu
```

可以将 `export PROOT_DISTRO_MIRROR="..."` 加入 `~/.bashrc` 永久生效。

**方法2: 手动下载并安装**

```bash
# 手动下载 rootfs.tar.gz
cd ~
wget https://mirrors.tuna.tsinghua.edu.cn/termux/proot-distro/ubuntu/rootfs.tar.gz

# 安装（使用本地文件）
proot-distro install ubuntu
```

---

### ❌ Ubuntu 启动失败（ denying permission to /dev/...）

**症状**: `proot-distro login ubuntu` 时报权限错误  
**原因**: Termux 存储权限未正确授权  
**解决**:
```bash
# 在 Termux 中重新授权存储
termux-setup-storage

# 检查软链接是否存在
ls -la ~/storage
# 应看到 shared, downloads 等软链接

# 重启 Termux 应用，重新尝试登录
```

---

### ❌ apt update 失败（GPG error 或 404 Not Found）

**原因**: Ubuntu sources.list 配置错误或镜像问题  
**解决**:
```bash
# 进入 Ubuntu
proot-distro login ubuntu

# 备份并重置 sources.list
cp /etc/apt/sources.list /etc/apt/sources.list.bak
cat > /etc/apt/sources.list <<'EOF'
deb http://archive.ubuntu.com/ubuntu jammy main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu jammy-security main restricted universe multiverse
EOF

# 更新
apt update
```

如果国内访问慢，替换为清华镜像：
```bash
sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
```

---

### ❌ nvm 安装失败（curl: (7) Failed to connect）

**原因**: 网络无法访问 raw.githubusercontent.com  
**解决**:
```bash
# 使用国内镜像（gitee）
export NVM_URL="https://gitee.com/mirrors/nvm"
curl -o- https://gitee.com/mirrors/nvm/raw/v0.40.3/install.sh | bash

# 或手动下载
wget https://gitee.com/mirrors/nvm/releases/download/v0.40.3/nvm-0.40.3.tar.gz
tar -xzf nvm-0.40.3.tar.gz -C ~
```

然后手动加载：
```bash
\. "$HOME/.nvm/nvm.sh"
```

---

### ❌ Node.js 安装失败（Download failed或 checksum mismatch）

**原因**: 网络问题导致下载不完整  
**解决**:
```bash
# 清理 nvm 缓存
nvm cache clear

# 使用国内镜像下载 Node.js
# 方法1: 配置 nvm 使用淘宝镜像
export NVM_NODEJS_ORG_MIRROR="https://npmmirror.com/mirrors/node"

# 方法2: 手动下载并安装
cd /tmp
wget https://npmmirror.com/mirrors/node/v24.14.0/node-v24.14.0-linux-arm64.tar.xz
tar -xf node-v24.14.0-linux-arm64.tar.xz
mv node-v24.14.0-linux-arm64 ~/.nvm/versions/node/v24.14.0

nvm use 24
node --version
```

---

### ❌ npm install -g openclaw-cn-termux 失败（权限错误或 EACCES）

**症状**: `npm ERR! Error: EACCES: permission denied`  
**原因**: 全局安装目录权限不足（尤其是使用 `/usr/local` 作为 prefix 时）  
**解决**:

**方案 A**: 使用用户目录（推荐）
```bash
# 设置 npm 用户目录（不在 root 下）
npm config set prefix "${HOME}/.npm-global"

# 添加到 PATH
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 重新安装
npm install -g openclaw-cn-termux@latest
```

**方案 B**: 使用 sudo（不推荐，破坏安全性）
```bash
sudo npm install -g openclaw-cn-termux@latest
```

---

### ❌ 下载速度慢（npm/pnpm）

**解决**:
```bash
# 设置淘宝镜像
npm config set registry https://registry.npmmirror.com
# 或使用 pnpm（更快）
npm install -g pnpm
pnpm config set registry https://registry.npmmirror.com

# 使用 pnpm 安装
pnpm add -g openclaw-cn-termux@latest

# 清理缓存加速
pnpm store prune
```

---

## 🏃 运行阶段问题

### ❌ openclaw-cn-termux: command not found

**原因**: npm 全局 bin 目录不在 PATH 中  
**解决**:
```bash
# 查看 bin 目录
npm bin -g
# 假设输出: /home/openclaw/.npm-global/bin

# 添加到 PATH
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 验证
which openclaw-cn-termux || which openclaw-termux
```

---

### ❌ 端口被占用（EADDRINUSE）

**症状**: 启动时报错 `listen EADDRINUSE: address already in use :::18789`  
**原因**: 端口 18789 或 1880 已被其他进程占用

**解决**:
```bash
# 查看占用进程
sudo lsof -i :18789
sudo lsof -i :1880

# 杀死进程
sudo kill <PID>

# 或修改配置使用其他端口
# 编辑 ~/.openclaw/openclaw.json
# "gateway": { "port": 18790 }
```

---

### ❌ Gateway 启动后立即退出

**原因**: 配置文件错误或缺失 API Key  
**解决**:
```bash
# 查看日志
tail -50 ~/.openclaw/gateway.log

# 常见错误：
# - API Key 未设置：编辑 ~/.openclaw/openclaw.json
# - JSON 格式错误：使用 jsonlint 检查
# - 端口权限不足（<1024）：使用 >1024 端口

# 验证配置
cat ~/.openclaw/openclaw.json | python3 -m json.tool > /dev/null
# 无输出表示 JSON 有效
```

---

### ❌ 无法访问 Web UI（Connection refused）

**原因**:
- Gateway 未运行
- 绑定地址为 localhost
- 防火墙限制

**解决**:
```bash
# 1. 检查 Gateway 状态
ps aux | grep openclaw
# 或
sudo systemctl status openclaw  # 如果使用了 systemd

# 2. 检查配置
cat ~/.openclaw/openclaw.json | grep -A2 '"gateway"'
# 应包含 "bind": "lan" 或 "0.0.0.0"

# 3. 重启服务
# 如果使用 nohup:
pkill -f "openclaw.*gateway"
nohup openclaw-cn-termux gateway > ~/.openclaw/gateway.log 2>&1 &

# 如果使用 systemd:
sudo systemctl restart openclaw
```

---

### ❌ 插件加载失败（Cannot find module）

**症状**: `Error: Cannot find module '@larksuiteoapi/feishu-openclaw-plugin'`  
**原因**: 插件依赖未安装

**解决**:
```bash
# 在 Ubuntu 中（openclaw 用户）
cd ~
pnpm install --filter @larksuiteoapi/feishu-openclaw-plugin
# 或
npm install -g @larksuiteoapi/feishu-openclaw-plugin
```

然后重启网关。

---

### ❌ 中文乱码

**原因**: 环境未正确设置 UTF-8  
**解决**:
```bash
# 在 Ubuntu 中（~/.bashrc）
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

source ~/.bashrc

# 检查
locale
# 应显示 LANG=zh_CN.UTF-8
```

如未安装中文语言包：
```bash
sudo apt install -y language-pack-zh-hans
sudo locale-gen zh_CN.UTF-8
```

---

## 🐛 日志与诊断

### 启用详细日志

编辑 `~/.openclaw/openclaw.json`：
```json
{
  "gateway": {
    "logLevel": "debug"
  }
}
```

重启后查看：
```bash
tail -f ~/.openclaw/gateway.log
```

---

### 收集诊断信息

```bash
#!/bin/bash
# generate-diagnostic-report.sh

cat > ~/openclaw-diagnostic.txt <<EOF
=== System Info ===
date: $(date)
uname -a: $(uname -a)
lsb_release: $(lsb_release -a 2>/dev/null || echo "N/A")
termux-info: $(termux-info 2>/dev/null || echo "Not in Termux")

=== Node & npm ===
node --version: $(node --version 2>/dev/null || echo "N/A")
npm --version: $(npm --version 2>/dev/null || echo "N/A")
pnpm --version: $(pnpm --version 2>/dev/null || echo "N/A")

=== OpenClaw ===
openclaw-cn-termux --version: $(openclaw-cn-termux --version 2>/dev/null || echo "N/A")
which openclaw: $(which openclaw-cn-termux 2>/dev/null || echo "Not found")

=== Config ===
cat ~/.openclaw/openclaw.json 2>/dev/null || echo "Config not found"

=== Processes ===
ps aux | grep openclaw

=== Log Tail ===
EOF

tail -50 ~/.openclaw/gateway.log 2>/dev/null >> ~/openclaw-diagnostic.txt || echo "No log file"

echo "诊断报告已生成: ~/openclaw-diagnostic.txt"
```

---

## 📦 卸载

### 完全卸载

```bash
# 1. 停止服务
pkill -f "openclaw.*gateway"
# 或
sudo systemctl stop openclaw
sudo systemctl disable openclaw

# 2. 删除全局包
npm uninstall -g openclaw-cn-termux
# 或
pnpm remove -g openclaw-cn-termux

# 3. 删除配置和数据
rm -rf ~/.openclaw

# 4. 删除 Ubuntu 容器（可选）
# 在 Termux 中
proot-distro remove ubuntu
```

---

## 🆘 仍然无法解决？

1. **查阅官方文档**: https://clawd.org.cn/docs
2. **搜索 GitHub Issues**: https://github.com/jiulingyun/openclaw-cn/issues
3. **加入 Discord 社区**: https://discord.gg/clawd
4. **提交新 Issue**，提供：
   - Termux 版本
   - Ubuntu 版本
   - Node.js 版本
   - `~/.openclaw/openclaw.json`（脱敏）
   - 错误日志（完整）
   - 操作复现步骤

---

**祝你好运！** 🎉
