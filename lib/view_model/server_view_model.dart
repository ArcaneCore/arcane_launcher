import 'package:arcane_launcher/schema/server.dart';
import 'package:arcane_launcher/util/json_store.dart';
import 'package:signals/signals.dart';

class ServerViewModel {
  static const _fileName = 'servers.json';

  final _servers = signal<List<Server>>([]);
  late final Computed<Server> _activeServer;
  final _store = JsonStore(_fileName);

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
    final results = await _store.readList();
    _servers.value = results.map(Server.fromMap).toList();
  }

  Future<void> store(Server server) async {
    if (server.id != null && server.id != 0) {
      _servers.value = [
        for (final s in _servers.value) s.id == server.id ? server : s,
      ];
    } else {
      server.id = _nextId();
      _servers.value = [..._servers.value, server];
    }
    await _save();
  }

  Future<void> destroy(Server server) async {
    _servers.value = _servers.value.where((s) => s.id != server.id).toList();
    await _save();
  }

  Future<void> activate(Server server) async {
    _servers.value = [
      for (final s in _servers.value) s.copyWith(active: s.id == server.id),
    ];
    await _save();
  }

  int _nextId() {
    var maxId = 0;
    for (final s in _servers.value) {
      if ((s.id ?? 0) > maxId) maxId = s.id!;
    }
    return maxId + 1;
  }

  Future<void> _save() async {
    await _store.writeList([
      for (final s in _servers.value) s.toMap(),
    ]);
  }
}
