import 'package:arcane_launcher/view_model/auth_server_view_model.dart';
import 'package:arcane_launcher/view_model/application_view_model.dart';
import 'package:arcane_launcher/view_model/game_view_model.dart';
import 'package:arcane_launcher/view_model/mysqld_view_model.dart';
import 'package:arcane_launcher/view_model/server_view_model.dart';
import 'package:arcane_launcher/view_model/setting_view_model.dart';
import 'package:arcane_launcher/view_model/world_server_view_model.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton(ServerViewModel());
  getIt.registerSingleton(ApplicationViewModel());
  getIt.registerSingleton(SettingViewModel());
  getIt.registerSingleton(MysqldViewModel());
  getIt.registerSingleton(AuthServerViewModel());
  getIt.registerSingleton(WorldServerViewModel());
  getIt.registerSingleton(GameViewModel());
}
