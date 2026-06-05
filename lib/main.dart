import 'package:arcane_launcher/di.dart';
import 'package:arcane_launcher/page/launcher/launcher.dart';
import 'package:arcane_launcher/schema/laconic.dart';
import 'package:arcane_launcher/viewmodel/auth_server_view_model.dart';
import 'package:arcane_launcher/viewmodel/external_application_view_model.dart';
import 'package:arcane_launcher/viewmodel/game_view_model.dart';
import 'package:arcane_launcher/viewmodel/mysqld_view_model.dart';
import 'package:arcane_launcher/viewmodel/server_view_model.dart';
import 'package:arcane_launcher/viewmodel/setting_view_model.dart';
import 'package:arcane_launcher/viewmodel/world_server_view_model.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowInitializer.ensureInitialized();
  await LaconicInitializer.ensureInitialized();
  setupDependencies();

  final serverVM = getIt<ServerViewModel>();
  final settingVM = getIt<SettingViewModel>();

  await Future.wait([
    serverVM.fetch(),
    getIt<ExternalApplicationViewModel>().fetch(),
    settingVM.fetch(),
    getIt<MysqldViewModel>().init(),
  ]);

  final server = serverVM.activeServer;
  await Future.wait([
    getIt<AuthServerViewModel>().init(server),
    getIt<AuthServerViewModel>().fetchConfig(server),
    getIt<WorldServerViewModel>().init(server),
    getIt<WorldServerViewModel>().fetchConfig(server),
  ]);

  getIt<GameViewModel>().init();

  runApp(const ArcaneLauncher());
}

class ArcaneLauncher extends StatelessWidget {
  const ArcaneLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    final s = getIt<SettingViewModel>().setting;
    return MaterialApp(
      title: 'Arcane Launcher',
      home: const LauncherPage(),
      theme: ThemeData(
        brightness: s.darkMode ? Brightness.dark : Brightness.light,
        colorSchemeSeed: Color(s.color),
        fontFamily: 'Microsoft YaHei UI',
      ),
    );
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
