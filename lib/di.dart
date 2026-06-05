import 'package:arcane_launcher/viewmodel/auth_server_view_model.dart';
import 'package:arcane_launcher/viewmodel/external_application_view_model.dart';
import 'package:arcane_launcher/viewmodel/game_view_model.dart';
import 'package:arcane_launcher/viewmodel/mysqld_view_model.dart';
import 'package:arcane_launcher/viewmodel/server_view_model.dart';
import 'package:arcane_launcher/viewmodel/setting_view_model.dart';
import 'package:arcane_launcher/viewmodel/world_server_view_model.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton(ServerViewModel());
  getIt.registerSingleton(ExternalApplicationViewModel());
  getIt.registerSingleton(SettingViewModel());
  getIt.registerSingleton(MysqldViewModel());
  getIt.registerSingleton(AuthServerViewModel());
  getIt.registerSingleton(WorldServerViewModel());
  getIt.registerSingleton(GameViewModel());
}
