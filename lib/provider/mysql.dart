import 'dart:async';
import 'dart:convert';

import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/provider/server.dart';
import 'package:arcane_launcher/util/process.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mysql.g.dart';

@riverpod
class MysqlInformationNotifier extends _$MysqlInformationNotifier {
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
    if (server.mysqldPath.isEmpty) return;
    final process = await ProcessUtil().start(
      server.mysqldPath,
      arguments: ['--console'],
    );
    var information = await future;
    if (information.active) return;
    state = AsyncData(information.copyWith(active: true));
    process.stdout.transform(utf8.decoder).listen(_listenProcessLogs);
    process.stderr.transform(utf8.decoder).listen(_listenProcessLogs);
    _listenProcessExit();
  }

  void _listenProcessLogs(String log) async {
    var information = await future;
    state = AsyncData(information.copyWith(logs: [...information.logs, log]));
    if (log.contains('ready for connections')) {
      final processIds = await _getProcessIds();
      information = await future;
      state = AsyncData(information.copyWith(processIds: processIds));
    }
  }

  void stop() async {
    var information = await future;
    if (!information.active) return;
    ProcessUtil().stop(information.processIds);
    state = AsyncData(information.copyWith(active: false, processIds: []));
    _cancelListeningProcessExit();
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
    return ProcessUtil().getProcessIds('mysqld.exe');
  }
}
