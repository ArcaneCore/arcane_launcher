# Arcane Launcher

A Flutter-based desktop launcher for World of Warcraft emulators, built to manage TrinityCore-style servers and launch the game client with one click. Supports **Windows / macOS / Linux**.

![Flutter](https://img.shields.io/badge/Flutter-3.29+-02569B?logo=flutter) ![Dart](https://img.shields.io/badge/Dart-3.7+-0175C2?logo=dart) ![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **One-click play** — starts services in dependency order (`mysqld` → `worldserver` / `authserver`) and launches the client once the world server is ready
- **Automatic client setup** — cleans the client `Cache` directory and writes the login address into `realmlist.wtf` before launch
- **Service management** — start / stop / toggle MySQL, world server, and auth server with live status in the sidebar
- **Real-time logs** — three log panels showing mysqld / worldserver / authserver output
- **Process watchdog** — polls processes every 15 seconds and syncs service status when a process exits unexpectedly
- **Auto-discovered config** — pick the server and client directories and the launcher scans the emulator root and parses conf files to fill in mysqld / worldserver / authserver paths, configs, and logs; anything not found can be set manually in the Advanced section
- **Multiple servers** — maintain any number of server profiles (paths, version, realm list, etc.) and switch between them from a dropdown
- **In-app conf editing** — read and edit `worldserver.conf` / `authserver.conf` directly
- **External apps** — add shortcuts to frequently used programs and launch them with one click
- **Theming** — custom accent color and dark / light mode

## Screens

- **Launcher** — service status, live logs, server switcher, one-click start / stop and client launch
- **Emulator Config** — edit the active server's worldserver / authserver config files
- **Settings** — server management, external apps, theme

## Tech Stack

| Category | Technology |
| --- | --- |
| UI framework | Flutter (Material 3) |
| State management | [signals](https://pub.dev/packages/signals) |
| Dependency injection | [get_it](https://pub.dev/packages/get_it) |
| Config storage | [yaml](https://pub.dev/packages/yaml) / [yaml_writer](https://pub.dev/packages/yaml_writer) + [shared_preferences](https://pub.dev/packages/shared_preferences) |
| Window management | [window_manager](https://pub.dev/packages/window_manager) |
| File picking | [file_picker](https://pub.dev/packages/file_picker) |
| Icons | [lucide_icons_flutter](https://pub.dev/packages/lucide_icons_flutter) |

## Architecture

MVVM, with pages decoupled from state:

```
lib/
├── main.dart                  # Entry: window init, DI setup, data preloading
├── di.dart                    # get_it registration
├── page/                      # Pages
│   ├── launcher/              # Launcher home (service status + logs + one-click play)
│   ├── config/                # Emulator config (worldserver / authserver conf editing)
│   └── setting/               # Settings (servers, external apps, theme)
├── view_model/                # ViewModels (signals-based reactive state)
│   ├── server_view_model.dart
│   ├── game_view_model.dart   # Start orchestration and process watchdog
│   ├── mysqld_view_model.dart
│   ├── world_server_view_model.dart
│   ├── auth_server_view_model.dart
│   └── ...
├── schema/                    # Data models (Server / Setting / ExternalApplication)
├── model/                     # Service information model (ServiceInformation)
├── util/                      # Process utils, YAML store, discovery, preferences
├── widget/                    # Shared widgets (buttons, cards, log views, forms, etc.)
└── theme/                     # Theme and design tokens
```

## Requirements

- Flutter SDK (Dart SDK **^3.7.2**, see `pubspec.yaml`)
- Desktop toolchains: Windows (VS 2022 + C++), macOS (Xcode), Linux (CMake + GTK)

## Quick Start

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run (pick a platform)
flutter run -d windows
flutter run -d macos
flutter run -d linux

# 3. Build a release
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

## Config Files

The app reads and writes the following YAML files in the **working directory** (written atomically via temp file + rename to survive crashes):

### servers.yaml

| Field | Description |
| --- | --- |
| `name` / `description` / `version` | Server name, description, version |
| `local` | Whether this is a local server |
| `realm_list` | Login address written to the client's `realmlist.wtf` |
| `mysqld_path` | Path to the mysqld executable |
| `world_server_path` / `auth_server_path` | World / auth server executables |
| `world_server_config` / `auth_server_config` | Corresponding conf file paths |
| `world_server_log` / `auth_server_log` | Log file paths (polled by the log panels) |
| `client_path` | Game client executable |
| `active` | Whether this is the active server |

### external_applications.yaml

| Field | Description |
| --- | --- |
| `name` | Display name |
| `path` | Program path |
| `description` | Description |

> Theme color and dark mode are stored in `shared_preferences`.

## Usage

1. In **Settings → Servers**, add a server and pick the server and client directories — the launcher auto-discovers service paths, confs, and logs (expand **Advanced** to fix anything manually)
2. Add external app shortcuts in **Settings → External Apps** if needed
3. Back on the launcher, select a server and press **Play** — services start in order (mysqld → worldserver / authserver) and the client launches once the world server is ready
4. The menu next to the play button offers **Start All Services**, **Stop All Services**, and **Launch Client** individually

## Troubleshooting

- **Service fails to start?** Check the paths in `servers.yaml`. The database must be initialized before first use (initialization is outside this launcher's scope).
- **Cannot log in?** Make sure `realm_list` matches the auth server address and the client version matches the emulator.
- **Log panels empty?** Ensure the world/auth servers are configured with log file paths and the paths are set on the server profile.

## License

MIT
