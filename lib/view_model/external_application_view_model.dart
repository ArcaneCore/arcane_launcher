import 'package:arcane_launcher/schema/external_application.dart';
import 'package:arcane_launcher/util/process.dart';
import 'package:arcane_launcher/util/yaml_store.dart';
import 'package:signals/signals.dart';

class ExternalApplicationViewModel {
  static const _fileName = 'external_applications.yaml';

  final _apps = signal<List<ExternalApplication>>([]);
  final _store = YamlStore(_fileName);

  List<ExternalApplication> get applications => _apps.value;

  Future<void> fetch() async {
    final results = await _store.readList();
    _apps.value = results.map(ExternalApplication.fromMap).toList();
  }

  void start(int index) {
    final apps = _apps.value;
    if (index >= apps.length) return;
    ProcessUtil().start(apps[index].path);
  }

  Future<void> store(ExternalApplication application) async {
    if (application.id != null && application.id != 0) {
      _apps.value = [
        for (final a in _apps.value)
          a.id == application.id ? application : a,
      ];
    } else {
      application.id = _nextId();
      _apps.value = [..._apps.value, application];
    }
    await _save();
  }

  Future<void> destroy(ExternalApplication application) async {
    _apps.value =
        _apps.value.where((a) => a.id != application.id).toList();
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
    await _store.writeList([
      for (final a in _apps.value) a.toMap(),
    ]);
  }
}
