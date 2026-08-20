import 'package:arcane_launcher/util/process_util.dart';
import 'package:arcane_launcher/util/server_discovery.dart';
import 'package:arcane_launcher/util/shared_preference_util.dart';
import 'package:arcane_launcher/util/yaml_store.dart';
import 'package:arcane_launcher/view_model/auth_server_view_model.dart';
import 'package:arcane_launcher/view_model/application_view_model.dart';
import 'package:arcane_launcher/view_model/game_view_model.dart';
import 'package:arcane_launcher/view_model/mysqld_view_model.dart';
import 'package:arcane_launcher/view_model/server_view_model.dart';
import 'package:arcane_launcher/view_model/setting_view_model.dart';
import 'package:arcane_launcher/view_model/world_server_view_model.dart';
import 'package:get_it/get_it.dart';

void setupDependencies() {
  GetIt.instance.registerLazySingleton<ProcessUtil>(ProcessUtil.new);
  GetIt.instance.registerLazySingleton<ServerDiscovery>(ServerDiscovery.new);
  GetIt.instance.registerLazySingleton<YamlStore>(YamlStore.new);
  GetIt.instance.registerLazySingleton<SharedPreferenceUtil>(
    SharedPreferenceUtil.new,
  );

  GetIt.instance.registerSingleton(ServerViewModel());
  GetIt.instance.registerSingleton(ApplicationViewModel());
  GetIt.instance.registerSingleton(SettingViewModel());
  GetIt.instance.registerSingleton(MysqldViewModel());
  GetIt.instance.registerSingleton(AuthServerViewModel());
  GetIt.instance.registerSingleton(WorldServerViewModel());
  GetIt.instance.registerSingleton(GameViewModel());
}
