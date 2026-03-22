# Patches 目录

此目录用于存放针对 Termux/Android 平台的 OpenClaw 补丁文件。

## 使用方式

在 `scripts/install.sh` 的 `fetch_source()` 或 `build_openclaw()` 阶段，脚本会自动应用 `patches/*.patch` 文件：

```bash
for patch in ../patches/*.patch; do
    [ -e "$patch" ] || continue
    echo "应用补丁: $patch"
    git apply "$patch" || true
done
```

## 补丁命名规范

建议命名格式：`{issue-number}-{description}.patch`

示例：
- `android-touch-fix.patch`
- `termux-build-error-001.patch`

## 注意事项

- 补丁应基于 OpenClaw 官方仓库的对应分支
- 使用 `git format-patch` 或 `diff -u` 生成标准补丁
- 避免包含中间构建文件或二进制内容
