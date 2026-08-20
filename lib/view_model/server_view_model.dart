import 'package:get_it/get_it.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:arcane_launcher/util/yaml_store.dart';
import 'package:signals/signals.dart';

class ServerViewModel {
  static const _fileName = 'servers.yaml';

  final _servers = signal<List<ServerEntity>>([]);
  late final Computed<ServerEntity> _activeServer;
  final _store = GetIt.instance.get<YamlStore>();

  ServerViewModel() {
    _activeServer = computed<ServerEntity>(() {
      if (_servers.value.isEmpty) return ServerEntity();
      return _servers.value.firstWhere(
        (s) => s.active,
        orElse: () => _servers.value.first,
      );
    });
  }

  List<ServerEntity> get servers => _servers.value;
  ServerEntity get activeServer => _activeServer.value;

  Future<void> fetch() async {
    final results = await _store.readList(_fileName);
    _servers.value = results.map(ServerEntity.fromMap).toList();
  }

  Future<void> store(ServerEntity server) async {
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

  Future<void> destroy(ServerEntity server) async {
    _servers.value = _servers.value.where((s) => s.id != server.id).toList();
    await _save();
  }

  Future<void> activate(ServerEntity server) async {
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
    await _store.writeList(_fileName, [
      for (final s in _servers.value) s.toMap(),
    ]);
  }
}
