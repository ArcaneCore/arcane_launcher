import 'package:arcane_launcher/schema/setting.dart';
import 'package:arcane_launcher/util/shared_preference_util.dart';
import 'package:signals/signals.dart';

class SettingViewModel {
  final _setting = signal(SettingEntity());
  final _prefs = SharedPreferenceUtil.instance;

  SettingEntity get setting => _setting.value;

  Future<void> fetch() async {
    final color = await _prefs.getColor();
    final darkMode = await _prefs.getDarkMode();
    _setting.value = SettingEntity(color: color, darkMode: darkMode);
  }

  Future<void> updateColor(int color) async {
    await _prefs.setColor(color);
    final s = _setting.value;
    _setting.value = SettingEntity(
      id: s.id,
      color: color,
      darkMode: s.darkMode,
    );
  }

  Future<void> toggleBrightness() async {
    final s = _setting.value;
    final darkMode = !s.darkMode;
    await _prefs.setDarkMode(darkMode);
    _setting.value = SettingEntity(
      id: s.id,
      color: s.color,
      darkMode: darkMode,
    );
  }
}
