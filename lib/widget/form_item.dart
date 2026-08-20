import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:flutter/material.dart';

class ArcaneFormItem extends StatelessWidget {
  const ArcaneFormItem({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Arcane.space16),
      child: Row(
        children: [
          Container(
            alignment: Alignment.centerRight,
            width: Arcane.formLabelWidth,
            child: Text(label, textAlign: TextAlign.end),
          ),
          const SizedBox(width: Arcane.space8),
          Expanded(child: child),
        ],
      ),
    );
  }
}
