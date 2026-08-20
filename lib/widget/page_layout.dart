import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:arcane_launcher/widget/card.dart';
import 'package:flutter/material.dart';

/// Page skeleton: [sidebarWidth] card on the left, content on the right;
/// shared by launcher / config / setting pages.
class ArcanePageLayout extends StatelessWidget {
  const ArcanePageLayout({
    super.key,
    required this.sidebar,
    required this.content,
  });

  final Widget sidebar;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ArcaneCard(
          margin: const EdgeInsets.all(Arcane.space16),
          width: Arcane.sidebarWidth,
          child: sidebar,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(Arcane.space16),
            child: content,
          ),
        ),
      ],
    );
  }
}
