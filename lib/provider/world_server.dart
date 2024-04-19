import 'dart:async';
import 'dart:io';

import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/provider/server.dart';
import 'package:arcane_launcher/util/process.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'world_server.g.dart';

@riverpod
class WorldServerInformationNotifier extends _$WorldServerInformationNotifier {
  Timer? _logTimer;
  Timer? _processTimer;

  @override
  Future<ServiceInformation> build() async {
    final information = ServiceInformation();
    final processIds = await _getProcessIds();
    if (processIds.isEmpty) return information;
    information.processIds = processIds;
    information.status = ServiceStatus.running;
    return information;
  }

  void start() async {
    final information = await future;
    if (information.status != ServiceStatus.stopped) return;
    final server = await ref.read(activeServerNotifierProvider.future);
    if (server.worldServerPath.isEmpty) return;
    await ProcessUtil().start(server.worldServerPath);
    state = AsyncData(information.copyWith(status: ServiceStatus.running));
    _listenProcessLogs();
    _listenProcessExit();
  }

  void stop() async {
    var information = await future;
    if (information.status != ServiceStatus.running) return;
    ProcessUtil().stop(information.processIds);
    state = AsyncData(information.copyWith(
      processIds: [],
      status: ServiceStatus.stopped,
    ));
    _cancelListeningProcessLogs();
    _cancelListeningProcessExit();
  }

  void toggle() async {}

  void _listenProcessLogs() async {
    var information = await future;
    state = AsyncData(information.copyWith(logs: []));
    final server = await ref.read(activeServerNotifierProvider.future);
    if (server.worldServerLog.isEmpty) return;
    final file = File(server.worldServerLog);
    DateTime modified = await file.lastModified();
    _logTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!file.existsSync()) return;
      final lastModified = await file.lastModified();
      if (lastModified.compareTo(modified) == 0) return;
      modified = lastModified;
      final lines = await file.readAsLines();
      information = await future;
      state = AsyncData(information.copyWith(logs: lines));
      for (var line in lines) {
        if (line.contains(' (worldserver-daemon) ready...')) {
          final processIds = await _getProcessIds();
          information = await future;
          state = AsyncData(information.copyWith(
            processIds: processIds,
            status: ServiceStatus.running,
          ));
        }
      }
    });
  }

  void _cancelListeningProcessLogs() {
    _logTimer?.cancel();
  }

  void _listenProcessExit() async {
    _processTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      var information = await future;
      if (information.status != ServiceStatus.running) return;
      final processIds = await _getProcessIds();
      if (processIds.isNotEmpty) return;
      information = await future;
      state = AsyncData(information.copyWith(
        processIds: [],
        status: ServiceStatus.stopped,
      ));
      _cancelListeningProcessExit();
    });
  }

  void _cancelListeningProcessExit() {
    _processTimer?.cancel();
  }

  Future<List<int>> _getProcessIds() async {
    return ProcessUtil().getProcessIds('worldserver.exe');
  }
}

@riverpod
class WorldServerConfigNotifier extends _$WorldServerConfigNotifier {
  @override
  Future<String> build() async {
    final server = await ref.watch(activeServerNotifierProvider.future);
    if (server.worldServerConfig.isEmpty) return '';
    return await File(server.worldServerConfig).readAsString();
  }

  Future<void> store(String config) async {
    final server = await ref.watch(activeServerNotifierProvider.future);
    if (server.worldServerConfig.isEmpty) return;
    final file = File(server.worldServerConfig);
    await file.writeAsString(config);
  }
}
