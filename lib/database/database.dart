import 'dart:io';

import 'package:arcane_launcher/database/migration/migration_202506050000.dart';
import 'package:laconic/laconic.dart';
import 'package:laconic_sqlite/laconic_sqlite.dart';

late Laconic laconic;

class Database {
  static final Database instance = Database._internal();

  Database._internal();

  final _migrationCreateSql = '''
CREATE TABLE IF NOT EXISTS migrations(
  name TEXT NOT NULL
);
''';
  final _checkMigrationExistSql = '''
SELECT name FROM sqlite_master WHERE type='table' AND name='migrations';
''';

  Future<void> ensureInitialized() async {
    final directory = Directory.current;
    final file = File('${directory.path}/arcane_launcher.db');
    if (!await file.exists()) {
      await file.create();
    }

    laconic = Laconic(SqliteDriver(SqliteConfig(file.path)));

    await _migrate();
  }

  Future<void> _migrate() async {
    final tables = await laconic.select(_checkMigrationExistSql);
    if (tables.isEmpty) {
      await laconic.statement(_migrationCreateSql);
    }
    await Migration202506050000().migrate(laconic);
  }
}
