import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

/// Utility for reading and writing YAML config files in the working directory.
///
/// Writes atomically via a temp file + rename so a crash mid-write cannot
/// corrupt the config file.
class YamlStore {
  YamlStore(this.fileName);

  /// File name (relative to the working directory), e.g. servers.yaml.
  final String fileName;

  File get _file => File('${Directory.current.path}/$fileName');

  final _writer = YamlWriter();

  /// Reads a list-shaped YAML file, creating an empty file first when missing.
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

  /// Atomic write: write a `.tmp` file first, then rename over the target.
  Future<void> writeList(List<Map<String, Object?>> data) async {
    final file = _file;
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(_writer.write(data), flush: true);
    await temp.rename(file.path);
  }
}
