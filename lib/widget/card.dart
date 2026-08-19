import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:flutter/material.dart';

/// 表面卡片：颜色 + 圆角 + 阴影 + 内边距一体，替换所有手写的
/// BoxDecoration / BoxShadow 组合。
class ArcaneCard extends StatelessWidget {
  const ArcaneCard({
    super.key,
    this.margin,
    this.padding = const EdgeInsets.all(16),
    this.width,
    required this.child,
  });

  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final double? width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      padding: padding,
      width: width,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(Arcane.radiusCard),
        boxShadow: Arcane.shadow(cs),
      ),
      // 透明的 Material 作为 ListTile 等控件的 ink 载体，
      // 避免 ink 溅射被卡片的背景色遮挡。
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}
