import 'package:flutter/material.dart';

class ArcaneTag extends StatelessWidget {
  const ArcaneTag({super.key, required this.label, this.type = ArcaneTagType.tertiary});

  final String label;
  final ArcaneTagType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final (backgroundColor, foregroundColor) = switch (type) {
      ArcaneTagType.primary => (colorScheme.primary, colorScheme.onPrimary),
      ArcaneTagType.secondary => (colorScheme.secondary, colorScheme.onSecondary),
      ArcaneTagType.tertiary => (
        colorScheme.outlineVariant,
        colorScheme.onSurfaceVariant,
      ),
    };
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Text(
        label,
        style: TextStyle(color: foregroundColor, fontSize: 12),
      ),
    );
  }
}

enum ArcaneTagType { primary, secondary, tertiary }
