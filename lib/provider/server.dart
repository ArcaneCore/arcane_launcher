import 'package:arcane_launcher/schema/laconic.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server.g.dart';

@riverpod
class ServersNotifier extends _$ServersNotifier {
  @override
  Future<List<Server>> build() async {
    final results = await laconic.table('servers').get();
    return results.map((r) => Server.fromMap(r.toMap())).toList();
  }

  Future<void> store(Server server) async {
    if (server.id != null && server.id != 0) {
      await laconic.table('servers').where('id', server.id!).update(server.toMap());
    } else {
      final id = await laconic.table('servers').insertGetId(server.toMap());
      server.id = id;
    }
    ref.invalidateSelf();
  }

  Future<void> destroy(Server server) async {
    await laconic.table('servers').where('id', server.id!).delete();
    ref.invalidateSelf();
  }

  Future<void> active(Server server) async {
    await laconic.statement('UPDATE servers SET active = 0');
    server.active = true;
    await store(server);
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
