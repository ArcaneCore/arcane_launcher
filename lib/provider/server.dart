import 'package:arcane_launcher/schema/isar.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server.g.dart';

@riverpod
class ServersNotifier extends _$ServersNotifier {
  @override
  Future<List<Server>> build() async {
    return await isar.servers.where().findAll();
  }

  Future<void> store(Server server) async {
    await isar.writeTxn(() async {
      await isar.servers.put(server);
    });
    ref.invalidateSelf();
  }

  Future<void> destroy(Server server) async {
    await isar.writeTxn(() async {
      await isar.servers.delete(server.id);
    });
    ref.invalidateSelf();
  }

  Future<void> active(Server server) async {
    final queryBuilder = isar.servers.filter().activeEqualTo(true);
    final activeServers = await queryBuilder.findAll();
    if (activeServers.isNotEmpty) {
      for (final activeServer in activeServers) {
        activeServer.active = false;
      }
      await isar.writeTxn(() async {
        await isar.servers.putAll(activeServers);
      });
    }
    server.active = true;
    await store(server);
    return;
  }
}

@riverpod
class ActiveServerNotifier extends _$ActiveServerNotifier {
  @override
  Future<Server> build() async {
    final servers = await ref.watch(serversNotifierProvider.future);
    if (servers.isEmpty) return Server();
    final activeServer = servers.where((server) => server.active).firstOrNull;
    return activeServer ?? servers.first;
  }
}
