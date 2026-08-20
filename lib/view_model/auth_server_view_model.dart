import 'dart:async';
import 'dart:io';

import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:arcane_launcher/util/process_util.dart';
import 'package:signals/signals.dart';

class AuthServerViewModel {
  final _info = signal(ServiceInformation());
  final _config = signal('');
  Timer? _timer;

  ServiceInformation get info => _info.value;
  String get config => _config.value;

  Future<void> init(ServerEntity server) async {
    final info = ServiceInformation();
    final processIds = await ProcessUtil.instance.getProcessIds('authserver.exe');
    if (processIds.isNotEmpty) {
      info.logs = await _getLogs(server);
      info.processIds = processIds;
      info.status = ServiceStatus.running;
    }
    _info.value = info;
  }

  Future<void> fetchConfig(ServerEntity server) async {
    if (server.authServerConfig.isEmpty) {
      _config.value = '';
      return;
    }
    _config.value = await File(server.authServerConfig).readAsString();
  }

  Future<void> storeConfig(ServerEntity server, String config) async {
    if (server.authServerConfig.isEmpty) return;
    await File(server.authServerConfig).writeAsString(config);
  }

  void start(ServerEntity server) async {
    final info = _info.value;
    if (info.status != ServiceStatus.stopped) return;
    if (server.authServerPath.isEmpty) return;
    ProcessUtil.instance.start(server.authServerPath, detached: true);
    _info.value = info.copyWith(status: ServiceStatus.starting);
    _listenLogs(server);
  }

  void stop() async {
    final info = _info.value;
    if (info.status != ServiceStatus.running) return;
    ProcessUtil.instance.stop(info.processIds);
    _info.value = ServiceInformation();
    _timer?.cancel();
  }

  void toggle(ServerEntity server) {
    if (_info.value.status != ServiceStatus.stopped) {
      stop();
    } else {
      start(server);
    }
  }

  Future<List<String>> _getLogs(ServerEntity server) async {
    if (server.authServerLog.isEmpty) return [];
    final file = File(server.authServerLog);
    if (!file.existsSync()) return [];
    return await file.readAsLines();
  }

  void _listenLogs(ServerEntity server) async {
    if (server.authServerLog.isEmpty) return;
    final file = File(server.authServerLog);
    int size = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!file.existsSync()) return;
      final newSize = await file.length();
      if (newSize == size) return;
      size = newSize;
      final lines = await file.readAsLines();
      _info.value = _info.value.copyWith(logs: lines);
      for (var line in lines) {
        if (line.contains('Added realm')) {
          final processIds = await ProcessUtil.instance.getProcessIds(
            'authserver.exe',
          );
          _info.value = _info.value.copyWith(
            processIds: processIds,
            status: ServiceStatus.running,
          );
        }
      }
    });
  }
}
