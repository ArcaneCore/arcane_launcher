import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:flutter/material.dart';

/// Surface card: color + radius + shadow + padding in one, replacing all
/// hand-written BoxDecoration / BoxShadow combinations.
class ArcaneCard extends StatelessWidget {
  const ArcaneCard({
    super.key,
    this.margin,
    this.padding = const EdgeInsets.all(Arcane.space16),
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
      // Transparent Material acts as the ink host for ListTile etc., so ink
      // splashes are not hidden behind the card background.
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}
