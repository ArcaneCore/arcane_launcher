import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceUtil {
  final _preferences = SharedPreferences.getInstance();

  static const _keyColor = 'color';
  static const _keyDarkMode = 'dark_mode';

  static const _defaultColor = 4288423856;
  static const _defaultDarkMode = false;

  Future<void> init() async {
    final prefs = await _preferences;
    if (!prefs.containsKey(_keyColor)) {
      await prefs.setInt(_keyColor, _defaultColor);
    }
    if (!prefs.containsKey(_keyDarkMode)) {
      await prefs.setBool(_keyDarkMode, _defaultDarkMode);
    }
  }

  Future<int> getColor() async {
    return (await _preferences).getInt(_keyColor) ?? _defaultColor;
  }

  Future<void> setColor(int value) async {
    (await _preferences).setInt(_keyColor, value);
  }

  Future<bool> getDarkMode() async {
    return (await _preferences).getBool(_keyDarkMode) ?? _defaultDarkMode;
  }

  Future<void> setDarkMode(bool value) async {
    (await _preferences).setBool(_keyDarkMode, value);
  }
}
