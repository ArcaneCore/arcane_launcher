import 'package:isar/isar.dart';

part 'server.g.dart';

@collection
@Name('servers')
class Server {
  Id id = Isar.autoIncrement;
  String name = '';
  String description = '';
  String version = '';
  bool local = true;
  @Name('realm_list')
  String realmList = '127.0.0.1';
  @Name('mysqld_path')
  String mysqldPath = '';
  @Name('world_server_path')
  String worldServerPath = '';
  @Name('world_server_config')
  String worldServerConfig = '';
  @Name('world_server_log')
  String worldServerLog = '';
  @Name('auth_server_path')
  String authServerPath = '';
  @Name('auth_server_config')
  String authServerConfig = '';
  @Name('auth_server_log')
  String authServerLog = '';
  @Name('client_path')
  String clientPath = '';
  bool active = false;

  Server copyWith({
    Id? id,
    String? name,
    String? description,
    String? version,
    bool? local,
    String? realmList,
    String? mysqldPath,
    String? worldServerPath,
    String? worldServerConfig,
    String? worldServerLog,
    String? authServerPath,
    String? authServerConfig,
    String? authServerLog,
    String? clientPath,
    bool? active,
  }) {
    return Server()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..description = description ?? this.description
      ..version = version ?? this.version
      ..local = local ?? this.local
      ..realmList = realmList ?? this.realmList
      ..mysqldPath = mysqldPath ?? this.mysqldPath
      ..worldServerPath = worldServerPath ?? this.worldServerPath
      ..authServerPath = authServerPath ?? this.authServerPath
      ..clientPath = clientPath ?? this.clientPath
      ..active = active ?? this.active;
  }
}
