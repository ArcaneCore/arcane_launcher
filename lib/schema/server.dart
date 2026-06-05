class Server {
  int? id;
  String name;
  String description;
  String version;
  bool local;
  String realmList;
  String mysqldPath;
  String worldServerPath;
  String worldServerConfig;
  String worldServerLog;
  String authServerPath;
  String authServerConfig;
  String authServerLog;
  String clientPath;
  bool active;

  Server({
    this.id,
    this.name = '',
    this.description = '',
    this.version = '',
    this.local = true,
    this.realmList = '127.0.0.1',
    this.mysqldPath = '',
    this.worldServerPath = '',
    this.worldServerConfig = '',
    this.worldServerLog = '',
    this.authServerPath = '',
    this.authServerConfig = '',
    this.authServerLog = '',
    this.clientPath = '',
    this.active = false,
  });

  factory Server.fromMap(Map<String, Object?> map) {
    return Server(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      version: map['version'] as String? ?? '',
      local: (map['local'] as int?) == 1,
      realmList: map['realm_list'] as String? ?? '127.0.0.1',
      mysqldPath: map['mysqld_path'] as String? ?? '',
      worldServerPath: map['world_server_path'] as String? ?? '',
      worldServerConfig: map['world_server_config'] as String? ?? '',
      worldServerLog: map['world_server_log'] as String? ?? '',
      authServerPath: map['auth_server_path'] as String? ?? '',
      authServerConfig: map['auth_server_config'] as String? ?? '',
      authServerLog: map['auth_server_log'] as String? ?? '',
      clientPath: map['client_path'] as String? ?? '',
      active: (map['active'] as int?) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'version': version,
      'local': local ? 1 : 0,
      'realm_list': realmList,
      'mysqld_path': mysqldPath,
      'world_server_path': worldServerPath,
      'world_server_config': worldServerConfig,
      'world_server_log': worldServerLog,
      'auth_server_path': authServerPath,
      'auth_server_config': authServerConfig,
      'auth_server_log': authServerLog,
      'client_path': clientPath,
      'active': active ? 1 : 0,
    };
  }

  Server copyWith({
    int? id,
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
    return Server(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      local: local ?? this.local,
      realmList: realmList ?? this.realmList,
      mysqldPath: mysqldPath ?? this.mysqldPath,
      worldServerPath: worldServerPath ?? this.worldServerPath,
      worldServerConfig: worldServerConfig ?? this.worldServerConfig,
      worldServerLog: worldServerLog ?? this.worldServerLog,
      authServerPath: authServerPath ?? this.authServerPath,
      authServerConfig: authServerConfig ?? this.authServerConfig,
      authServerLog: authServerLog ?? this.authServerLog,
      clientPath: clientPath ?? this.clientPath,
      active: active ?? this.active,
    );
  }
}
