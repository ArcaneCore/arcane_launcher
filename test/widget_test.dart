import 'package:arcane_launcher/widget/card.dart';
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
}
