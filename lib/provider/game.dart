import 'dart:async';

import 'package:arcane_launcher/provider/auth_server.dart';
import 'package:arcane_launcher/provider/mysql.dart';
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

  /// Starts the game by initializing the MySQL database and launching the necessary
  /// servers.
  ///
  /// This function starts the MySQL database by calling the `start` method on the
  /// `mysqlNotifier`. It then sets up a timer to periodically check the status of
  /// the MySQL database and the servers. If the MySQL database is not yet started,
  /// it waits for it to finish starting. If the auth server is not yet started, it
  /// starts it by calling the `start` method on the `authServerNotifier`. If the
  /// world server is not yet started, it starts it by calling the `start` method
  /// on the `worldServerNotifier`. Once the world server is started, it cancels
  /// the timer and starts the client by calling the `start` method on `ProcessUtil`.
  /// Only can attempt to start the client up to 5 times.
  ///
  /// This function does not return anything.
  void start() async {
    state = const AsyncData(true);
    // 如果mysql没有启动，启动mysql
    var mysqlInformation =
        await ref.read(mysqlInformationNotifierProvider.future);
    if (!mysqlInformation.active) {
      final mysqlNotifier = ref.read(mysqlInformationNotifierProvider.notifier);
      mysqlNotifier.start();
    }
    const maxAttempt = 5;
    var attempt = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      // 等待mysql启动完毕
      mysqlInformation =
          await ref.read(mysqlInformationNotifierProvider.future);
      if (mysqlInformation.processIds.isEmpty) return;
      // 如果authserver没有启动，启动authserver
      final authServerInformation =
          await ref.read(authServerInformationNotifierProvider.future);
      if (!authServerInformation.active) {
        final authServerNotifier =
            ref.read(authServerInformationNotifierProvider.notifier);
        authServerNotifier.start();
        attempt++;
      }
      // 如果worldserver没有启动，启动worldserver
      final worldServerInformation =
          await ref.read(worldServerInformationNotifierProvider.future);
      if (!worldServerInformation.active) {
        final worldServerNotifier =
            ref.read(worldServerInformationNotifierProvider.notifier);
        worldServerNotifier.start();
        attempt++;
      }
      // 等待worldserver启动完毕，关闭定时器，启动client
      if (worldServerInformation.processIds.isNotEmpty) {
        timer.cancel();
        startClient();
        state = const AsyncData(false);
      }
      // 如果超过5次没有启动，退出
      if (attempt >= maxAttempt) {
        timer.cancel();
        state = const AsyncData(false);
      }
    });
  }

  void startServices() async {
    state = const AsyncData(true);
    // 如果mysql没有启动，启动mysql
    var mysqlInformation =
        await ref.read(mysqlInformationNotifierProvider.future);
    if (!mysqlInformation.active) {
      final mysqlNotifier = ref.read(mysqlInformationNotifierProvider.notifier);
      mysqlNotifier.start();
    }
    const maxAttempt = 5;
    var attempt = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      // 等待mysql启动完毕
      mysqlInformation =
          await ref.read(mysqlInformationNotifierProvider.future);
      if (mysqlInformation.processIds.isEmpty) return;
      // 如果authserver没有启动，启动authserver
      final authServerInformation =
          await ref.read(authServerInformationNotifierProvider.future);
      if (!authServerInformation.active) {
        final authServerNotifier =
            ref.read(authServerInformationNotifierProvider.notifier);
        authServerNotifier.start();
        attempt++;
      }
      // 如果worldserver没有启动，启动worldserver
      final worldServerInformation =
          await ref.read(worldServerInformationNotifierProvider.future);
      if (!worldServerInformation.active) {
        final worldServerNotifier =
            ref.read(worldServerInformationNotifierProvider.notifier);
        worldServerNotifier.start();
        attempt++;
      }
      // 等待worldserver启动完毕，关闭定时器
      if (worldServerInformation.processIds.isNotEmpty) {
        timer.cancel();
        state = const AsyncData(false);
      }
      // 如果超过5次没有启动，退出
      if (attempt >= maxAttempt) {
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
    final mysqlNotifier = ref.read(mysqlInformationNotifierProvider.notifier);
    mysqlNotifier.stop();
  }

  void startClient() async {
    final server = await ref.read(activeServerNotifierProvider.future);
    if (server.clientPath.isEmpty) return;
    ProcessUtil().start(server.clientPath);
  }
}
