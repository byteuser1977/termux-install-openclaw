# Termux OpenClaw 详细安装手册

> **版本**: v1.0.0-alpha  
> **最后更新**: 2026-03-22

---

## 📋 目录

1. [概述](#概述)
2. [前置检查](#前置检查)
3. [依赖安装](#依赖安装)
4. [源码获取](#源码获取)
5. [构建过程](#构建过程)
6. [安装配置](#安装配置)
7. [后续优化](#后续优化)
8. [命令行参考](#命令行参考)

---

## 📝 概述

本手册提供在 Android Termux 环境中从源码编译和安装 OpenClaw 的完整步骤。适用于需要自定义编译选项或理解整个安装流程的高级用户。

### 预期时间

| 步骤 | 预计时长 | 影响因素 |
|------|----------|----------|
| 依赖安装 | 5-15 分钟 | 网络速度、设备性能 |
| 源码下载 | 2-5 分钟 | 网络速度（约 50-100 MB） |
| 编译构建 | 10-60 分钟 | CPU 核心数、主频、散热 |
| 安装验证 | 1 分钟 | - |

**总计**: 约 20-80 分钟，取决于设备性能。

---

## 🔍 前置检查

### 1.1 检查 Termux 版本

```bash
termux-info
```

确保以下信息符合要求：
- **Termux 版本**: ≥ 0.101.0
- **API Level**: ≥ 24 (Android 7.0)
- **架构**: aarch64 (ARM64) 推荐

输出示例：
```
Termux Info:
  API level: 30
  ABI: aarch64
  SDK: 29
```

### 1.2 检查存储权限

确保 Termux 已获得存储访问权限：

```bash
# 查看存储目录是否可访问
ls ~/storage 2>/dev/null

# 如未授权，运行：
termux-setup-storage
```

首次运行 `termux-setup-storage` 后，需要**手动授权** Termux 访问存储权限（弹出系统对话框）。

### 1.3 检查磁盘空间

```bash
# 查看可用空间（至少需要 1GB）
df -h $HOME
```

推荐：剩余空间 ≥ 2 GB（包含源码、构建文件和最终安装）。

### 1.4 检查 CPU 信息

```bash
# 查看 CPU 架构和核心数
uname -m
nproc
```

建议：ARM64 设备，4 核心及以上可获得较好编译速度。

---

## 📦 依赖安装

### 2.1 更新包管理器

```bash
pkg update -y
pkg upgrade -y
```

**注意**：
- 如果提示 "Do you want to continue?"，输入 `Y`
- 确保网络通畅（可访问 Termux 镜像源）

### 2.2 安装基础工具链

```bash
pkg install -y \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    cmake \
    pkg-config
```

**解释**：
- `build-essential`: GCC 编译器、make、binutils
- `cmake`: 构建系统生成器
- `pkg-config`: 库依赖检测工具

### 2.3 安装 SDL2 多媒体库

OpenClaw 依赖 SDL2 及其扩展库进行图形、音频和输入处理：

```bash
pkg install -y \
    sdl2 \
    sdl2_image \
    sdl2_mixer \
    sdl2_ttf \
    sdl2_gfx
```

**验证安装**：
```bash
pkg list-installed | grep sdl2
```

应看到以上所有包标记为 `installed`。

### 2.4 安装其他运行时依赖

```bash
pkg install -y \
    libiconv \
    zlib
```

### 2.5 可选：性能优化工具

```bash
# CPU 频率调节（需要 root）
# pkg install cpufrequtils

# 性能监控
pkg install -y htop
```

---

## 📥 源码获取

### 3.1 克隆 OpenClaw 仓库

```bash
# 创建工作目录
mkdir -p ~/openclaw-build
cd ~/openclaw-build

# 克隆官方仓库（最新 master 分支）
git clone --depth 1 https://github.com/OpenClaw/OpenClaw.git src

# 进入源码目录
cd src

# 查看分支信息
git branch -a
```

### 3.2 指定特定版本（可选）

如需稳定版本，检出对应 tag：

```bash
# 查看可用标签
git tag -l

# 切换至 v1.2.0 版本（示例）
git checkout tags/v1.2.0
```

### 3.3 应用 Android 补丁（如有）

如果项目包含针对 Termux/Android 的补丁：

```bash
# 进入项目根目录
cd ~/openclaw-build/src

# 应用补丁
for patch in ../patches/*.patch; do
    echo "应用补丁: $patch"
    git apply "$patch" || true
done
```

---

## 🔨 构建过程

### 4.1 创建构建目录

```bash
cd ~/openclaw-build
mkdir -p build
cd build
```

### 4.2 配置 CMake

```bash
cmake \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_BUILD_TYPE=Release \
    ../src
```

**参数说明**：
- `CMAKE_INSTALL_PREFIX`: 安装目标目录，Termux 标准位置为 `$PREFIX`
- `CMAKE_BUILD_TYPE`: 构建类型，`Release` 为优化版本（推荐），`Debug` 用于调试

**常见配置选项**：
```bash
# 启用/禁用组件
-DENABLE_EDITOR=ON      # 构建关卡编辑器（可能需要额外依赖）
-DENABLE_TESTS=OFF      # 不构建测试套件

# 指定资源路径（如果资源文件在外部）
-DRESOURCE_DIR="$PREFIX/share/openclaw"
```

### 4.3 编译源码

```bash
# 自动检测 CPU 核心数并行编译
cmake --build . -- -j$(nproc)

# 或手动指定并行数（例如 4 个任务）
cmake --build . -- -j4
```

**编译日志**：
- 正常输出：`[ 50%] Building CXX object ...`
- 错误：`error: ...`（停止并显示问题）

### 4.4 编译时长参考

| 设备 CPU | 核心数 | 预估时长 |
|----------|--------|----------|
| 骁龙 855 | 8 | ~15 分钟 |
| 骁龙 765G | 8 | ~25 分钟 |
| 骁龙 480 | 8 | ~35 分钟 |
| 中低端 Cortex-A53 | 4-8 | ~60 分钟 |

---

## 📦 安装配置

### 5.1 安装到系统目录

```bash
cmake --install .
```

这将复制：
- 可执行文件 → `$PREFIX/bin/openclaw`
- 共享资源（图像、音效、关卡） → `$PREFIX/share/openclaw/`
- 默认配置 → `$PREFIX/etc/openclaw/`

### 5.2 创建用户配置目录

```bash
mkdir -p "$HOME/.openclaw"
```

首次运行会自动生成配置文件。

### 5.3 验证安装

```bash
# 检查可执行文件
ls -lh "$PREFIX/bin/openclaw"

# 测试运行（显示版本信息）
openclaw --version

# 如果提示 command not found，确保 PATH 包含 $PREFIX/bin
echo 'export PATH="$HOME/.local/bin:$PREFIX/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## ⚙️ 配置说明

### 6.1 配置文件结构

```
~/.openclaw/
├── config.ini      # 主配置文件
├── controls.ini    # 控制映射（可选）
└── saves/          # 游戏存档目录
```

### 6.2 默认配置项

编辑 `~/.openclaw/config.ini`：

```ini
[graphics]
# 分辨率设置
width=1280
height=720
fullscreen=false
vsync=true

# 纹理质量 (low/medium/high)
texture_quality=high

[audio]
enabled=true
music_volume=80
sfx_volume=100

[controls]
# 输入设备启用
touch_enabled=true
keyboard_enabled=true
gamepad_enabled=true

[performance]
# 最大帧率（0 表示不限制）
max_fps=60

# 渲染驱动 (auto/opengles/software)
render_driver=auto
```

### 6.3 控制映射（controls.ini）

```ini
[keyboard]
# 格式: action=key
move_left=LEFT
move_right=RIGHT
jump=SPACE
attack=LCONTROL

[touch]
# 触摸屏按钮位置（百分比）
jump_button_x=50
jump_button_y=80
attack_button_x=80
attack_button_y=80
```

---

## 🚀 后续优化

### 7.1 性能调优

1. **降低分辨率**
   ```ini
   width=800
   height=480
   ```

2. **使用软件渲染（无 GPU 加速设备）**
   ```bash
   export SDL_RENDER_DRIVER=software
   openclaw
   ```

3. **限制帧率以省电**
   ```ini
   max_fps=30
   ```

### 7.2 资源包

原始游戏资源（图片、音效、关卡数据）需另外获取。将资源文件复制到 `$PREFIX/share/openclaw/`：

```bash
# 示例：复制资源包
cp -r /sdcard/OpenClaw-Resources/* "$PREFIX/share/openclaw/"
```

### 7.3 创建快捷方式

```bash
# 添加到主屏幕（Termux:Widget）
echo "#!/data/data/com.termux/files/usr/bin/bash" > ~/.shortcuts/openclaw.sh
echo "openclaw" >> ~/.shortcuts/openclaw.sh
chmod +x ~/.shortcuts/openclaw.sh
```

---

## 💻 命令行参考

| 命令 | 说明 |
|------|------|
| `openclaw` | 启动游戏 |
| `openclaw --version` | 显示版本信息 |
| `openclaw --fullscreen` | 全屏启动 |
| `openclaw --res=800x480` | 指定分辨率启动 |
| `OPENCLAW_DEBUG=1 openclaw` | 调试模式（输出日志） |

### 环境变量

| 变量 | 说明 | 示例 |
|------|------|------|
| `OPENCLAW_CONFIG` | 指定配置文件路径 | `export OPENCLAW_CONFIG=~/myconfig.ini` |
| `SDL_RENDER_DRIVER` | 强制渲染驱动 | `export SDL_RENDER_DRIVER=software` |
| `OPENCLAW_DEBUG` | 启用调试日志 | `export OPENCLAW_DEBUG=1` |

---

## 📚 附录

### A. 编译错误排查

| 错误信息 | 可能原因 | 解决方案 |
|----------|----------|----------|
| `SDL.h: No such file` | SDL2 开发包未安装 | `pkg install sdl2` |
| `CMake Error` | CMake 版本过低 | `pkg install cmake` |
| `permission denied` | 缺少执行权限 | `chmod +x script.sh` |

### B. 运行问题排查

| 问题 | 可能原因 | 解决方案 |
|------|----------|----------|
| 黑屏/闪退 | GPU 驱动问题 | 使用 `SDL_RENDER_DRIVER=software` |
| 无声音 | SDL2_mixer 缺失 | `pkg install sdl2_mixer` |
| 触摸无效 | 输入配置错误 | 检查 `controls.ini` |

### C. 卸载

```bash
# 删除二进制文件
rm -f "$PREFIX/bin/openclaw"

# 删除系统配置
rm -rf "$PREFIX/etc/openclaw"

# 删除用户数据（存档）
rm -rf "$HOME/.openclaw"
```

---

**如有问题，请参考 [troubleshooting.md](./troubleshooting.md) 或 [FAQ](./faq.md)**

返回 [README](../README.md) 主页