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
    information.active = true;
    information.processIds = processIds;
    return information;
  }

  void start() async {
    final server = await ref.read(activeServerNotifierProvider.future);
    if (server.worldServerPath.isEmpty) return;
    await ProcessUtil().start(server.worldServerPath);
    var information = await future;
    if (information.active) return;
    state = AsyncData(information.copyWith(active: true));
    _listenProcessLogs();
    _listenProcessExit();
  }

  void stop() async {
    final information = await future;
    if (!information.active) return;
    ProcessUtil().stop(information.processIds);
    state = AsyncData(information.copyWith(active: false, processIds: []));
    _cancelListeningProcessLogs();
    _cancelListeningProcessExit();
  }

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
          state = AsyncData(information.copyWith(processIds: processIds));
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
      if (!information.active) return;
      final processIds = await _getProcessIds();
      if (processIds.isNotEmpty) return;
      information = await future;
      state = AsyncData(information.copyWith(active: false, processIds: []));
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
