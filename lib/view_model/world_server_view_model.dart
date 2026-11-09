import 'dart:async';
import 'dart:io';

import 'package:arcane_launcher/model/config_document.dart';
import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:arcane_launcher/util/process_util.dart';
import 'package:arcane_launcher/view_model/config_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals.dart';

class WorldServerViewModel implements ConfigViewModel {
  final _info = signal(ServiceInformation());
  final _process = GetIt.instance.get<ProcessUtil>();
  ConfigDocument? _config;
  Timer? _timer;

  ServiceInformation get info => _info.value;

  @override
  ConfigDocument? get document => _config;

  Future<void> init(ServerEntity server) async {
    final info = ServiceInformation();
    final processIds = await _process.getProcessIds('worldserver.exe');
    if (processIds.isNotEmpty) {
      info.logs = await _getLogs(server);
      info.processIds = processIds;
      info.status = ServiceStatus.running;
    }
    _info.value = info;
  }

  @override
  Future<void> fetchConfig(ServerEntity server) async {
    if (server.worldServerConfig.isEmpty) {
      _config = null;
      return;
    }
    _config = ConfigDocument.parseBytes(
      await File(server.worldServerConfig).readAsBytes(),
    );
  }

  @override
  Future<void> storeConfig(ServerEntity server) async {
    final document = _config;
    if (document == null || server.worldServerConfig.isEmpty) return;
    await File(server.worldServerConfig).writeAsString(document.source);
  }

  void start(ServerEntity server) async {
    final info = _info.value;
    if (info.status != ServiceStatus.stopped) return;
    if (server.worldServerPath.isEmpty) return;
    await _process.startHidden(server.worldServerPath);
    _info.value = info.copyWith(status: ServiceStatus.starting);
    _listenLogs(server);
  }

  void stop() async {
    final info = _info.value;
    if (info.status != ServiceStatus.running) return;
    _process.stop(info.processIds);
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
    if (server.worldServerLog.isEmpty) return [];
    final file = File(server.worldServerLog);
    if (!file.existsSync()) return [];
    return await file.readAsLines();
  }

  void _listenLogs(ServerEntity server) async {
    if (server.worldServerLog.isEmpty) return;
    final file = File(server.worldServerLog);
    int size = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!file.existsSync()) return;
      final newSize = await file.length();
      if (newSize == size) return;
      size = newSize;
      final lines = await file.readAsLines();
      _info.value = _info.value.copyWith(logs: lines);
      for (var line in lines) {
        if (line.contains(' (worldserver-daemon) ready...')) {
          final processIds = await _process.getProcessIds('worldserver.exe');
          _info.value = _info.value.copyWith(
            processIds: processIds,
            status: ServiceStatus.running,
          );
        }
      }
    });
  }
}
