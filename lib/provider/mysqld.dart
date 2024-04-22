import 'dart:async';
import 'dart:convert';

import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/provider/server.dart';
import 'package:arcane_launcher/util/process.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mysqld.g.dart';

@riverpod
class MysqldInformationNotifier extends _$MysqldInformationNotifier {
  @override
  Future<ServiceInformation> build() async {
    final information = ServiceInformation();
    final processIds = await _getProcessIds();
    if (processIds.isEmpty) return information;
    information.logs = ['Mysqld is running...'];
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
    state = AsyncData(information.copyWith(status: ServiceStatus.starting));
    process.stdout.transform(utf8.decoder).listen(_listenProcessLogs);
    process.stderr.transform(utf8.decoder).listen(_listenProcessLogs);
  }

  void stop() async {
    var information = await future;
    if (information.status != ServiceStatus.running) return;
    ProcessUtil().stop(information.processIds);
    state = AsyncData(ServiceInformation());
  }

  void toggle() async {
    var information = await future;
    if (information.status != ServiceStatus.stopped) {
      stop();
    } else {
      start();
    }
  }

  Future<List<int>> _getProcessIds() async {
    return ProcessUtil().getProcessIds('mysqld.exe');
  }

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
}
