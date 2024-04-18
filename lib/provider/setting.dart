import 'package:arcane_launcher/schema/isar.dart';
import 'package:arcane_launcher/schema/setting.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setting.g.dart';

@riverpod
class SettingNotifier extends _$SettingNotifier {
  @override
  Future<Setting> build() async {
    final settings = await isar.settings.where().findAll();
    if (settings.isEmpty) {
      final setting = Setting();
      await isar.writeTxn(() async {
        await isar.settings.put(setting);
      });
      return setting;
    }
    return settings.first;
  }

  Future<void> updateColor(int color) async {
    final setting = await future;
    setting.color = color;
    await isar.writeTxn(() async {
      await isar.settings.put(setting);
    });
    ref.invalidateSelf();
  }

  Future<void> toggleBrightness() async {
    final setting = await future;
    setting.darkMode = !setting.darkMode;
    await isar.writeTxn(() async {
      await isar.settings.put(setting);
    });
    ref.invalidateSelf();
  }
}
