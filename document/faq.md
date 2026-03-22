# Termux OpenClaw 常见问题

## 📱 安装与配置

### Q1: 安装脚本提示"Node.js 版本过低"怎么办？

Termux 默认仓库的 Node.js 可能不是最新版。运行：

```bash
pkg update -y
pkg upgrade -y nodejs
```

或手动安装最新：
```bash
pkg install -y nodejs
```

### Q2: 如何配置 API Key？

编辑 `~/.openclaw/openclaw.json`，在 `agent.apiKey` 字段填入你的 AI 模型 API Key（如 OpenAI、Claude 等）。

示例：
```json
{
  "agent": {
    "model": "anthropic/claude-sonnet-4-5",
    "apiKey": "sk-your-api-key-here"
  }
}
```

### Q3: 支持哪些 AI 模型？

OpenClaw 支持 OpenAI 兼容接口：
- GPT-4o, GPT-4-turbo
- Claude 系列（通过 OpenAI 兼容端点）
- 其他兼容 OpenAI 格式的模型

### Q4: 配置文件在哪里？

- 系统示例: `termux-install-openclaw/config/openclaw.json.example`
- 用户配置: `~/.openclaw/openclaw.json`
- 这是唯一需要手动编辑的配置文件

---

## 🔌 渠道插件

### Q5: 如何使用飞书插件？

1. 确保已安装飞书插件依赖：
```bash
cd openclaw
pnpm install --filter @larksuiteoapi/feishu-openclaw-plugin
```

2. 在 `openclaw.json` 启用并配置：
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

3. 按照 [飞书官方文档](https://clawd.org.cn/channels/feishu.html) 完成应用配置。

### Q6: 如何使用 Telegram Bot？

1. 通过 [@BotFather](https://t.me/botfather) 创建 Bot，获取 token

2. 配置 `openclaw.json`：
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

### Q7: 插件安装失败？

检查网络连接，尝试使用国内镜像：

```bash
pnpm config set registry https://registry.npmmirror.com
```

---

## 🖥️ 运行问题

### Q8: 启动后无法访问 Web UI？

1. 确认 Gateway 正在运行：
```bash
./scripts/start-gateway.sh
```

2. 查看日志：
```bash
tail -f ~/.openclaw/gateway.log
```

3. 检查端口是否被占用：
```bash
lsof -i :18789
```

4. 在 Termux 内部访问：`http://localhost:1880`
   在局域网其他设备访问：`http://<设备IP>:1880`

### Q9: 如何让后台服务开机自启动？

Termux 不支持真正的开机自启，但可以使用 `termux-boot` 插件：

1. 安装 termux-boot：
```bash
pkg install termux-boot
```

2. 创建启动脚本 `~/.termux/boot/start-openclaw`：
```bash
#!/data/data/com.termux/files/usr/bin/bash
cd /data/data/com.termux/files/home/openclaw
pnpm start:gateway
```

3. 赋予权限：
```bash
chmod +x ~/.termux/boot/start-openclaw
```

重启设备后服务会自动启动。

### Q10: 日志文件在哪里？

- Gateway 日志: `~/.openclaw/gateway.log`
- 应用日志: `~/.openclaw/logs/`
- 内存数据: `~/.openclaw/memory/`

---

## ⚡ 性能与优化

### Q11: 如何降低 CPU/内存占用？

1. 关闭不必要的插件
2. 调低模型采样参数（如 max_tokens）
3. 限制并发请求数
4. 使用更小的模型（如 gpt-4o-mini 替代 gpt-4o）

编辑配置：
```json
{
  "agent": {
    "maxTokens": 1024,
    "temperature": 0.7
  }
}
```

### Q12: 移动网络下耗电快？

建议：
- 使用 `daemon.enabled: false`（按需启动）
- 降低日志级别：`"gateway": { "logLevel": "warn" }`
- 禁用不需要的渠道插件

---

## 🔄 更新与维护

### Q13: 如何更新到最新版本？

```bash
cd openclaw
git pull origin main
pnpm install
pnpm build
pnpm ui:build
```

### Q14: 如何备份数据？

备份整个配置目录：
```bash
tar -czf openclaw-backup-$(date +%Y%m%d).tar.gz ~/.openclaw/
```

恢复：
```bash
tar -xzf openclaw-backup-*.tar.gz -C ~/
```

---

## 🆘 其他问题

### Q15: 安装过程中断怎么办？

可以安全地重新运行 `./install.sh`，脚本支持断点续传。

### Q16: 如何查看详细错误日志？

```bash
# 查看网关日志
cat ~/.openclaw/gateway.log

# 启用调试模式（编辑配置文件）
{
  "gateway": {
    "logLevel": "debug"
  }
}
```

### Q17: 支持 Docker 部署吗？

支持！但需要 Termux 内的 Docker 环境（如 `proot-distro` 安装 Debian 后运行 Docker）。更推荐使用原生 Node.js 安装方式。

建议参考 `openclaw-cn-termux` 项目的 `docker-setup.sh` 了解 Docker 部署选项。

---

## 📞 获取帮助

- **官方文档**: https://clawd.org.cn/docs
- **GitHub Issues**: https://github.com/jiulingyun/openclaw-cn/issues
- **Discord 社区**: https://discord.gg/clawd
- **中文交流群**: 参考项目 README

提交 Issue 时请提供：
- Termux 版本 (`termux-info`)
- 安装日志
- `~/.openclaw/openclaw.json`（脱敏后）
