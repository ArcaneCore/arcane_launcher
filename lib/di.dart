import 'package:arcane_launcher/util/process_util.dart';
import 'package:arcane_launcher/util/server_discovery.dart';
import 'package:arcane_launcher/util/shared_preference_util.dart';
import 'package:arcane_launcher/util/yaml_store.dart';
import 'package:arcane_launcher/view_model/application_view_model.dart';
import 'package:arcane_launcher/view_model/auth_server_view_model.dart';
import 'package:arcane_launcher/view_model/game_view_model.dart';
import 'package:arcane_launcher/view_model/mysqld_view_model.dart';
import 'package:arcane_launcher/view_model/server_view_model.dart';
import 'package:arcane_launcher/view_model/setting_view_model.dart';
import 'package:arcane_launcher/view_model/world_server_view_model.dart';
import 'package:get_it/get_it.dart';

/// Central registration point for all application dependencies.
class Di {
  static final Di instance = Di._();

  final _getIt = GetIt.instance;

  Di._();

  /// Registers all services and view models with the locator.
  void ensureInitialized() {
    _getIt.registerLazySingleton<ProcessUtil>(ProcessUtil.new);
    _getIt.registerLazySingleton<ServerDiscovery>(ServerDiscovery.new);
    _getIt.registerLazySingleton<YamlStore>(YamlStore.new);
    _getIt.registerLazySingleton<SharedPreferenceUtil>(
      SharedPreferenceUtil.new,
    );

    _getIt.registerSingleton(ServerViewModel());
    _getIt.registerSingleton(ApplicationViewModel());
    _getIt.registerSingleton(SettingViewModel());
    _getIt.registerSingleton(MysqldViewModel());
    _getIt.registerSingleton(AuthServerViewModel());
    _getIt.registerSingleton(WorldServerViewModel());
    _getIt.registerSingleton(GameViewModel());
  }
}
