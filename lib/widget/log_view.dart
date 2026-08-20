import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:arcane_launcher/widget/card.dart';
import 'package:flutter/material.dart';

/// Service log card: a faint service-name watermark (signature element) plus
/// a reversed log list.
class ArcaneLogView extends StatelessWidget {
  const ArcaneLogView({super.key, required this.watermark, required this.logs});

  final String watermark;
  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ArcaneCard(
      child: Stack(
        children: [
          Center(
            child: Text(
              watermark,
              maxLines: 1,
              style: Arcane.watermark(
                cs,
              ).copyWith(overflow: TextOverflow.ellipsis),
            ),
          ),
          ListView.builder(
            reverse: true,
            itemCount: logs.length,
            itemBuilder:
                (context, index) => Text(logs[logs.length - 1 - index]),
          ),
        ],
      ),
    );
  }
}
