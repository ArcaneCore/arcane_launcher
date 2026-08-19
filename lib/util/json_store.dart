import 'dart:convert';
import 'dart:io';

/// 读写工作目录下 JSON 配置文件的工具类。
///
/// 写入时先写临时文件再重命名覆盖，避免应用中途退出导致配置文件损坏。
class JsonStore {
  JsonStore(this.fileName);

  /// 文件名（相对工作目录），如 servers.json。
  final String fileName;

  File get _file => File('${Directory.current.path}/$fileName');

  static const _encoder = JsonEncoder.withIndent('  ');

  /// 读取列表型 JSON 文件，文件不存在或内容为空时返回空列表。
  Future<List<Map<String, Object?>>> readList() async {
    final file = _file;
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];
    final decoded = jsonDecode(content);
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
    await temp.writeAsString(_encoder.convert(data), flush: true);
    await temp.rename(file.path);
  }
}
