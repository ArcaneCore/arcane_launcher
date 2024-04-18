import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  const Tag({super.key, required this.label, this.type = TagType.tertiary});

  final String label;
  final TagType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = switch (type) {
      TagType.primary => colorScheme.primary,
      TagType.secondary => colorScheme.secondary,
      TagType.tertiary => colorScheme.outlineVariant,
    };
    final foregroundColor = colorScheme.onPrimary;
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
