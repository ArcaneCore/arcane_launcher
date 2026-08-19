import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

/// 读写工作目录下 YAML 配置文件的工具类。
///
/// 写入时先写临时文件再重命名覆盖，避免应用中途退出导致配置文件损坏。
class YamlStore {
  YamlStore(this.fileName);

  /// 文件名（相对工作目录），如 servers.yaml。
  final String fileName;

  File get _file => File('${Directory.current.path}/$fileName');

  final _writer = YamlWriter();

  /// 读取列表型 YAML 文件，文件不存在时先创建空文件，再返回空列表。
  Future<List<Map<String, Object?>>> readList() async {
    final file = _file;
    if (!await file.exists()) {
      await writeList([]);
      return [];
    }
    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];
    final decoded = loadYaml(content);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => e.cast<String, Object?>())
        .toList();
  }

  /// 原子写入：先写 `.tmp` 临时文件，再重命名覆盖原文件。
  Future<void> writeList(List<Map<String, Object?>> data) async {
    final file = _file;
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(_writer.write(data), flush: true);
    await temp.rename(file.path);
  }
}
