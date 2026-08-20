import 'package:get_it/get_it.dart';
import 'package:arcane_launcher/schema/application.dart';
import 'package:arcane_launcher/util/process_util.dart';
import 'package:arcane_launcher/util/yaml_store.dart';
import 'package:signals/signals.dart';

class ApplicationViewModel {
  static const _fileName = 'applications.yaml';

  final _apps = signal<List<ApplicationEntity>>([]);
  final _store = GetIt.instance.get<YamlStore>();
  final _process = GetIt.instance.get<ProcessUtil>();

  List<ApplicationEntity> get applications => _apps.value;

  Future<void> fetch() async {
    final results = await _store.readList(_fileName);
    _apps.value = results.map(ApplicationEntity.fromMap).toList();
  }

  void start(int index) {
    final apps = _apps.value;
    if (index >= apps.length) return;
    _process.start(apps[index].path);
  }

  Future<void> store(ApplicationEntity application) async {
    if (application.id != null && application.id != 0) {
      _apps.value = [
        for (final a in _apps.value) a.id == application.id ? application : a,
      ];
    } else {
      application.id = _nextId();
      _apps.value = [..._apps.value, application];
    }
    await _save();
  }

  Future<void> destroy(ApplicationEntity application) async {
    _apps.value = _apps.value.where((a) => a.id != application.id).toList();
    await _save();
  }

  int _nextId() {
    var maxId = 0;
    for (final a in _apps.value) {
      if ((a.id ?? 0) > maxId) maxId = a.id!;
    }
    return maxId + 1;
  }

  Future<void> _save() async {
    await _store.writeList(_fileName, [for (final a in _apps.value) a.toMap()]);
  }
}
