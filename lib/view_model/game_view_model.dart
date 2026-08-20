import 'dart:async';
import 'dart:io';

import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:arcane_launcher/util/process.dart';
import 'package:arcane_launcher/view_model/auth_server_view_model.dart';
import 'package:arcane_launcher/view_model/mysqld_view_model.dart';
import 'package:arcane_launcher/view_model/server_view_model.dart';
import 'package:arcane_launcher/view_model/world_server_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals.dart';

class GameViewModel {
  final _loading = signal(false);
  Timer? _watchTimer;

  bool get loading => _loading.value;

  void init() {
    _watchTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      final processes = await ProcessUtil().getProcessNames();
      final getIt = GetIt.instance;
      if (!processes.contains('mysqld.exe')) {
        getIt<MysqldViewModel>().stop();
      }
      if (!processes.contains('worldserver.exe')) {
        getIt<WorldServerViewModel>().stop();
      }
      if (!processes.contains('authserver.exe')) {
        getIt<AuthServerViewModel>().stop();
      }
    });
  }

  void dispose() {
    _watchTimer?.cancel();
  }

  void startGame() {
    _startServices();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final getIt = GetIt.instance;
      if (getIt<WorldServerViewModel>().info.status == ServiceStatus.running) {
        _startClient(getIt<ServerViewModel>().activeServer);
        timer.cancel();
      }
    });
  }

  void startClient() {
    _startClient(GetIt.instance<ServerViewModel>().activeServer);
  }

  void _startClient(ServerEntity server) {
    if (server.clientPath.isEmpty) return;
    final patterns = server.clientPath.split(r'\');
    final prefix = patterns.take(patterns.length - 1);
    final cachePatterns = [...prefix, 'Cache'];
    final directory = Directory(cachePatterns.join(r'\'));
    directory.exists().then((exists) {
      if (exists) directory.delete(recursive: true);
    });
    final realmListPatterns = [...prefix, 'realmlist.wtf'];
    final file = File(realmListPatterns.join(r'\'));
    file.exists().then((exists) {
      if (!exists) file.create();
    });
    file.writeAsString('SET realmlist "${server.realmList}"');
    ProcessUtil().start(server.clientPath);
  }

  void startServices() {
    _startServices();
  }

  void _startServices() {
    final getIt = GetIt.instance;
    final server = getIt<ServerViewModel>().activeServer;
    final tasks = _createTasks(server);
    if (tasks.isEmpty) return;
    _loading.value = true;
    if (tasks.contains('mysqld')) {
      getIt<MysqldViewModel>().start(server);
      tasks.remove('mysqld');
    }
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final getIt = GetIt.instance;
      if (getIt<MysqldViewModel>().info.status != ServiceStatus.running) return;
      if (tasks.contains('worldserver')) {
        getIt<WorldServerViewModel>().start(server);
        tasks.remove('worldserver');
      }
      if (tasks.contains('authserver')) {
        getIt<AuthServerViewModel>().start(server);
        tasks.remove('authserver');
      }
      if (tasks.isEmpty) {
        timer.cancel();
        _loading.value = false;
      }
    });
  }

  void stopServices() {
    final getIt = GetIt.instance;
    getIt<WorldServerViewModel>().stop();
    getIt<AuthServerViewModel>().stop();
    getIt<MysqldViewModel>().stop();
  }

  List<String> _createTasks(ServerEntity server) {
    final getIt = GetIt.instance;
    final tasks = <String>[];
    if (server.mysqldPath.isEmpty) return tasks;
    if (getIt<MysqldViewModel>().info.status == ServiceStatus.stopped) {
      tasks.add('mysqld');
    }
    if (server.worldServerPath.isEmpty) return tasks;
    if (getIt<WorldServerViewModel>().info.status == ServiceStatus.stopped) {
      tasks.add('worldserver');
    }
    if (server.authServerPath.isEmpty) return tasks;
    if (getIt<AuthServerViewModel>().info.status == ServiceStatus.stopped) {
      tasks.add('authserver');
    }
    return tasks;
  }
}
