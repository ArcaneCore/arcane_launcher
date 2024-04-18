import 'package:arcane_launcher/page/launcher/launcher.dart';
import 'package:arcane_launcher/provider/setting.dart';
import 'package:arcane_launcher/schema/isar.dart';
import 'package:arcane_launcher/schema/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowInitializer.ensureInitialized();
  await IsarInitializer.ensureInitialized();
  runApp(const ProviderScope(child: ArcaneLauncher()));
}

class ArcaneLauncher extends StatelessWidget {
  const ArcaneLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final provider = ref.watch(settingNotifierProvider);
      final setting = switch (provider) {
        AsyncData(:final value) => value,
        _ => Setting(),
      };
      return MaterialApp(
        title: 'Arcane Launcher',
        home: const LauncherPage(),
        theme: ThemeData(
          brightness: setting.darkMode ? Brightness.dark : Brightness.light,
          colorSchemeSeed: Color(setting.color),
          fontFamily: 'Microsoft YaHei',
        ),
      );
    });
  }
}

class WindowInitializer {
  static Future<void> ensureInitialized() async {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      center: true,
      size: Size(1440, 1000),
      title: 'Arcane Launcher',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
