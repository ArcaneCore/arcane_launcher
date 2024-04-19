import 'dart:async';
import 'dart:convert';

import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/provider/server.dart';
import 'package:arcane_launcher/util/process.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mysqld.g.dart';

@riverpod
class MysqldInformationNotifier extends _$MysqldInformationNotifier {
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
    if (server.mysqldPath.isEmpty) return;
    final process = await ProcessUtil().start(
      server.mysqldPath,
      arguments: ['--console'],
    );
    state = AsyncData(information.copyWith(status: ServiceStatus.running));
    process.stdout.transform(utf8.decoder).listen(_listenProcessLogs);
    process.stderr.transform(utf8.decoder).listen(_listenProcessLogs);
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
    _cancelListeningProcessExit();
  }

  void toggle() async {}

  void _listenProcessLogs(String log) async {
    var information = await future;
    state = AsyncData(information.copyWith(logs: [...information.logs, log]));
    if (log.contains('ready for connections')) {
      final processIds = await _getProcessIds();
      information = await future;
      state = AsyncData(information.copyWith(
        processIds: processIds,
        status: ServiceStatus.running,
      ));
    }
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
    return ProcessUtil().getProcessIds('mysqld.exe');
  }
}
