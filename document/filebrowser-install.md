# FileBrowser 快速安装 (Termux) v2.63.2

**一键安装脚本 + 自动配置**

---

## 方式一：简短版（推荐）

```bash
# 1. 创建目录
cd
mkdir -p ~/bin

# 2. 下载并直接解压到 ~/bin
cd ~/bin
wget -qO- https://github.com/filebrowser/filebrowser/releases/download/v2.63.2/linux-arm64-filebrowser.tar.gz | tar -xz

# 3. 创建软链接
ln -sf ~/bin/filebrowser /data/data/com.termux/files/usr/bin/filebrowser

# 4. 初始化配置
mkdir -p ~/.filebrowser
cat > ~/.filebrowser/filebrowser.json << 'EOF'
{
  "port": 28000,
  "address": "0.0.0.0",
  "database": "/data/data/com.termux/files/home/.filebrowser/filebrowser.db",
  "root": "/data/data/com.termux/files/home/storage/documents",
  "auth": { "method": "password" },
  "branding": { "name": "Bit Boss Files" },
  "thumbnails": { "enabled": false },
  "share": { "enabled": true, "expire": "168h" },
  "log": { "level": "info", "format": "logfmt" },
  "hidden": [".git", ".DS_Store", "Thumbs.db"],
  "allowEmpty": false,
  "commands": ["hash", "help"]
}
EOF

# 5. 创建启动脚本
cat > ~/bin/start-fb << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
CONFIG="$HOME/.filebrowser/filebrowser.json"
PIDFILE="$HOME/.filebrowser/filebrowser.pid"
LOG="$HOME/.filebrowser/filebrowser.log"
mkdir -p "$(dirname "$PIDFILE")"

# 防止重复启动
[ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null && echo "已在运行" && exit 1

nohup filebrowser -c "$CONFIG" > "$LOG" 2>&1 &
EOF
chmod +x ~/bin/start-fb

# 6. 确保 PATH 包含 ~/bin
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

**安装完成！**

**修改密码：**
```bash
filebrowser -c ~/.filebrowser/filebrowser.json users update admin -p 'termux123456'
```
.

**修改密码：**
```bash
filebrowser -c ~/.filebrowser/filebrowser.json users update admin -p '新密码(12位以上)'
```
**启动服务：**
```bash
echo $! > "$PIDFILE"
echo "✓ FileBrowser 已启动"
echo "访问: http://localhost:28000"
echo "账号: admin / termux123456"
start-fb
```
---

## 访问

打开浏览器访问：

**http://localhost:28000**

- 用户名: `admin`
- 密码: `termux123456`

⚠️ **首次登录后建议立即修改密码！**

---

## 文件说明

| 文件/目录 | 说明 |
|-----------|------|
| `~/bin/filebrowser` | 主程序 |
| `/data/data/com.termux/files/usr/bin/filebrowser` | 系统软链接 |
| `~/.filebrowser/filebrowser.json` | 配置文件 |
| `~/.filebrowser/filebrowser.db` | 数据库 |
| `~/.filebrowser/filebrowser.log` | 日志 |
| `~/bin/start-fb` | 启动脚本 |

---

## 提示

- 根目录指向 `~/storage/documents`，可在此目录管理文件
- 如需外网访问，配置 Nginx 反向代理并开启 HTTPS
- 缩略图已禁用（Termux 环境下建议保持）
- 分享链接默认 7 天过期

**安装完成！** 🎉
