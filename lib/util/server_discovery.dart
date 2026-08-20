import 'dart:io';

import 'package:arcane_launcher/schema/server.dart';

/// 服务器配置自动发现结果。
class ServerDiscoveryResult {
  ServerDiscoveryResult({required this.server, required this.warnings});

  /// 部分填充的服务器配置,未命中的字段为空字符串。
  final Server server;

  /// 发现过程中的提示,如「未找到 MySQL」。
  final List<String> warnings;
}

/// 通过扫描服务端 / 客户端目录,自动发现模拟器各服务路径、配置与日志。
///
/// 针对 TrinityCore 系目录结构:
/// - 服务端根目录下 `bin/`(worldserver / authserver 及 conf)、`mysql/bin/mysqld`
/// - conf 为 `Key = "Value"` 格式,`#` 开头为注释
Future<ServerDiscoveryResult> discoverServer({
  required String serverDir,
  required String clientDir,
}) async {
  final warnings = <String>[];
  final server = Server();
  server.name = _basename(serverDir);

  if (serverDir.isNotEmpty) {
    final root = Directory(serverDir);
    if (root.existsSync()) {
      final found = <String, File>{};
      await _scan(root, 4, (file) => _matchServerFile(file, found));

      server.mysqldPath = found['mysqld']?.path ?? '';
      server.worldServerPath = found['worldserver']?.path ?? '';
      server.authServerPath = found['authserver']?.path ?? '';
      server.worldServerConfig = found['worldserver_conf']?.path ?? '';
      server.authServerConfig = found['authserver_conf']?.path ?? '';

      if (found['worldserver_conf'] != null) {
        server.worldServerLog = _resolveLogPath(
          found['worldserver_conf']!,
          _parseConf(found['worldserver_conf']!),
          'Server.log',
        );
      }
      if (found['authserver_conf'] != null) {
        final authConf = _parseConf(found['authserver_conf']!);
        server.authServerLog = _resolveLogPath(
          found['authserver_conf']!,
          authConf,
          'Auth.log',
        );
        final bind = authConf['BindIP']?.trim() ?? '';
        if (bind.isNotEmpty && bind != '0.0.0.0') {
          server.realmList = bind;
        }
      }

      if (server.mysqldPath.isEmpty) {
        warnings.add('未找到 MySQL(mysqld),可在高级配置中手动指定');
      }
      if (server.worldServerPath.isEmpty) {
        warnings.add('未找到 World Server(worldserver),可在高级配置中手动指定');
      }
      if (server.authServerPath.isEmpty) {
        warnings.add('未找到 Auth Server(authserver),可在高级配置中手动指定');
      }
    } else {
      warnings.add('服务端目录不存在:$serverDir');
    }
  }

  if (clientDir.isNotEmpty) {
    final root = Directory(clientDir);
    if (root.existsSync()) {
      final matches = <File>[];
      await _scan(root, 2, (file) {
        if (_clientCandidates.contains(_basename(file.path).toLowerCase())) {
          matches.add(file);
        }
      });
      if (matches.isNotEmpty) {
        matches.sort(
          (a, b) =>
              _clientCandidates
                  .indexOf(_basename(a.path).toLowerCase())
                  .compareTo(
                    _clientCandidates.indexOf(_basename(b.path).toLowerCase()),
                  ),
        );
        server.clientPath = matches.first.path;
      } else {
        warnings.add('未找到客户端主程序(Wow.exe),可在高级配置中手动指定');
      }
    } else {
      warnings.add('客户端目录不存在:$clientDir');
    }
  }

  return ServerDiscoveryResult(server: server, warnings: warnings);
}

/// 常见魔兽客户端主程序名,按优先级排列。
const _clientCandidates = [
  'wow.exe',
  'wow-64.exe',
  'wowclassic.exe',
  'wowclassic_retail.exe',
  'wow_beta.exe',
];

/// 服务端可执行文件 / 配置文件,按文件名小写匹配,兼容 `.exe` 与无扩展名的 Linux 版。
void _matchServerFile(File file, Map<String, File> found) {
  final name = _basename(file.path).toLowerCase();
  if (name == 'mysqld.exe' || name == 'mysqld') {
    found.putIfAbsent('mysqld', () => file);
  } else if (name == 'worldserver.exe' || name == 'worldserver') {
    found.putIfAbsent('worldserver', () => file);
  } else if (name == 'authserver.exe' || name == 'authserver') {
    found.putIfAbsent('authserver', () => file);
  } else if (name == 'worldserver.conf' || name == 'worldserver.conf.dist') {
    // 真实 conf 优先于 .dist 模板
    final current = found['worldserver_conf'];
    if (current == null || current.path.endsWith('.dist')) {
      found['worldserver_conf'] = file;
    }
  } else if (name == 'authserver.conf' || name == 'authserver.conf.dist') {
    final current = found['authserver_conf'];
    if (current == null || current.path.endsWith('.dist')) {
      found['authserver_conf'] = file;
    }
  }
}

/// 有限深度递归扫描目录,越界或无权访问的目录直接跳过。
Future<void> _scan(
  Directory dir,
  int maxDepth,
  void Function(File file) onFile,
) async {
  if (maxDepth <= 0) return;
  try {
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is Directory) {
        await _scan(entity, maxDepth - 1, onFile);
      } else if (entity is File) {
        onFile(entity);
      }
    }
  } catch (_) {
    // 忽略无权限等扫描异常
  }
}

/// 解析 `Key = "Value"` 格式的模拟器 conf,返回键值映射。
Map<String, String> _parseConf(File confFile) {
  final result = <String, String>{};
  String? content;
  try {
    content = confFile.readAsStringSync();
  } catch (_) {
    return result;
  }
  for (final rawLine in content.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final eq = line.indexOf('=');
    if (eq <= 0) continue;
    final key = line.substring(0, eq).trim();
    var value = line.substring(eq + 1).trim();
    if (value.startsWith('"')) {
      final close = value.indexOf('"', 1);
      if (close > 0) value = value.substring(1, close);
    }
    result[key] = value;
  }
  return result;
}

/// 由 conf 推导日志文件完整路径:conf 所在目录 + LogFileDir/LogsDir + LogFile。
String _resolveLogPath(File confFile, Map<String, String> conf, String defaultName) {
  final logDir = (conf['LogFileDir'] ?? conf['LogsDir'] ?? '').trim();
  final logName = (conf['LogFile'] ?? '').trim();
  if (logName.isEmpty) return '';
  final sep = Platform.pathSeparator;
  final base = confFile.parent.path;
  if (logDir.isEmpty || logDir == '.') return '$base$sep$logName';
  final dir = File(logDir).isAbsolute
      ? logDir
      : '$base$sep$logDir';
  return '$dir$sep$logName';
}

/// 取路径最后一段,兼容 `\` 与 `/` 分隔符。
String _basename(String path) {
  final parts = path.split(RegExp(r'[\\/]'));
  return parts.where((p) => p.isNotEmpty).lastOrNull ?? '';
}
