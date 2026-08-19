import 'package:arcane_launcher/widget/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ArcaneCard 为 ListTile 提供 ink 载体', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArcaneCard(
            child: ListTile(title: const Text('item'), onTap: () {}),
          ),
        ),
      ),
    );

    // debug 模式下若 ListTile 的 ink 效果被背景色遮挡会抛断言，
    // 这里断言构建过程无任何异常。
    expect(tester.takeException(), isNull);
    expect(find.text('item'), findsOneWidget);
  });
}
