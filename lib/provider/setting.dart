import 'package:arcane_launcher/schema/laconic.dart';
import 'package:arcane_launcher/schema/setting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setting.g.dart';

@riverpod
class SettingNotifier extends _$SettingNotifier {
  @override
  Future<Setting> build() async {
    final results = await laconic.table('settings').get();
    if (results.isEmpty) {
      final setting = Setting();
      final id = await laconic.table('settings').insertGetId(setting.toMap());
      setting.id = id;
      return setting;
    }
    return Setting.fromMap(results.first.toMap());
  }

  Future<void> updateColor(int color) async {
    final setting = await future;
    setting.color = color;
    await laconic.table('settings').where('id', setting.id!).update(setting.toMap());
    ref.invalidateSelf();
  }

  Future<void> toggleBrightness() async {
    final setting = await future;
    setting.darkMode = !setting.darkMode;
    await laconic.table('settings').where('id', setting.id!).update(setting.toMap());
    ref.invalidateSelf();
  }
}
