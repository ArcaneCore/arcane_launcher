import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Confirmation dialog: shared radius and Cancel / Confirm button layout.
class ArcaneConfirmDialog extends StatelessWidget {
  const ArcaneConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  final String title;
  final String content;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Arcane.radiusCard),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await onConfirm();
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

/// Form dialog: shared header (title + close button), radius, and width.
class ArcaneFormDialog extends StatelessWidget {
  const ArcaneFormDialog({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Arcane.radiusCard),
      ),
      child: Container(
        padding: const EdgeInsets.all(Arcane.space16),
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
            const SizedBox(height: Arcane.space16),
            Flexible(child: SingleChildScrollView(child: child)),
          ],
        ),
      ),
    );
  }
}
