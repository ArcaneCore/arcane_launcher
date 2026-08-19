import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:arcane_launcher/widget/card.dart';
import 'package:flutter/material.dart';

/// 页面骨架：左侧 [sidebarWidth] 卡片 + 右侧内容区，launcher / config / setting 共用。
class ArcanePageLayout extends StatelessWidget {
  const ArcanePageLayout({super.key, required this.sidebar, required this.content});

  final Widget sidebar;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ArcaneCard(
          margin: const EdgeInsets.all(Arcane.pageGap),
          width: Arcane.sidebarWidth,
          child: sidebar,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(Arcane.pageGap),
            child: content,
          ),
        ),
      ],
    );
  }
}
