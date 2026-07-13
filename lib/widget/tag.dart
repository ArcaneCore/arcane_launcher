import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  const Tag({super.key, required this.label, this.type = TagType.tertiary});

  final String label;
  final TagType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final (backgroundColor, foregroundColor) = switch (type) {
      TagType.primary => (colorScheme.primary, colorScheme.onPrimary),
      TagType.secondary => (colorScheme.secondary, colorScheme.onSecondary),
      TagType.tertiary => (colorScheme.outlineVariant, colorScheme.onSurfaceVariant),
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

enum TagType { primary, secondary, tertiary }
