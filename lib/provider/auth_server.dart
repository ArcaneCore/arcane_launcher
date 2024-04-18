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
    information.active = true;
    information.processIds = processIds;
    return information;
  }

  void start() async {
    final server = await ref.read(activeServerNotifierProvider.future);
    if (server.authServerPath.isEmpty) return;
    ProcessUtil().start(server.authServerPath);
    _listenProcessLogs();
    _listenProcessExit();
    var information = await future;
    if (information.active) return;
    state = AsyncData(information.copyWith(active: true));
  }

  void stop() async {
    var information = await future;
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
    if (server.authServerLog.isEmpty) return;
    final file = File(server.authServerLog);
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
        if (line.contains('Added realm')) {
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
