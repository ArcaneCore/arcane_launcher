import 'dart:async';
import 'dart:io';

import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/provider/server.dart';
import 'package:arcane_launcher/util/process.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_server.g.dart';

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

@riverpod
class AuthServerInformationNotifier extends _$AuthServerInformationNotifier {
  Timer? _timer;

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
  }

  void stop() async {
    var information = await future;
    if (information.status != ServiceStatus.running) return;
    ProcessUtil().stop(information.processIds);
    state = AsyncData(ServiceInformation());
    _cancelListeningProcessLogs();
  }

  void toggle() async {
    var information = await future;
    if (information.status != ServiceStatus.stopped) {
      stop();
    } else {
      start();
    }
  }

  void _cancelListeningProcessLogs() {
    _timer?.cancel();
  }

  Future<List<String>> _getLogs() async {
    final server = await ref.read(activeServerNotifierProvider.future);
    if (server.authServerLog.isEmpty) return [];
    final file = File(server.authServerLog);
    if (!file.existsSync()) return [];
    final lines = await file.readAsLines();
    return lines;
  }

  Future<List<int>> _getProcessIds() async {
    return ProcessUtil().getProcessIds('authserver.exe');
  }

  void _listenProcessLogs() async {
    final server = await ref.read(activeServerNotifierProvider.future);
    if (server.authServerLog.isEmpty) return;
    final file = File(server.authServerLog);
    int size = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
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
}
