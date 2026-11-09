import 'dart:convert';

/// Value type used to choose the editing control for a config entry.
enum ConfigValueType { boolean, integer, decimal, string }

/// One setting (`Key = Value`) of an INI-style server config file.
///
/// The original text of the line is kept intact; only the value is mutable, so
/// serializing an edited document leaves comments, alignment and every other
/// line untouched.
class ConfigEntry {
  ConfigEntry._(
    this.key,
    this.section,
    this.description,
    this.type,
    this._line,
  );

  final String key;
  final String section;

  /// Text after `Description:` in the comment block above the entry.
  final String description;

  /// Fixed at parse time, so a control never changes type while editing.
  final ConfigValueType type;

  final _ConfigLine _line;

  /// Raw value as written in the file, quotes included.
  String get value => _line.value;

  bool get isModified => _line.value != _line.originalValue;

  bool get boolValue => value.trim() == '1';

  set boolValue(bool value) => _line.value = value ? '1' : '0';

  /// Value for a text field: surrounding quotes are hidden from the user.
  String get displayValue {
    final value = this.value;
    if (_isQuoted(value)) return value.substring(1, value.length - 1);
    return value;
  }

  /// Applies a text field edit, restoring quotes for quoted string values.
  void updateDisplayValue(String text) {
    _line.value = _isQuoted(value) ? '"$text"' : text;
  }

  void accept() => _line.originalValue = _line.value;

  static bool _isQuoted(String value) =>
      value.length >= 2 && value.startsWith('"') && value.endsWith('"');
}

/// A group of entries introduced by a `# SECTION NAME` banner in the file.
class ConfigSection {
  ConfigSection(this.title);

  final String title;
  final List<ConfigEntry> entries = [];
}

/// Parsed, losslessly editable view of an INI-style config file.
class ConfigDocument {
  ConfigDocument._(this._lines, this.entries, this.sections);

  /// Parses [source] while keeping every line ending and the BOM character.
  factory ConfigDocument.parse(String source) {
    final lines = <_ConfigLine>[];
    final entries = <ConfigEntry>[];
    final sections = <ConfigSection>[];
    ConfigSection? current;

    for (final split in _splitLines(source)) {
      final text = split.text;
      final trimmed = text.trim();
      final previous = lines.isEmpty ? null : lines.last.text.trim();

      if (trimmed.startsWith('#') &&
          _isRule(previous) &&
          _headingPattern.hasMatch(trimmed)) {
        current = ConfigSection(trimmed.substring(1).trim());
        sections.add(current);
      }

      final match =
          trimmed.startsWith('#') ? null : _entryPattern.firstMatch(text);
      if (match == null) {
        lines.add(_ConfigLine.text(text, split.eol));
        continue;
      }

      final prefix = '${match.group(1)}${match.group(2)}${match.group(3)}';
      final value = match.group(4) ?? '';
      final suffix = match.group(5) ?? '';
      final description = _descriptionOf(lines);

      final line = _ConfigLine.entry(prefix, value, suffix, split.eol);
      lines.add(line);

      current ??= _addSection(sections, ConfigSection('General'));
      final entry = ConfigEntry._(
        match.group(2)!,
        current.title,
        description,
        _valueType(value),
        line,
      );
      entries.add(entry);
      current.entries.add(entry);
    }

    return ConfigDocument._(lines, entries, sections);
  }

  /// Parses raw file bytes, preserving a UTF-8 BOM in [source].
  factory ConfigDocument.parseBytes(List<int> bytes) {
    var source = utf8.decode(bytes);
    final hasBom =
        bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF;
    if (hasBom && !source.startsWith('\uFEFF')) {
      source = '\uFEFF$source';
    }
    return ConfigDocument.parse(source);
  }

  final List<_ConfigLine> _lines;
  final List<ConfigEntry> entries;
  final List<ConfigSection> sections;

  /// Full file contents; identical to the input unless an entry was edited.
  String get source => _lines.map((line) => '${line.raw}${line.eol}').join();

  bool get hasChanges => entries.any((entry) => entry.isModified);

  int get changedCount => entries.where((entry) => entry.isModified).length;

  /// Marks every current value as the new baseline (after a successful save).
  void acceptChanges() {
    for (final entry in entries) {
      entry.accept();
    }
  }

  static ConfigSection _addSection(
    List<ConfigSection> sections,
    ConfigSection section,
  ) {
    sections.add(section);
    return section;
  }

  static ConfigValueType _valueType(String value) {
    final text = value.trim();
    if (text == '0' || text == '1') return ConfigValueType.boolean;
    if (int.tryParse(text) != null) return ConfigValueType.integer;
    if (double.tryParse(text) != null) return ConfigValueType.decimal;
    return ConfigValueType.string;
  }

  static bool _isRule(String? text) =>
      text != null && _rulePattern.hasMatch(text);

  /// Collects the comment block directly above an entry and extracts its
  /// `Description:` paragraph.
  static String _descriptionOf(List<_ConfigLine> lines) {
    var index = lines.length - 1;
    while (index >= 0 && lines[index].text.trim().isEmpty) {
      index--;
    }
    final block = <String>[];
    while (index >= 0) {
      final text = lines[index].text.trim();
      if (!text.startsWith('#')) break;
      block.add(_commentText(text));
      index--;
    }
    if (block.isEmpty) return '';

    final texts = block.reversed.toList();
    var start = -1;
    for (var i = 0; i < texts.length; i++) {
      if (texts[i].startsWith('Description:')) {
        start = i;
        break;
      }
    }
    if (start < 0) return '';

    final parts = <String>[];
    for (var i = start; i < texts.length; i++) {
      var text = texts[i];
      if (i == start) {
        text = text.substring('Description:'.length).trim();
      } else if (_labelPattern.hasMatch(text)) {
        break;
      }
      if (text.isEmpty) break;
      parts.add(text);
    }
    return parts.join(' ').trim();
  }

  static String _commentText(String line) {
    final text = line.trim();
    return text.startsWith('#') ? text.substring(1).trim() : text;
  }

  static List<({String text, String eol})> _splitLines(String source) {
    final result = <({String text, String eol})>[];
    var start = 0;
    for (var i = 0; i < source.length; i++) {
      final unit = source.codeUnitAt(i);
      if (unit == 0x0A) {
        final crlf = i > start && source.codeUnitAt(i - 1) == 0x0D;
        final end = crlf ? i - 1 : i;
        result.add((
          text: source.substring(start, end),
          eol: crlf ? '\r\n' : '\n',
        ));
        start = i + 1;
      } else if (unit == 0x0D &&
          (i + 1 == source.length || source.codeUnitAt(i + 1) != 0x0A)) {
        result.add((text: source.substring(start, i), eol: '\r'));
        start = i + 1;
      }
    }
    if (start < source.length) {
      result.add((text: source.substring(start), eol: ''));
    }
    return result;
  }

  static final _rulePattern = RegExp(r'^#{3,}$');
  static final _headingPattern = RegExp(r'^# [A-Z][A-Z0-9 &/()\-.,]*$');
  static final _entryPattern = RegExp(
    r'^(\s*)([A-Za-z_][A-Za-z0-9_.\-]*)(\s*=\s*)(.*?)(\s*)$',
  );
  static final _labelPattern = RegExp(
    r'^(Default|Example|Important|Note|Possible values|Range|Values|Format|'
    r'Accepted values|Limits|Remark|Warning|Usage|Options):',
  );
}

/// A single line, kept with its original line ending.
class _ConfigLine {
  _ConfigLine.text(this.text, this.eol)
    : prefix = null,
      suffix = '',
      _value = null,
      originalValue = null;

  _ConfigLine.entry(this.prefix, String value, this.suffix, this.eol)
    : text = '',
      _value = value,
      originalValue = value;

  final String text;
  final String eol;

  /// Everything up to and including the `=` and its trailing spaces.
  final String? prefix;

  /// Original trailing whitespace after the value.
  final String suffix;

  String? _value;
  String? originalValue;

  bool get isEntry => prefix != null;

  String get value => _value!;

  set value(String value) => _value = value;

  String get raw => isEntry ? '$prefix$_value$suffix' : text;
}
