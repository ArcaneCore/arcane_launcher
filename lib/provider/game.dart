import 'dart:async';
import 'dart:io';

import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/provider/auth_server.dart';
import 'package:arcane_launcher/provider/mysqld.dart';
import 'package:arcane_launcher/provider/server.dart';
import 'package:arcane_launcher/provider/world_server.dart';
import 'package:arcane_launcher/util/process.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game.g.dart';

@riverpod
class GameNotifier extends _$GameNotifier {
  Timer? _timer;
  @override
  Future<bool> build() async {
    _timer = Timer.periodic(const Duration(seconds: 15), (_) async {
      final processes = await ProcessUtil().getProcessNames();
      if (!processes.contains('mysqld.exe')) {
        final mysqldInformationNotifier =
            ref.read(mysqldInformationNotifierProvider.notifier);
        mysqldInformationNotifier.stop();
      }
      if (!processes.contains('worldserver.exe')) {
        final worldServerInformationNotifier =
            ref.read(worldServerInformationNotifierProvider.notifier);
        worldServerInformationNotifier.stop();
      }
      if (!processes.contains('authserver.exe')) {
        final authServerInformationNotifier =
            ref.read(authServerInformationNotifierProvider.notifier);
        authServerInformationNotifier.stop();
      }
    });
    ref.onDispose(() {
      _timer?.cancel();
    });
    return false;
  }

  void start() async {
    startServices();
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final worldServerInformation =
          await ref.read(worldServerInformationNotifierProvider.future);
      if (worldServerInformation.status == ServiceStatus.running) {
        startClient();
        timer.cancel();
      }
    });
  }

  void startClient() async {
    final server = await ref.read(activeServerNotifierProvider.future);
    if (server.clientPath.isEmpty) return;
    final patterns = server.clientPath.split(r'\');
    final prefix = patterns.take(patterns.length - 1);
    final cachePatterns = [...prefix, 'Cache'];
    final directory = Directory(cachePatterns.join(r'\'));
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    final realmListPatterns = [...prefix, 'realmlist.wtf'];
    final file = File(realmListPatterns.join(r'\'));
    if (!await file.exists()) {
      await file.create();
    }
    final realmList = server.realmList;
    file.writeAsString('SET realmlist "$realmList"');
    ProcessUtil().start(server.clientPath);
  }

  void startServices() async {
    List<String> tasks = await _createTasks();
    if (tasks.isEmpty) return;
    state = const AsyncData(true);
    if (tasks.contains('mysqld')) {
      final mysqldNotifier =
          ref.read(mysqldInformationNotifierProvider.notifier);
      mysqldNotifier.start();
      tasks.remove('mysqld');
    }
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final mysqldInformation =
          await ref.read(mysqldInformationNotifierProvider.future);
      if (mysqldInformation.status != ServiceStatus.running) return;
      if (tasks.contains('worldserver')) {
        final worldServerNotifier =
            ref.read(worldServerInformationNotifierProvider.notifier);
        worldServerNotifier.start();
        tasks.remove('worldserver');
      }
      if (tasks.contains('authserver')) {
        final authServerNotifier =
            ref.read(authServerInformationNotifierProvider.notifier);
        authServerNotifier.start();
        tasks.remove('authserver');
      }
      if (tasks.isEmpty) {
        timer.cancel();
        state = const AsyncData(false);
      }
    });
  }

  void stopServices() async {
    final worldServerNotifier =
        ref.read(worldServerInformationNotifierProvider.notifier);
    worldServerNotifier.stop();
    final authServerNotifier =
        ref.read(authServerInformationNotifierProvider.notifier);
    authServerNotifier.stop();
    final mysqldNotifier = ref.read(mysqldInformationNotifierProvider.notifier);
    mysqldNotifier.stop();
  }

  Future<List<String>> _createTasks() async {
    List<String> tasks = [];
    final server = await ref.read(activeServerNotifierProvider.future);
    if (server.mysqldPath.isEmpty) return tasks;
    var mysqldInformation =
        await ref.read(mysqldInformationNotifierProvider.future);
    if (mysqldInformation.status == ServiceStatus.stopped) {
      tasks.add('mysqld');
    }
    if (server.worldServerPath.isEmpty) return tasks;
    var worldServerInformation =
        await ref.read(worldServerInformationNotifierProvider.future);
    if (worldServerInformation.status == ServiceStatus.stopped) {
      tasks.add('worldserver');
    }
    if (server.authServerPath.isEmpty) return tasks;
    var authServerInformation =
        await ref.read(authServerInformationNotifierProvider.future);
    if (authServerInformation.status == ServiceStatus.stopped) {
      tasks.add('authserver');
    }
    return tasks;
  }
}
