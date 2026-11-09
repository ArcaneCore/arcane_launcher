import 'package:arcane_launcher/widget/card.dart';
import 'package:arcane_launcher/widget/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ArcaneCard provides an ink host for ListTile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArcaneCard(
            child: ListTile(title: const Text('item'), onTap: () {}),
          ),
        ),
      ),
    );

    // In debug mode Flutter asserts when ListTile ink is hidden behind a
    // background, so this just asserts the build completes without exceptions.
    expect(tester.takeException(), isNull);
    expect(find.text('item'), findsOneWidget);
  });

  testWidgets('ArcaneDropdown overlay provides an ink host for ListTile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ArcaneDropdown(
              builder:
                  (context) =>
                      ListTile(title: const Text('item'), onTap: () {}),
              child: const SizedBox(
                width: 120,
                height: 40,
                child: Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    // The dropdown wraps its child in AbsorbPointer, so the text itself is
    // "missed" by hit testing even though the tap reaches the GestureDetector.
    await tester.tap(find.text('open'), warnIfMissed: false);
    await tester.pump();

    // The overlay paints behind the ListTile's ink host without hiding it.
    expect(tester.takeException(), isNull);
    expect(find.text('item'), findsOneWidget);
  });
}
