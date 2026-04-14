# macos-app-dual-open

一个用于创建和管理 macOS 应用 `secondary` 副本的小型 Bash CLI。

[Landing Page](./README.md) | [English](./README.en.md)

## 功能概览

- 基于原始 `.app` 创建 `-secondary.app` 副本
- 读取原始 `CFBundleIdentifier` 并改写为 `.secondary` 后缀
- 对副本重新本地签名
- 统一提供 `clone / launch / update / remove` 四个子命令
- 默认不修改原始 app，也不清理用户 `~/Library` 数据

## 快速开始

```bash
bin/app-dual clone "/Applications/WeChat.app"
bin/app-dual launch "/Applications/WeChat.app"
bin/app-dual update "/Applications/WeChat.app"
bin/app-dual remove "/Applications/WeChat.app"
```

典型场景下，位于 `/Applications` 下的 app 需要使用 `sudo` 执行 `clone`、`update`、`remove`：

```bash
sudo bin/app-dual clone "/Applications/WeChat.app"
sudo bin/app-dual update "/Applications/WeChat.app"
sudo bin/app-dual remove "/Applications/WeChat.app"
```

## 命名规则

给定：

```text
/Applications/WeChat.app
com.tencent.xinWeChat
```

生成的 secondary 副本为：

```text
/Applications/WeChat-secondary.app
com.tencent.xinWeChat.secondary
```

规则：

- 副本 app 文件名统一追加 `-secondary`
- 副本 Bundle ID 统一追加 `.secondary`
- `clone`、`update`、`remove` 要求传入原始 `.app` 路径，不接受已有 `-secondary.app` 作为 source 输入

## 命令

### `bin/app-dual clone <app-path>`

- 校验原始 app 路径
- 复制 app 包到 `-secondary.app`
- 修改副本 `CFBundleIdentifier`
- 对副本重新签名

示例：

```bash
sudo bin/app-dual clone "/Applications/WeChat.app"
```

### `bin/app-dual launch <app-path>`

- 根据原始 app 路径推导 `-secondary.app`
- 使用 `open -a` 启动副本
- 允许 path-first 行为：只要副本存在，即使原始 app 当前路径不存在，也会按推导路径尝试启动

示例：

```bash
bin/app-dual launch "/Applications/WeChat.app"
```

### `bin/app-dual update <app-path>`

- 删除旧的 secondary 副本
- 从原始 app 重新生成副本
- 保留用户数据目录，不主动清理 `~/Library`

示例：

```bash
sudo bin/app-dual update "/Applications/WeChat.app"
```

### `bin/app-dual remove <app-path>`

- 删除推导出的 `-secondary.app`
- 不删除 `~/Library`、Keychain 或其他用户数据

示例：

```bash
sudo bin/app-dual remove "/Applications/WeChat.app"
```

## 行为说明

- `clone` 会创建一个新的 secondary app 副本
- `launch` 的效果接近于手动打开 `WeChat-secondary.app`
- `update` 只输出 `Updated` 成功日志，不重复输出 `Created`
- `remove` 只删除副本 app，不影响原始 app

## 安全边界

- 原始 app 包不会被修改
- 原始 app 的 `Info.plist` 不会被修改
- 原始 app 的签名不会被修改
- 工具不会清理 `~/Library`、Keychain 或其他用户数据
- 并非所有 macOS app 都支持作为第二实例运行

## 开发 / 测试

运行测试：

```bash
bash tests/run.sh
```

当前自动化测试覆盖：

- 公共路径与命名规则 helper
- `clone` 行为与副本 Bundle ID 改写
- `launch` 行为与 path-first 约定
- `update` / `remove` 行为
- “不修改原始 app”的安全边界

## License

详见 [LICENSE](./LICENSE)。
