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

  test('扫描模拟器根目录,发现全部配置项', () async {
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

    final result = await discoverServer(
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
    // 日志路径由 conf 推导:conf 目录 + LogFileDir + LogFile
    expect(s.worldServerLog, '${bin.path}/logs/Server.log');
    expect(s.authServerLog, '${bin.path}/logs/Auth.log');
    // BindIP 为 0.0.0.0 时保持默认登录地址
    expect(s.realmList, '127.0.0.1');
    expect(s.clientPath, '${clientRoot.path}/Wow.exe');
    expect(result.warnings, isEmpty);
  });

  test('conf 不存在时回退 .dist 模板,无 LogFile 时不推导日志路径', () async {
    final bin = Directory('${serverRoot.path}/bin')..createSync();
    File('${bin.path}/worldserver.exe').createSync();
    File('${bin.path}/authserver.exe').createSync();
    write('${bin.path}/worldserver.conf.dist', 'LogFile = "Server.log"\n');
    // authserver 没有 conf

    final result = await discoverServer(
      serverDir: serverRoot.path,
      clientDir: clientRoot.path,
    );
    final s = result.server;

    expect(s.worldServerConfig, '${bin.path}/worldserver.conf.dist');
    expect(s.worldServerLog, '${bin.path}/Server.log');
    expect(s.authServerConfig, '');
    expect(s.authServerLog, '');
    // authserver.exe 存在,不应出现对应警告
    expect(result.warnings, isNot(contains('未找到 Auth Server(authserver),可在高级配置中手动指定')));
  });

  test('authserver.conf 指定 BindIP 时作为登录地址', () async {
    final bin = Directory('${serverRoot.path}/bin')..createSync();
    File('${bin.path}/authserver.exe').createSync();
    write(
      '${bin.path}/authserver.conf',
      'BindIP = "192.168.1.10"\nLogFile = "Auth.log"\n',
    );

    final result = await discoverServer(
      serverDir: serverRoot.path,
      clientDir: clientRoot.path,
    );
    expect(result.server.realmList, '192.168.1.10');
  });

  test('客户端按优先级选择主程序(wow-64.exe 优先于 wowclassic.exe)', () async {
    File('${clientRoot.path}/wowclassic.exe').createSync();
    File('${clientRoot.path}/wow-64.exe').createSync();

    final result = await discoverServer(
      serverDir: '',
      clientDir: clientRoot.path,
    );
    expect(result.server.clientPath, '${clientRoot.path}/wow-64.exe');
  });

  test('缺失项产生警告', () async {
    File('${clientRoot.path}/something.txt').createSync();

    final result = await discoverServer(
      serverDir: serverRoot.path,
      clientDir: clientRoot.path,
    );
    expect(result.warnings, hasLength(4));
    expect(
      result.warnings,
      containsAll([
        '未找到 MySQL(mysqld),可在高级配置中手动指定',
        '未找到 World Server(worldserver),可在高级配置中手动指定',
        '未找到 Auth Server(authserver),可在高级配置中手动指定',
        '未找到客户端主程序(Wow.exe),可在高级配置中手动指定',
      ]),
    );
  });

  test('目录不存在时提示', () async {
    final result = await discoverServer(
      serverDir: '${temp.path}/not_exist',
      clientDir: '',
    );
    expect(result.warnings, contains('服务端目录不存在:${temp.path}/not_exist'));
    expect(result.server.name, 'not_exist');
  });
}
