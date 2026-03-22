# Termux OpenClaw 故障排查指南

> **版本**: v1.0.0-alpha  
> **最后更新**: 2026-03-22

---

## 🚨 常见问题速查

### 安装阶段问题

#### ❌ 错误: `pkg: command not found`

**症状**: 执行 `pkg update` 时报错

**原因**: Termux 环境未正确初始化

**解决**:
```bash
# 1. 确认在 Termux 应用中（非其他终端模拟器）
# 2. 重新安装 Termux（F-Droid 版本）
# 3. 首次运行执行：
termux-setup-storage
pkg update
```

---

#### ❌ 错误: `Unable to locate package sdl2`

**症状**: `pkg install sdl2` 失败

**原因**: 包仓库未更新或网络问题

**解决**:
```bash
# 1. 强制更新包列表
pkg update -y

# 2. 如果仍失败，检查网络
ping -c 1 termux.com

# 3. 更换镜像（编辑 ~/.pkg 或使用代理）
```

---

#### ❌ 编译错误: `CMake Error: Could not find SDL2`

**症状**: CMake 配置阶段失败

**原因**:
- SDL2 开发文件未安装
- CMake 找不到库路径

**解决**:
```bash
# 确认 SDL2 包已安装
pkg list-installed | grep sdl2

# 应看到：
# sdl2
# sdl2_image
# sdl2_mixer
# sdl2_ttf
# sdl2_gfx

# 如有缺失，重新安装：
pkg install -y sdl2 sdl2_image sdl2_mixer sdl2_ttf sdl2_gfx

# 清理构建目录重新配置
rm -rf build
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX="$PREFIX" ..
```

---

#### ❌ 编译错误: `fatal error: zlib.h: No such file`

**原因**: Zlib 开发库缺失

**解决**:
```bash
pkg install -y zlib
```

---

#### ❌ 编译错误: `collect2: error: ld returned 1 exit status`

**症状**: 链接阶段失败

**原因**: 内存不足或库路径冲突

**解决**:
1. **检查可用内存**:
   ```bash
   free -h
   ```
   建议：剩余 RAM ≥ 1GB

2. **降低并行度**:
   ```bash
   # 原命令：cmake --build . -- -j$(nproc)
   # 改为：
   cmake --build . -- -j2  # 仅用 2 个核心
   ```

3. **清理重试**:
   ```bash
   cd build
   make clean
   cmake --build . -- -j2
   ```

---

### 运行阶段问题

#### ❌ 错误: `cannot open display: No such file or directory`

**症状**: 启动游戏时报错

**原因**:
- Termux 未启用 X11 显示服务
- 未运行 XServer 应用

**解决**:

**方案 A: 使用 Termux:X11（推荐）**
```bash
# 1. 安装 X11 组件
pkg install -y x11-repo
pkg install -y termux-x11-nightly

# 2. 启动 X11 服务
termux-x11 :0 &

# 3. 设置 DISPLAY 环境变量
export DISPLAY=:0

# 4. 启动游戏
openclaw
```

**方案 B: 使用软件渲染（无需 X11）**
```bash
# 仅适用于新版 OpenClaw（支持软件后端）
export SDL_RENDERING_BACKEND=software
openclaw
```

---

#### ❌ 错误: `SDL could not initialize video: No available display`

**原因**: 同上，缺少显示服务器

**解决**: 参考上方 "cannot open display" 方案

---

#### ❌ 游戏启动后黑屏/闪退

**症状**: 窗口短暂出现后立即关闭

**可能原因与解决**:

1. **GPU 驱动不兼容**
   ```bash
   # 强制软件渲染
   export SDL_RENDER_DRIVER=software
   openclaw
   ```

2. **资源文件缺失**
   ```bash
   # 检查资源目录
   ls "$PREFIX/share/openclaw/"

   # 应包含：images/ sounds/ levels/ 等
   # 如为空，需手动复制资源文件
   ```

3. **权限问题**
   ```bash
   # 确保二进制文件可执行
   chmod +x "$PREFIX/bin/openclaw"

   # 检查用户配置目录权限
   chmod -R u+rw "$HOME/.openclaw"
   ```

4. **查看详细日志**
   ```bash
   # 启用调试输出
   OPENCLAW_DEBUG=1 openclaw 2>&1 | tee ~/openclaw.log

   # 检查日志文件
   cat ~/openclaw.log
   ```

---

#### ❌ 音频无声音

**症状**: 游戏运行但无声

**排查步骤**:

1. **检查系统音量**
   ```bash
   # Termux 音量控制
   termux-volume music 10
   termux-volume notification 10
   termux-volume alarm 10
   ```

2. **检查 SDL 音频驱动**
   ```bash
   # 尝试不同音频后端
   export SDL_AUDIODRIVER=opensles  # Android 默认
   # 或
   export SDL_AUDIODRIVER=alsa
   openclaw
   ```

3. **验证 SDL2_mixer**
   ```bash
   # 检查库文件
   ls "$PREFIX/lib/libSDL2_mixer.*"
   ```

4. **配置文件检查**
   编辑 `~/.openclaw/config.ini`:
   ```ini
   [audio]
   enabled=true
   music_volume=80
   sfx_volume=100
   ```

---

#### ❌ 触摸控制无响应

**症状**: 屏幕按钮无法点击

**解决**:

1. **校准触摸输入**
   ```bash
   termux-touchCalibrator
   ```

2. **检查控制配置**
   ```bash
   cat "$HOME/.openclaw/controls.ini"
   ```

3. **重启 X11 服务**（如果使用）
   ```bash
   pkill -f termux-x11
   termux-x11 :0 &
   ```

4. **验证 SDL 触摸支持**
   ```bash
   # 确保 SDL2 启用了触摸驱动
   export SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS=1
   openclaw
   ```

---

#### ❌ 游戏运行卡顿/帧率低

**诊断与优化**:

1. **监控性能**
   ```bash
   # 查看 CPU 频率和温度
   termux-cpu-info
   cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null
   ```

2. **降低图形设置**
   编辑 `~/.openclaw/config.ini`:
   ```ini
   [graphics]
   width=800          # 降低分辨率
   height=480
   texture_quality=low
   vsync=false        # 关闭垂直同步
   ```

3. **限制帧率**
   ```ini
   [performance]
   max_fps=30
   ```

4. **后台进程清理**
   ```bash
   # 查看占用
   top
   # 关闭不必要的应用
   ```

5. **启用性能模式**
   ```bash
   # 如果设备已 root
   cpufreq-set -g performance
   ```

---

#### ❌ 存档无法保存

**症状**: 游戏进度丢失

**原因**: 用户配置目录不可写

**解决**:
```bash
# 检查目录权限
ls -ld "$HOME/.openclaw"
ls -ld "$HOME/.openclaw/saves"

# 修复权限
chmod -R u+rwx "$HOME/.openclaw"

# 确保存储空间充足
df -h $HOME
```

---

#### ❌ 启动报错: `libSDL2-2.0.so.0: cannot open shared object file`

**原因**: 动态链接库路径未设置

**解决**:
```bash
# 方法 1: 设置 LD_LIBRARY_PATH
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
openclaw

# 方法 2: 将路径加入 ~/.bashrc 永久生效
echo 'export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 🔧 高级诊断

### 收集诊断信息

运行以下脚本打包所有相关信息：

```bash
#!/data/data/com.termux/files/usr/bin/bash
OUTPUT="$HOME/openclaw-diag-$(date +%Y%m%d-%H%M%S).tar.gz"

tar -czf "$OUTPUT" \
    "$HOME/.openclaw/" \
    "$PREFIX/bin/openclaw" \
    "$PREFIX/lib/libSDL2*" \
    <(echo "=== termux-info ===" && termux-info) \
    <(echo "=== pkg list-installed ===" && pkg list-installed) \
    <(echo "=== openclaw --version ===" && openclaw --version 2>&1 || echo "binary not found") \
    <(echo "=== env ===" && env) \
    2>/dev/null

echo "诊断包已生成: $OUTPUT"
```

### 查看系统日志

```bash
# Android 日志（需要 termux-api 或 root）
logcat -d | grep -i openclaw

# 或使用 termux 工具
termux-log 2>&1 | tail -50
```

---

## 📞 寻求帮助

### 提供信息

在提交 issue 或求助时，请提供以下内容：

1. **设备信息**
   - 手机型号
   - Android 版本
   - CPU 架构（`uname -m`）

2. **Termux 环境**
   ```bash
   termux-info
   pkg list-installed | grep -E 'sdl2|cmake|gcc'
   ```

3. **错误日志**
   ```bash
   OPENCLAW_DEBUG=1 openclaw 2>&1 | tee ~/error.log
   ```

4. **操作复现步骤**
   - 从哪个步骤开始出错？
   - 是否首次安装？
   - 之前是否正常运行过？

### 联系渠道

- **GitHub Issues**: https://github.com/yourusername/termux-install-openclaw/issues
- **OpenClaw 社区**: https://github.com/OpenClaw/OpenClaw/discussions
- **Termux 中文群组**: Telegram/QQ 频道

---

## 📑 版本相关

### 降级/升级

```bash
# 清理构建
cd ~/openclaw-build
rm -rf build src

# 切换分支或 tag
# 重新执行安装流程
./install.sh
```

### 完全卸载

```bash
# 1. 删除安装文件
rm -f "$PREFIX/bin/openclaw"
rm -rf "$PREFIX/share/openclaw"
rm -rf "$PREFIX/etc/openclaw"

# 2. 删除用户数据
rm -rf "$HOME/.openclaw"

# 3. 清理构建目录（可选）
rm -rf ~/openclaw-build

# 4. 卸载依赖（可选，保留其他用途）
# pkg uninstall sdl2 sdl2_image sdl2_mixer sdl2_ttf sdl2_gfx
```

---

**返回**: [installation.md](./installation.md) | [faq.md](./faq.md) | [README](../../README.md)