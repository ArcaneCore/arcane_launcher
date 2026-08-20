import 'package:arcane_launcher/di.dart';
import 'package:arcane_launcher/page/launcher/launcher.dart';
import 'package:arcane_launcher/util/shared_preference_util.dart';
import 'package:arcane_launcher/view_model/auth_server_view_model.dart';
import 'package:arcane_launcher/view_model/application_view_model.dart';
import 'package:arcane_launcher/view_model/game_view_model.dart';
import 'package:arcane_launcher/view_model/mysqld_view_model.dart';
import 'package:arcane_launcher/view_model/server_view_model.dart';
import 'package:arcane_launcher/view_model/setting_view_model.dart';
import 'package:arcane_launcher/view_model/world_server_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowInitializer.ensureInitialized();
  setupDependencies();
  await GetIt.instance.get<SharedPreferenceUtil>().init();

  final serverVM = GetIt.instance.get<ServerViewModel>();
  final settingVM = GetIt.instance.get<SettingViewModel>();

  await Future.wait([
    serverVM.fetch(),
    GetIt.instance.get<ApplicationViewModel>().fetch(),
    settingVM.fetch(),
    GetIt.instance.get<MysqldViewModel>().init(),
  ]);

  final server = serverVM.activeServer;
  await Future.wait([
    GetIt.instance.get<AuthServerViewModel>().init(server),
    GetIt.instance.get<AuthServerViewModel>().fetchConfig(server),
    GetIt.instance.get<WorldServerViewModel>().init(server),
    GetIt.instance.get<WorldServerViewModel>().fetchConfig(server),
  ]);

  GetIt.instance.get<GameViewModel>().init();

  runApp(const ArcaneLauncher());
}

class ArcaneLauncher extends StatelessWidget {
  const ArcaneLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final s = GetIt.instance.get<SettingViewModel>().setting;
        return MaterialApp(
          title: 'Arcane Launcher',
          home: const LauncherPage(),
          theme: ThemeData(
            brightness: s.darkMode ? Brightness.dark : Brightness.light,
            colorSchemeSeed: Color(s.color),
            fontFamily: 'Microsoft YaHei UI',
          ),
        );
      },
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
