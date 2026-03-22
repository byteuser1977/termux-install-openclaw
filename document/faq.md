# Termux OpenClaw 常见问题

## 📦 安装与配置

### Q1: 为什么需要 proot-distro 和 Ubuntu？

OpenClaw-CN 是为标准 Linux 环境设计的，依赖许多 Linux 工具和库。Termux 本身是 Android 上的 Linux 用户空间，但某些库可能缺失或版本不符。通过 proot-distro 运行完整的 Ubuntu 系统可以保证与服务器部署环境的完全一致，避免兼容性问题。

**简言之**: 这是最稳定、最接近生产环境的安装方式。

---

### Q2: Termux 从哪里下载？

从 **F-Droid** 下载最新版：
https://github.com/termux/termux-app/releases

不要使用 Google Play 的旧版本。

---

### Q3: proot-distro 安装 Ubuntu 很慢怎么办？

首次安装需要下载约 200-300 MB 的 rootfs 镜像。可以更换为国内镜像源加速：

```bash
# 在 Termux 中执行前，编辑或创建
mkdir -p ~/.proot-distro
cat > ~/.proodistrotostatic/ etc/apt/sources.list <<'EOF'
# 清华大学镜像
deb http://mirrors.tuna.tsinghua.edu.cn/termux/proot-distro/ubuntu-22.04 jammy main
# 或使用官方源
# deb http://termux.net/proot-distro/ubuntu-22.04 jammy main
EOF
```

或在 `proot-distro install` 时指定镜像。

---

### Q4: 如何选择 Ubuntu 版本？

- **Ubuntu 22.04 (jammy)**: 长期支持版，稳定性好，兼容性最佳
- **Ubuntu 24.04 (noble)**: 较新，软件版本更新，但可能存在未知问题

**推荐**: 新手使用 22.04，追求新特性可试用 24.04。

---

### Q5: nvm 安装失败怎么办？

确保网络通畅，可以尝试：
```bash
# 使用国内镜像安装 nvm
export NVM_URL="https://gitee.com/mirrors/nvm"
curl -o- https://gitee.com/mirrors/nvm/raw/v0.40.3/install.sh | bash
```

或手动下载脚本：
```bash
wget https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh
bash install.sh
```

---

### Q6: Node.js 安装哪个版本？

OpenClaw-CN 需要 **Node.js ≥ 22**。推荐使用 **Node.js 24**（当前 LTS）。

```bash
nvm install --lts   # 安装最新 LTS
nvm alias default 24
```

---

### Q7: npm 全局安装很慢/失败？

使用淘宝镜像：
```bash
npm config set registry https://registry.npmmirror.com
```

或使用 pnpm（更快）：
```bash
npm install -g pnpm
pnpm config set registry https://registry.npmmirror.com
pnpm add -g openclaw-cn-termux@latest
```

---

### Q8: 命令行找不到 `openclaw-cn-termux`？

检查 npm 全局 bin 目录是否在 PATH 中：

```bash
# 查看 npm 全局安装位置
npm config get prefix
# 通常是 /home/openclaw/.npm-global 或 /usr/local

# 查看 bin 目录
npm bin -g

# 添加到 PATH（编辑 ~/.bashrc）
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
# 或如果使用 /usr/local:
# echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc

source ~/.bashrc

# 重新检查
which openclaw-cn-termux || which openclaw-termux
```

---

### Q9: 配置文件在哪里？

- **位置**: `~/.openclaw/openclaw.json`
- **首次创建**: 运行 `openclaw-cn-termux onboard` 交互式向导
- **手动创建**: 复制 `config/openclaw.json.example` 并编辑

---

### Q10: 如何配置 API Key？

编辑 `~/.openclaw/openclaw.json`：

```json
{
  "agent": {
    "model": "anthropic/claude-sonnet-4-5",
    "apiKey": "sk-your-api-key-here"
  }
}
```

支持的模型：
- OpenAI: `gpt-4o`, `gpt-4-turbo`, `gpt-4o-mini`
- Claude (通过 OpenAI 兼容端点): `anthropic/claude-sonnet-4-5`
- 其他 OpenAI 兼容接口

---

## 🔌 渠道插件

### Q11: 如何使用飞书插件？

1. **安装插件依赖**（在 Ubuntu 中）：
   ```bash
   cd ~
   pnpm install --filter @larksuiteoapi/feishu-openclaw-plugin
   ```

2. **配置 `openclaw.json`**：
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

3. **按照官方文档完成飞书应用配置**：https://clawd.org.cn/channels/feishu.html

---

### Q12: 如何使用 Telegram Bot？

1. 通过 [@BotFather](https://t.me/botfather) 创建 Bot，获取 token

2. 配置：
   ```json
   {
     "plugins": {
       "telegram": {
         "enabled": true,
         "botToken": "123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
       }
     }
   }
   ```

3. 确保插件已安装：
   ```bash
   pnpm install --filter @openclaw/telegram-plugin
   ```

---

### Q13: 插件安装失败（Cannot find module）？

确认插件包已安装到 `node_modules`：

```bash
cd ~
pnpm install --filter <plugin-name>
# 例如:
pnpm install --filter @larksuiteoapi/feishu-openclaw-plugin
```

如果仍失败，可能是插件未发布到 npm 或需要从源码构建。参考对应插件的 README。

---

## 🖥️ 运行问题

### Q14: 启动后无法访问 Web UI？

1. **确认网关正在运行**：
   ```bash
   ps aux | grep openclaw
   # 或
   curl http://localhost:18789/health
   ```

2. **检查端口是否被占用**：
   ```bash
   lsof -i :18789
   lsof -i :1880
   ```

3. **检查配置绑定地址**：
   ```bash
   cat ~/.openclaw/openclaw.json | grep -A2 '"gateway"'
   # 确保 "bind": "lan" 或 "0.0.0.0"
   ```

4. **查看日志**：
   ```bash
   tail -f ~/.openclaw/gateway.log
   ```

---

### Q15: 如何让服务开机自启动？

在 Ubuntu 中使用 systemd（proot-distro 支持 systemd）：

```bash
# 在 Ubuntu 中
sudo nano /etc/systemd/system/openclaw.service
```

内容：
```ini
[Unit]
Description=OpenClaw Gateway
After=network.target

[Service]
Type=simple
User=openclaw
WorkingDirectory=/home/openclaw
ExecStart=/usr/bin/openclaw-cn-termux gateway
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

然后：
```bash
sudo systemctl daemon-reload
sudo systemctl enable openclaw
sudo systemctl start openclaw
```

---

### Q16: 日志文件在哪里？

- **网关日志**: `~/.openclaw/gateway.log`（如果使用 `nohup` 或脚本）
- **系统日志**: `journalctl -u openclaw`（如果使用 systemd）
- **应用日志**: `~/.openclaw/logs/`
- **内存数据**: `~/.openclaw/memory/`

---

### Q17: 中文乱码？

确保环境变量设置：
```bash
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
```

Ubuntu 默认已配置 UTF-8，应该没问题。如果仍乱码，检查终端编码设置（Termux 设置 → Terminal → Character encoding 选 UTF-8）。

---

## ⚡ 性能与优化

### Q18: 内存占用过高？

OpenClaw 本身内存占用不大（~100-200MB），但如果模型 API 响应慢或配置了大型插件，可能导致累积。

**优化建议**：
1. 限制并发请求数（配置中暂无直接选项，可通过插件配置）
2. 关闭不需要的插件
3. 使用更小的 AI 模型（如 `gpt-4o-mini` 替代 `gpt-4o`）
4. 调整 Node.js 内存限制（如内存确实不足）：
   ```bash
   export NODE_OPTIONS="--max-old-space-size=512"
   ```

---

### Q19: CPU 占用高？

正常运行时 CPU 占用应很低（<5%）。高占用可能原因：
- 某个插件死循环
- 频繁的 AI 请求（大量用户同时使用）
- 日志级别设为 debug（增加 I/O）

**解决**：
- 检查日志，定位高负载插件
- 设置 `"gateway.logLevel": "warn"` 减少日志
- 优化插件逻辑或限制请求频率

---

## 🔄 更新与维护

### Q20: 如何更新 OpenClaw？

```bash
cd ~
pnpm update -g openclaw-cn-termux
# 或
npm update -g openclaw-cn-termux

# 如果从源码安装，需要重新构建
# 但 npm 包已经预构建，直接更新即可
```

更新后重启服务。

---

### Q21: 备份数据

```bash
# 备份配置和内存
tar -czf ~/openclaw-backup-$(date +%Y%m%d).tar.gz ~/.openclaw/

# 恢复
tar -xzf ~/openclaw-backup-*.tar.gz -C ~/
```

---

## 🆘 其他问题

### Q22: Termux 和 Ubuntu 之间如何传输文件？

通过共享存储目录：
- Termux 共享目录: `~/storage/shared/`
- Ubuntu 访问: `/mnt/shared/`（自动挂载）

```bash
# 在 Ubuntu 中
ls /mnt/shared/Download/
```

---

### Q23: 可以在 Termux 直接安装，不用 proot-distro 吗？

技术上可以，但存在兼容性问题（库版本、glibc 版本等）。**不推荐**。如果坚持尝试：

```bash
# 在 Termux 中
pkg install nodejs
npm install -g openclaw-cn-termux
```

但可能会遇到各种构建错误。

---

### Q24: 支持 Docker 吗？

Ubuntu 容器内可以安装 Docker，但需要嵌套虚拟化，性能较差。推荐直接使用系统服务（systemd）管理。

---

## 📞 获取帮助

- **官方文档**: https://clawd.org.cn/docs
- **GitHub Issues**: https://github.com/jiulingyun/openclaw-cn/issues
- **Discord 社区**: https://discord.gg/clawd
- **中文交流**: 参考项目 README 和 Discussions

提交 Issue 时请提供：
- Termux 版本 (`termux-info`)
- Ubuntu 版本 (`lsb_release -a`)
- Node.js 版本 (`node --version`)
- `~/.openclaw/openclaw.json`（脱敏 API Key）
- 错误日志 (`tail -50 ~/.openclaw/gateway.log`)
