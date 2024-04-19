import 'dart:async';
import 'dart:io';

import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/provider/server.dart';
import 'package:arcane_launcher/util/process.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_server.g.dart';

@riverpod
class AuthServerInformationNotifier extends _$AuthServerInformationNotifier {
  Timer? _logTimer;
  Timer? _processTimer;

  @override
  Future<ServiceInformation> build() async {
    final information = ServiceInformation();
    final processIds = await _getProcessIds();
    if (processIds.isEmpty) return information;
    information.logs = await _getLogs();
    information.processIds = processIds;
    information.status = ServiceStatus.running;
    return information;
  }

  void start() async {
    final information = await future;
    if (information.status != ServiceStatus.stopped) return;
    final server = await ref.read(activeServerNotifierProvider.future);
    if (server.authServerPath.isEmpty) return;
    ProcessUtil().start(server.authServerPath);
    state = AsyncData(information.copyWith(status: ServiceStatus.starting));
    _listenProcessLogs();
    _listenProcessExit();
  }

  void stop() async {
    var information = await future;
    if (information.status != ServiceStatus.running) return;
    ProcessUtil().stop(information.processIds);
    state = AsyncData(ServiceInformation());
    _cancelListeningProcessLogs();
    _cancelListeningProcessExit();
  }

  void toggle() async {
    var information = await future;
    if (information.status != ServiceStatus.stopped) {
      stop();
    } else {
      start();
    }
  }

  void _listenProcessLogs() async {
    final server = await ref.read(activeServerNotifierProvider.future);
    if (server.authServerLog.isEmpty) return;
    final file = File(server.authServerLog);
    int size = 0;
    _logTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!file.existsSync()) return;
      final newSize = await file.length();
      if (newSize == size) return;
      size = newSize;
      final lines = await file.readAsLines();
      var information = await future;
      state = AsyncData(information.copyWith(logs: lines));
      for (var line in lines) {
        if (line.contains('Added realm')) {
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

  Future<List<String>> _getLogs() async {
    final server = await ref.read(activeServerNotifierProvider.future);
    if (server.authServerLog.isEmpty) return [];
    final file = File(server.authServerLog);
    if (!file.existsSync()) return [];
    final lines = await file.readAsLines();
    return lines;
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
    return ProcessUtil().getProcessIds('authserver.exe');
  }
}

@riverpod
class AuthServerConfigNotifier extends _$AuthServerConfigNotifier {
  @override
  Future<String> build() async {
    final server = await ref.watch(activeServerNotifierProvider.future);
    if (server.authServerConfig.isEmpty) return '';
    return await File(server.authServerConfig).readAsString();
  }

  Future<void> store(String config) async {
    final server = await ref.watch(activeServerNotifierProvider.future);
    if (server.authServerConfig.isEmpty) return;
    final file = File(server.authServerConfig);
    await file.writeAsString(config);
  }
}
