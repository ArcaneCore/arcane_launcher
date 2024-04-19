import 'dart:async';

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
  @override
  Future<bool> build() async {
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

  void startClient() async {
    final server = await ref.read(activeServerNotifierProvider.future);
    if (server.clientPath.isEmpty) return;
    ProcessUtil().start(server.clientPath);
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
