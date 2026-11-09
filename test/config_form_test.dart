import 'package:arcane_launcher/model/config_document.dart';
import 'package:arcane_launcher/widget/config_form.dart';
import 'package:arcane_launcher/widget/switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ConfigDocument document;
  late int saves;

  setUp(() {
    document = ConfigDocument.parse(
      ['RealmID = 1', 'MaxPingTime = 30', 'DataDir = "data"'].join('\n'),
    );
    saves = 0;
  });

  testWidgets('edits values and persists them through onSave', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConfigForm(
            document: document,
            onSave: () async {
              saves++;
            },
          ),
        ),
      ),
    );

    expect(find.text('RealmID'), findsOneWidget);
    expect(find.text('MaxPingTime'), findsOneWidget);
    expect(find.text('DataDir'), findsOneWidget);
    expect(find.text('No changes'), findsOneWidget);

    await tester.tap(find.byType(ArcaneSwitch));
    await tester.pump();
    expect(document.entries[0].value, '0');
    expect(find.text('1 changed'), findsOneWidget);

    // Search field, then MaxPingTime and DataDir value fields.
    await tester.enterText(find.byType(TextField).at(1), '45');
    await tester.pump();
    expect(document.entries[1].value, '45');
    expect(find.text('2 changed'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();

    expect(saves, 1);
    expect(document.hasChanges, isFalse);
    expect(find.text('No changes'), findsOneWidget);
  });

  testWidgets('filters entries by key or description', (tester) async {
    document = ConfigDocument.parse(
      [
        'RealmID = 1',
        '#',
        '#    MaxPingTime',
        '#        Description: Time between database pings.',
        '',
        'MaxPingTime = 30',
      ].join('\n'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConfigForm(document: document, onSave: () async {}),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'ping');
    await tester.pump();

    expect(find.text('RealmID'), findsNothing);
    expect(find.text('MaxPingTime'), findsOneWidget);
  });
}
