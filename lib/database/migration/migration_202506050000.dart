import 'package:laconic/laconic.dart';

class Migration202506050000 {
  static const name = 'migration_202506050000';

  Future<void> migrate(Laconic laconic) async {
    final count = await laconic.table('migrations').where('name', name).count();
    if (count > 0) return;

    await laconic.statement('''
      CREATE TABLE IF NOT EXISTS servers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        version TEXT NOT NULL DEFAULT '',
        local INTEGER NOT NULL DEFAULT 1,
        realm_list TEXT NOT NULL DEFAULT '127.0.0.1',
        mysqld_path TEXT NOT NULL DEFAULT '',
        world_server_path TEXT NOT NULL DEFAULT '',
        world_server_config TEXT NOT NULL DEFAULT '',
        world_server_log TEXT NOT NULL DEFAULT '',
        auth_server_path TEXT NOT NULL DEFAULT '',
        auth_server_config TEXT NOT NULL DEFAULT '',
        auth_server_log TEXT NOT NULL DEFAULT '',
        client_path TEXT NOT NULL DEFAULT '',
        active INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await laconic.statement('''
      CREATE TABLE IF NOT EXISTS external_applications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL DEFAULT '',
        path TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT ''
      )
    ''');

    await laconic.table('migrations').insert([
      {'name': name},
    ]);
  }
}
