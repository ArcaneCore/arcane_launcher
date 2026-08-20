import 'dart:io';

import 'package:arcane_launcher/util/server_discovery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temp;
  late Directory serverRoot;
  late Directory clientRoot;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('arcane_discovery_test');
    serverRoot = Directory('${temp.path}/server')..createSync();
    clientRoot = Directory('${temp.path}/client')..createSync();
  });

  tearDown(() {
    temp.deleteSync(recursive: true);
  });

  void write(String path, String content) {
    File(path).writeAsStringSync(content);
  }

  test('discovers all config items from an emulator root', () async {
    final bin = Directory('${serverRoot.path}/bin')..createSync();
    final mysqlBin = Directory('${serverRoot.path}/mysql/bin')
      ..createSync(recursive: true);
    File('${bin.path}/worldserver.exe').createSync();
    File('${bin.path}/authserver.exe').createSync();
    File('${mysqlBin.path}/mysqld.exe').createSync();
    write(
      '${bin.path}/worldserver.conf',
      'LogFileDir = "logs"\nLogFile = "Server.log"\n',
    );
    write(
      '${bin.path}/authserver.conf',
      'LogsDir = "logs"\nLogFile = "Auth.log"\nBindIP = "0.0.0.0"\n',
    );
    File('${clientRoot.path}/Wow.exe').createSync();

    final result = await ServerDiscovery.instance.discover(
      serverDir: serverRoot.path,
      clientDir: clientRoot.path,
    );
    final s = result.server;

    expect(s.name, 'server');
    expect(s.mysqldPath, '${mysqlBin.path}/mysqld.exe');
    expect(s.worldServerPath, '${bin.path}/worldserver.exe');
    expect(s.authServerPath, '${bin.path}/authserver.exe');
    expect(s.worldServerConfig, '${bin.path}/worldserver.conf');
    expect(s.authServerConfig, '${bin.path}/authserver.conf');
    // Log path is derived from conf: conf dir + LogFileDir + LogFile.
    expect(s.worldServerLog, '${bin.path}/logs/Server.log');
    expect(s.authServerLog, '${bin.path}/logs/Auth.log');
    // BindIP 0.0.0.0 keeps the default realm list address.
    expect(s.realmList, '127.0.0.1');
    expect(s.clientPath, '${clientRoot.path}/Wow.exe');
    expect(result.warnings, isEmpty);
  });

  test(
    'falls back to .dist template and skips log path when conf has no LogFile',
    () async {
      final bin = Directory('${serverRoot.path}/bin')..createSync();
      File('${bin.path}/worldserver.exe').createSync();
      File('${bin.path}/authserver.exe').createSync();
      write('${bin.path}/worldserver.conf.dist', 'LogFile = "Server.log"\n');
      // authserver has no conf.

      final result = await ServerDiscovery.instance.discover(
        serverDir: serverRoot.path,
        clientDir: clientRoot.path,
      );
      final s = result.server;

      expect(s.worldServerConfig, '${bin.path}/worldserver.conf.dist');
      expect(s.worldServerLog, '${bin.path}/Server.log');
      expect(s.authServerConfig, '');
      expect(s.authServerLog, '');
      // authserver.exe exists, so no matching warning is expected.
      expect(
        result.warnings,
        isNot(
          contains(
            'Auth Server (authserver) not found; specify it in Advanced settings',
          ),
        ),
      );
    },
  );

  test('uses BindIP from authserver.conf as the realm list address', () async {
    final bin = Directory('${serverRoot.path}/bin')..createSync();
    File('${bin.path}/authserver.exe').createSync();
    write(
      '${bin.path}/authserver.conf',
      'BindIP = "192.168.1.10"\nLogFile = "Auth.log"\n',
    );

    final result = await ServerDiscovery.instance.discover(
      serverDir: serverRoot.path,
      clientDir: clientRoot.path,
    );
    expect(result.server.realmList, '192.168.1.10');
  });

  test(
    'picks client executable by priority (wow-64.exe over wowclassic.exe)',
    () async {
      File('${clientRoot.path}/wowclassic.exe').createSync();
      File('${clientRoot.path}/wow-64.exe').createSync();

      final result = await ServerDiscovery.instance.discover(
        serverDir: '',
        clientDir: clientRoot.path,
      );
      expect(result.server.clientPath, '${clientRoot.path}/wow-64.exe');
    },
  );

  test('warns about missing items', () async {
    File('${clientRoot.path}/something.txt').createSync();

    final result = await ServerDiscovery.instance.discover(
      serverDir: serverRoot.path,
      clientDir: clientRoot.path,
    );
    expect(result.warnings, hasLength(4));
    expect(
      result.warnings,
      containsAll([
        'MySQL (mysqld) not found; specify it in Advanced settings',
        'World Server (worldserver) not found; specify it in Advanced settings',
        'Auth Server (authserver) not found; specify it in Advanced settings',
        'Client executable (Wow.exe) not found; specify it in Advanced settings',
      ]),
    );
  });

  test('warns when a directory does not exist', () async {
    final result = await ServerDiscovery.instance.discover(
      serverDir: '${temp.path}/not_exist',
      clientDir: '',
    );
    expect(
      result.warnings,
      contains('Server directory does not exist: ${temp.path}/not_exist'),
    );
    expect(result.server.name, 'not_exist');
  });
}
