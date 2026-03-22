# Termux OpenClaw 常见问题 (FAQ)

> **版本**: v1.0.0-alpha  
> **最后更新**: 2026-03-22

---

## 🎯 快速问答

### Q1: Termux 是什么？为什么需要它？

**A**: Termux 是 Android 上的 Linux 模拟环境，提供完整的包管理器和命令行工具链。OpenClaw 是原生 Linux 应用，需要 Termux 提供的编译环境和运行时库才能在 Android 上运行。

**相关**: [README.md](../README.md) - 前置要求

---

### Q2: 必须用 F-Droid 版本的 Termux 吗？

**A**: **强烈推荐**。Google Play 版本的 Termux 存在包管理问题，很多包无法正常安装或更新。F-Droid 版本维护活跃，兼容性更好。

**下载**: https://f-droid.org/en/packages/com.termux/

---

### Q3: 需要 Android 版本是多少？

**A**: 最低 Android 7.0 (API 24)，推荐 Android 10+ (API 29+)。新版本提供更好的性能优化和权限管理。

**检查**: `termux-info` 查看 API Level

---

### Q4: 安装需要多长时间？

**A**: 取决于设备性能：
- **高性能** (骁龙 855/8 Gen 系列): 20-30 分钟
- **中端** (骁龙 7/6 系列): 30-50 分钟
- **低端** (入门级 ARM): 60-90 分钟

主要耗时在编译阶段（CPU 密集型）。

---

### Q5: 编译失败怎么办？

**A**: 常见解决步骤：
1. **检查依赖**: `pkg list-installed | grep sdl2` 确认 SDL2 全家桶已安装
2. **清理重试**: `rm -rf build && mkdir build && cd build`
3. **降低并行**: `cmake --build . -- -j2`（减少 CPU 核心数）
4. **查看日志**: 错误信息通常很明确，搜索或查看 [troubleshooting.md](./troubleshooting.md)

**常见错误**:
- `SDL.h not found` → `pkg install sdl2`
- `zlib.h not found` → `pkg install zlib`
- `内存不足` → 关闭后台应用或 swap 文件

---

### Q6: 游戏启动黑屏/闪退？

**A**: 可能原因和解决：
1. **GPU 驱动问题** → 软件渲染
   ```bash
   export SDL_RENDER_DRIVER=software
   openclaw
   ```
2. **资源文件缺失** → 确认 `$PREFIX/share/openclaw/` 非空
3. **权限问题** → `chmod +x $PREFIX/bin/openclaw`

详细排查: [troubleshooting.md](./troubleshooting.md) - 运行阶段问题

---

### Q7: 有声音吗？如何调节音量？

**A**:
- 游戏内音量: 编辑 `~/.openclaw/config.ini`
- 系统音量: `termux-volume music 10` (0-10)
- 通话音量: `termux-volume call 10`

**无声排查**:
```bash
pkg install sdl2_mixer  # 确认安装
export SDL_AUDIODRIVER=opensles
```

---

### Q8: 支持手柄吗？

**A**: 是。OpenClaw 支持：
- **蓝牙手柄**: 配对后自动识别
- **键盘**: USB OTG 连接
- **触摸屏**: 虚拟按钮

控制映射编辑: `~/.openclaw/controls.ini`

---

### Q9: 游戏存档在哪里？

**A**: 存档位于 `~/.openclaw/saves/`
- 自动存档: 每关结束后
- 手动存档: 游戏内菜单
- 备份方法: 复制整个 `saves/` 目录

---

### Q10: 可以自定义分辨率吗？

**A**: 是。在 `~/.openclaw/config.ini` 修改：
```ini
[graphics]
width=800
height=480
fullscreen=false
```

**性能建议**:
- 高分辨率 (1280x720): 适合旗舰设备
- 中分辨率 (800x480): 平衡画质与性能
- 低分辨率 (640x480): 老旧设备推荐

---

### Q11: 如何卸载？

**A**: 完整卸载脚本：

```bash
#!/data/data/com.termux/files/usr/bin/bash

# 删除二进制
rm -f "$PREFIX/bin/openclaw"

# 删除系统配置
rm -rf "$PREFIX/etc/openclaw"

# 删除用户数据（存档、设置）
rm -rf "$HOME/.openclaw"

# 可选：卸载依赖（保留则跳过）
# pkg uninstall sdl2 sdl2_image sdl2_mixer sdl2_ttf sdl2_gfx

echo "OpenClaw 已完全卸载"
```

---

### Q12: 为什么需要这么多依赖？

**A**: OpenClaw 是跨平台 C++ 项目，依赖成熟的开源库：
- **SDL2**: 跨平台多媒体（图形、音频、输入）
- **SDL2_image**: 图像加载（PNG/JPEG）
- **SDL2_mixer**: 音频混音（MP3/OGG）
- **SDL2_ttf**: TrueType 字体渲染
- **SDL2_gfx**: 2D 图形原语

这些库在 Linux/Windows/macOS 上同样需要，Termux 只是提供 Android 上的兼容层。

---

### Q13: 可以在 iOS 上运行吗？

**A**: 当前项目仅支持 Android/Termux。iOS 需要：
- 越狱 + Alpine Linux（不推荐）
- 或等待官方 iOS 移植（未计划）

---

### Q14: 资源文件（图像、音效）从哪里获取？

**A**:
1. **官方 OpenClaw 资源包**: 从 [OpenClaw/OpenClaw](https://github.com/OpenClaw/OpenClaw) 仓库下载 `resources/` 目录
2. **社区打包版**: 搜索 "OpenClaw resources pack"
3. **自己提取**: 从 Windows/Linux 版安装目录复制

**安装位置**: `$PREFIX/share/openclaw/`

---

### Q15: 如何更新到最新版本？

**A**:

```bash
cd ~/openclaw-build/src
git pull origin master

# 清理并重新构建
cd ../build
rm -rf *
cmake .. -DCMAKE_INSTALL_PREFIX="$PREFIX"
cmake --build . -- -j$(nproc)
cmake --install .

# 验证
openclaw --version
```

**注意**: 注意检查配置文件兼容性（新版本可能引入新配置项）。

---

### Q16: 可以玩多人游戏吗？

**A**: OpenClaw 目前主要是 **单人单机** 游戏。多人联机功能在官方路线图上，但尚未实现。

---

### Q17: 支持中文显示吗？

**A**: 取决于资源文件。如果资源包含中文字体（`.ttf`），OpenClaw 可以显示中文。需：
1. 确保 `SDL2_ttf` 已安装
2. 在 `config.ini` 指定中文字体路径（如支持）

当前默认资源为英文，中文汉化需社区制作翻译包。

---

### Q18: 如何贡献代码或报告 Bug？

**A**:
- **Bug 报告**: 在 GitHub Issues 提供设备信息、日志、复现步骤
- **功能请求**: Discussions > Ideas
- **代码贡献**: Fork → 修改 → Pull Request（遵循代码规范）

详见 [CONTRIBUTING.md](../CONTRIBUTING.md)（待补充）

---

### Q19: 项目是否有计划支持云存档？

**A**: 目前无内置云存档功能。可手动备份 `~/.openclaw/saves/` 到网盘，或编写同步脚本。

---

### Q20: 可以在没有网络的情况下运行吗？

**A**: 可以。安装完成后，游戏完全离线运行，无需网络连接。

**离线前准备**:
1. 完成编译安装
2. 下载所有资源文件
3. 验证可启动

---

## 🔍 术语表

| 术语 | 解释 |
|------|------|
| **Termux** | Android Linux 模拟环境 |
| **SDL2** | 跨平台多媒体库（Simple DirectMedia Layer） |
| **CMake** | 构建系统生成工具 |
| **pkg** | Termux 包管理器（类似 apt） |
| **$PREFIX** | Termux 安装前缀，通常是 `/data/data/com.termux/files/usr` |
| **arm64 / aarch64** | 64 位 ARM 架构 |
| **软件渲染** | 使用 CPU 而非 GPU 进行图形渲染，兼容性好但速度慢 |

---

## 📚 附录

### 其他资源

- **OpenClaw 官方 Wiki**: https://github.com/OpenClaw/OpenClaw/wiki
- **SDL2 文档**: https://wiki.libsdl.org/
- **Termux Wiki**: https://wiki.termux.com/
- **Android NDK 开发**: https://developer.android.com/ndk

---

**返回**: [troubleshooting.md](./troubleshooting.md) | [README.md](../README.md)

仍有疑问？打开 [GitHub Issue](https://github.com/yourusername/termux-install-openclaw/issues) 提问。