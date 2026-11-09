import 'dart:convert';

import 'package:arcane_launcher/model/config_document.dart';
import 'package:flutter_test/flutter_test.dart';

const _lines = <String>[
  '\uFEFF############################################',
  '# Sample configuration file',
  '############################################',
  '[worldserver]',
  '',
  '###################################################################################################',
  '# DATABASE & CONNECTIONS',
  '#',
  '#    RealmID',
  '#        Description: ID of the Realm using this config.',
  '#        Default:     1',
  '',
  'RealmID = 1',
  '',
  '#',
  '#    MaxPingTime',
  '#        Description: Time (in minutes) between database pings.',
  '#        Default:     30',
  '',
  'MaxPingTime = 30',
  '',
  '#',
  '#    DataDir',
  '#        Description: Data directory setting.',
  '#        Important:   DataDir needs to be quoted, as the string might contain space characters.',
  '',
  'DataDir = "data"',
];

final _sample = '${_lines.join('\r\n')}\r\n';

void main() {
  test('round-trips an untouched document', () {
    final document = ConfigDocument.parse(_sample);

    expect(document.source, _sample);
    expect(document.hasChanges, isFalse);
  });

  test('parses entries, sections, descriptions and types', () {
    final document = ConfigDocument.parse(_sample);

    expect(document.entries.map((entry) => entry.key), [
      'RealmID',
      'MaxPingTime',
      'DataDir',
    ]);
    expect(document.entries[0].type, ConfigValueType.boolean);
    expect(document.entries[1].type, ConfigValueType.integer);
    expect(document.entries[2].type, ConfigValueType.string);
    expect(
      document.entries[0].description,
      'ID of the Realm using this config.',
    );
    expect(document.entries[2].description, 'Data directory setting.');
    expect(document.entries[2].section, 'DATABASE & CONNECTIONS');
    expect(
      document.sections
          .where((section) => section.entries.isNotEmpty)
          .map((section) => section.title),
      ['DATABASE & CONNECTIONS'],
    );
  });

  test('editing only rewrites the edited values', () {
    final document = ConfigDocument.parse(_sample);

    document.entries[0].boolValue = false;
    document.entries[1].updateDisplayValue('45');
    document.entries[2].updateDisplayValue('/srv/data');

    final expected = _sample
        .replaceFirst('RealmID = 1\r\n', 'RealmID = 0\r\n')
        .replaceFirst('MaxPingTime = 30\r\n', 'MaxPingTime = 45\r\n')
        .replaceFirst('DataDir = "data"\r\n', 'DataDir = "/srv/data"\r\n');

    expect(document.source, expected);
    expect(document.changedCount, 3);
    expect(document.hasChanges, isTrue);
  });

  test('acceptChanges resets the baseline after saving', () {
    final document = ConfigDocument.parse(_sample);

    document.entries[0].boolValue = false;
    document.acceptChanges();

    expect(document.hasChanges, isFalse);
    expect(document.entries[0].value, '0');
    expect(document.entries[0].displayValue, '0');
  });

  test('quoted strings stay quoted while editing', () {
    final document = ConfigDocument.parse(_sample);

    expect(document.entries[2].displayValue, 'data');
    document.entries[2].updateDisplayValue('new');
    expect(document.entries[2].value, '"new"');
  });

  test('keeps LF line endings', () {
    final source = _lines.join('\n');
    final document = ConfigDocument.parse(source);

    expect(document.entries, hasLength(3));
    expect(document.source, source);
  });

  test('parseBytes keeps the UTF-8 BOM', () {
    final bytes = utf8.encode(_sample);
    final document = ConfigDocument.parseBytes(bytes);

    expect(document.source, _sample);
    expect(utf8.encode(document.source), bytes);
  });
}
