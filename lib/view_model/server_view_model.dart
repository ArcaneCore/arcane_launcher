import 'package:arcane_launcher/schema/laconic.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:signals/signals.dart';

class ServerViewModel {
  final _servers = signal<List<Server>>([]);
  late final Computed<Server> _activeServer;

  ServerViewModel() {
    _activeServer = computed<Server>(() {
      if (_servers.value.isEmpty) return Server();
      return _servers.value.firstWhere((s) => s.active,
          orElse: () => _servers.value.first);
    });
  }

  List<Server> get servers => _servers.value;
  Server get activeServer => _activeServer.value;

  Future<void> fetch() async {
    final results = await laconic.table('servers').get();
    _servers.value =
        results.map((r) => Server.fromMap(r.toMap())).toList();
  }

  Future<void> store(Server server) async {
    if (server.id != null && server.id != 0) {
      await laconic
          .table('servers')
          .where('id', server.id!)
          .update(server.toMap());
    } else {
      final id =
          await laconic.table('servers').insertGetId(server.toMap());
      server.id = id;
    }
    await fetch();
  }

  Future<void> destroy(Server server) async {
    await laconic.table('servers').where('id', server.id!).delete();
    await fetch();
  }

  Future<void> activate(Server server) async {
    await laconic.statement('UPDATE servers SET active = 0');
    server.active = true;
    await store(server);
  }
}
