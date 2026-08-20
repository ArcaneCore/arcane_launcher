import 'dart:io';

import 'package:arcane_launcher/schema/server.dart';

/// Result of automatic server configuration discovery.
class ServerDiscoveryResult {
  ServerDiscoveryResult({required this.server, required this.warnings});

  /// Partially filled server config; unmatched fields are empty strings.
  final ServerEntity server;

  /// Hints collected during discovery, e.g. "MySQL not found".
  final List<String> warnings;
}

/// Discovers emulator service paths, configs, and logs by scanning the server
/// and client directories.
///
/// Targets TrinityCore-style directory layouts:
/// - server root with `bin/` (worldserver / authserver and confs) and
///   `mysql/bin/mysqld`
/// - conf uses `Key = "Value"` lines, with `#`-prefixed comments
class ServerDiscovery {
  ServerDiscovery._();

  static final ServerDiscovery instance = ServerDiscovery._();

  Future<ServerDiscoveryResult> discover({
    required String serverDir,
    required String clientDir,
  }) async {
    final warnings = <String>[];
    final server = ServerEntity();
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
          warnings.add(
            'MySQL (mysqld) not found; specify it in Advanced settings',
          );
        }
        if (server.worldServerPath.isEmpty) {
          warnings.add(
            'World Server (worldserver) not found; specify it in Advanced settings',
          );
        }
        if (server.authServerPath.isEmpty) {
          warnings.add(
            'Auth Server (authserver) not found; specify it in Advanced settings',
          );
        }
      } else {
        warnings.add('Server directory does not exist: $serverDir');
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
            (a, b) => _clientCandidates
                .indexOf(_basename(a.path).toLowerCase())
                .compareTo(
                  _clientCandidates.indexOf(_basename(b.path).toLowerCase()),
                ),
          );
          server.clientPath = matches.first.path;
        } else {
          warnings.add(
            'Client executable (Wow.exe) not found; specify it in Advanced settings',
          );
        }
      } else {
        warnings.add('Client directory does not exist: $clientDir');
      }
    }

    return ServerDiscoveryResult(server: server, warnings: warnings);
  }

  /// Common WoW client executables, ordered by priority.
  static const _clientCandidates = [
    'wow.exe',
    'wow-64.exe',
    'wowclassic.exe',
    'wowclassic_retail.exe',
    'wow_beta.exe',
  ];

  /// Matches server executables / configs by lowercase file name, handling both
  /// `.exe` and extensionless Linux builds.
  static void _matchServerFile(File file, Map<String, File> found) {
    final name = _basename(file.path).toLowerCase();
    if (name == 'mysqld.exe' || name == 'mysqld') {
      found.putIfAbsent('mysqld', () => file);
    } else if (name == 'worldserver.exe' || name == 'worldserver') {
      found.putIfAbsent('worldserver', () => file);
    } else if (name == 'authserver.exe' || name == 'authserver') {
      found.putIfAbsent('authserver', () => file);
    } else if (name == 'worldserver.conf' || name == 'worldserver.conf.dist') {
      // Prefer the real conf over the .dist template.
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

  /// Recursively scans a directory up to [maxDepth], skipping inaccessible
  /// entries.
  static Future<void> _scan(
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
      // Ignore scan errors such as permission issues.
    }
  }

  /// Parses an emulator conf (`Key = "Value"` lines) into a key-value map.
  static Map<String, String> _parseConf(File confFile) {
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

  /// Derives the full log path from conf: conf dir + LogFileDir/LogsDir + LogFile.
  static String _resolveLogPath(
    File confFile,
    Map<String, String> conf,
    String defaultName,
  ) {
    final logDir = (conf['LogFileDir'] ?? conf['LogsDir'] ?? '').trim();
    final logName = (conf['LogFile'] ?? '').trim();
    if (logName.isEmpty) return '';
    final sep = Platform.pathSeparator;
    final base = confFile.parent.path;
    if (logDir.isEmpty || logDir == '.') return '$base$sep$logName';
    final dir = File(logDir).isAbsolute ? logDir : '$base$sep$logDir';
    return '$dir$sep$logName';
  }

  /// Returns the last path segment, accepting both `\` and `/` separators.
  static String _basename(String path) {
    final parts = path.split(RegExp(r'[\\/]'));
    return parts.where((p) => p.isNotEmpty).lastOrNull ?? '';
  }
}
