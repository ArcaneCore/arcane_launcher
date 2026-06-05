import 'package:arcane_launcher/schema/laconic.dart';
import 'package:arcane_launcher/schema/setting.dart';
import 'package:signals/signals.dart';

class SettingViewModel {
  final _setting = signal(Setting());

  Setting get setting => _setting.value;

  Future<void> fetch() async {
    final results = await laconic.table('settings').get();
    if (results.isEmpty) {
      final s = Setting();
      final id = await laconic.table('settings').insertGetId(s.toMap());
      s.id = id;
      _setting.value = s;
      return;
    }
    _setting.value = Setting.fromMap(results.first.toMap());
  }

  Future<void> updateColor(int color) async {
    final s = _setting.value;
    s.color = color;
    await laconic.table('settings').where('id', s.id!).update(s.toMap());
    await fetch();
  }

  Future<void> toggleBrightness() async {
    final s = _setting.value;
    s.darkMode = !s.darkMode;
    await laconic.table('settings').where('id', s.id!).update(s.toMap());
    await fetch();
  }
}
