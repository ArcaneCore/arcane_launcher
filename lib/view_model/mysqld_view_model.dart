import 'dart:async';
import 'dart:convert';

import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:arcane_launcher/util/process_util.dart';
import 'package:signals/signals.dart';

class MysqldViewModel {
  final _info = signal(ServiceInformation());

  ServiceInformation get info => _info.value;

  Future<void> init() async {
    final info = ServiceInformation();
    final processIds = await ProcessUtil().getProcessIds('mysqld.exe');
    if (processIds.isNotEmpty) {
      info.logs = ['Mysqld is running...'];
      info.processIds = processIds;
      info.status = ServiceStatus.running;
    }
    _info.value = info;
  }

  void start(ServerEntity server) async {
    final info = _info.value;
    if (info.status != ServiceStatus.stopped) return;
    if (server.mysqldPath.isEmpty) return;
    final process = await ProcessUtil().start(server.mysqldPath,
        arguments: ['--console']);
    _info.value = info.copyWith(status: ServiceStatus.starting);
    process.stdout.transform(utf8.decoder).listen(_listenLogs);
    process.stderr.transform(utf8.decoder).listen(_listenLogs);
  }

  void stop() async {
    final info = _info.value;
    if (info.status != ServiceStatus.running) return;
    ProcessUtil().stop(info.processIds);
    _info.value = ServiceInformation();
  }

  void toggle(ServerEntity server) {
    if (_info.value.status != ServiceStatus.stopped) {
      stop();
    } else {
      start(server);
    }
  }

  void _listenLogs(String log) async {
    final info = _info.value;
    _info.value = info.copyWith(logs: [...info.logs, log]);
    if (log.contains('ready for connections')) {
      final processIds = await ProcessUtil().getProcessIds('mysqld.exe');
      _info.value = _info.value
          .copyWith(processIds: processIds, status: ServiceStatus.running);
    }
  }
}
