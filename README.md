# Arcane Launcher 奥术启动器

基于 Flutter 的《魔兽世界》模拟器桌面启动器,用于一键管理 TrinityCore 系模拟器的核心服务并启动游戏客户端。支持 **Windows / macOS / Linux** 三大桌面平台。

![Flutter](https://img.shields.io/badge/Flutter-3.29+-02569B?logo=flutter) ![Dart](https://img.shields.io/badge/Dart-3.7+-0175C2?logo=dart) ![License](https://img.shields.io/badge/License-MIT-green)

## 功能特性

- **一键启动游戏** — 按依赖顺序依次启动 `mysqld` → `worldserver` / `authserver`,待世界服务就绪后自动拉起客户端
- **客户端自动配置** — 启动前自动清理客户端 `Cache` 目录,并写入 `realmlist.wtf` 登录地址
- **服务管理** — 对 MySQL、世界服务器、登录服务器进行启动 / 停止 / 状态切换,侧边栏实时展示运行状态
- **实时日志** — 主界面三块日志面板实时展示 mysqld / worldserver / authserver 输出,并可手动刷新
- **进程守护** — 每 15 秒轮询进程,服务异常退出时自动同步为停止状态
- **自动发现配置** — 只需选择服务端与客户端目录,自动扫描模拟器根目录、解析 conf,填充 mysqld / worldserver / authserver 的路径、配置与日志,未命中的项可在高级配置中手动指定
- **多服务器配置** — 支持维护多套服务器配置(路径、版本、登录地址等),下拉切换激活
- **模拟器配置编辑** — 应用内直接读写 `worldserver.conf` / `authserver.conf`
- **外部应用快捷启动** — 自定义添加常用外部程序,一键启动
- **个性化主题** — 主题色自定义 + 深色 / 浅色模式切换

## 界面概览

- **启动器页** — 核心服务状态、实时日志、服务器切换、一键开始/关闭服务与启动客户端
- **模拟器配置页** — 编辑当前服务器的 worldserver / authserver 配置文件
- **设置页** — 服务器管理、外部应用管理、主题设置

## 技术栈

| 分类 | 技术 |
| --- | --- |
| UI 框架 | Flutter (Material 3) |
| 状态管理 | [signals](https://pub.dev/packages/signals) |
| 依赖注入 | [get_it](https://pub.dev/packages/get_it) |
| 配置存储 | [yaml](https://pub.dev/packages/yaml) / [yaml_writer](https://pub.dev/packages/yaml_writer) + [shared_preferences](https://pub.dev/packages/shared_preferences) |
| 窗口管理 | [window_manager](https://pub.dev/packages/window_manager) |
| 文件选择 | [file_picker](https://pub.dev/packages/file_picker) |
| 图标 | [lucide_icons_flutter](https://pub.dev/packages/lucide_icons_flutter) |

## 架构

采用 MVVM 模式,页面与状态解耦:

```
lib/
├── main.dart                  # 入口:初始化窗口、依赖注入、预加载数据
├── di.dart                    # get_it 依赖注册
├── page/                      # 页面层
│   ├── launcher/              # 启动器主界面(服务状态 + 日志 + 一键启动)
│   ├── config/                # 模拟器配置页(worldserver / authserver 配置编辑)
│   └── setting/               # 设置页(服务器、外部应用、主题)
├── view_model/                # ViewModel 层(signals 响应式状态)
│   ├── server_view_model.dart
│   ├── game_view_model.dart   # 启动编排与进程守护
│   ├── mysqld_view_model.dart
│   ├── world_server_view_model.dart
│   ├── auth_server_view_model.dart
│   └── ...
├── schema/                    # 数据模型(Server / Setting / ExternalApplication)
├── model/                     # 服务信息模型(ServiceInformation)
├── util/                      # 进程工具、YAML 存储、偏好设置
├── widget/                    # 通用组件(按钮、卡片、日志视图、表单等)
└── theme/                     # 主题与设计令牌
```

## 环境要求

- Flutter SDK(Dart SDK **^3.7.2**,见 `pubspec.yaml`)
- 桌面平台工具链:Windows (VS 2022 + C++ 工具链)、macOS (Xcode)、Linux (CMake + GTK)

## 快速开始

```bash
# 1. 获取依赖
flutter pub get

# 2. 运行(选择目标平台)
flutter run -d windows
flutter run -d macos
flutter run -d linux

# 3. 构建发布版本
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

## 配置文件

应用在**工作目录**下读写以下 YAML 文件(写入采用临时文件 + 原子重命名,避免中途退出损坏配置):

### servers.yaml

| 字段 | 说明 |
| --- | --- |
| `name` / `description` / `version` | 服务器名称、描述、版本 |
| `local` | 是否本地服务器 |
| `realm_list` | 客户端 `realmlist.wtf` 中写入的登录地址 |
| `mysqld_path` | mysqld 可执行文件路径 |
| `world_server_path` / `auth_server_path` | 世界 / 登录服务可执行文件路径 |
| `world_server_config` / `auth_server_config` | 对应 conf 配置文件路径 |
| `world_server_log` / `auth_server_log` | 对应日志文件路径(用于日志面板轮询) |
| `client_path` | 游戏客户端主程序路径 |
| `active` | 是否为当前激活服务器 |

### external_applications.yaml

| 字段 | 说明 |
| --- | --- |
| `name` | 显示名称 |
| `path` | 程序路径 |
| `description` | 描述 |

> 主题色与深色模式等界面偏好存储于 `shared_preferences`。

## 使用流程

1. 在 **设置 → 服务器** 中添加服务器,选择服务端与客户端目录,程序自动发现各服务路径、conf 与日志(展开「高级配置」可手动修正)
2. 在 **设置 → 外部应用** 中按需添加快捷启动程序
3. 回到启动器页选择目标服务器,点击 **开始** 一键启动(服务会按 mysqld → worldserver / authserver 的顺序拉起,世界服务就绪后自动启动客户端)
4. 通过主按钮旁的菜单可单独「启动所有服务」「关闭所有服务」「启动客户端」

## 常见问题

- **服务启动失败?** 检查 `servers.yaml` 中各路径是否正确,首次启动前请确保数据库已初始化(数据库初始化不属于本启动器职责)。
- **客户端无法登录?** 确认 `realm_list` 与实际登录服务器地址一致,且客户端版本与模拟器版本匹配。
- **日志面板无输出?** 确认 worldserver / authserver 配置了日志文件路径,并在服务器配置中正确填写。

## License

MIT
