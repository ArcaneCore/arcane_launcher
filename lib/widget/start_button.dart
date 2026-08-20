import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:arcane_launcher/widget/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Primary action button group: main button (left radius) + options dropdown
/// (right radius), separated by a hairline.
class ArcaneStartButton extends StatefulWidget {
  const ArcaneStartButton({
    super.key,
    required this.onPlay,
    this.loading = false,
    this.playLabel = 'Play',
    this.loadingLabel = 'Starting...',
    this.optionsBuilder,
  });

  final VoidCallback onPlay;
  final bool loading;
  final String playLabel;
  final String loadingLabel;

  /// Dropdown menu content; [close] collapses the menu after an item is tapped.
  final Widget Function(BuildContext context, VoidCallback close)?
  optionsBuilder;

  @override
  State<ArcaneStartButton> createState() => _ArcaneStartButtonState();
}

class _ArcaneStartButtonState extends State<ArcaneStartButton> {
  final controller = ArcaneDropdownController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(cs.primary),
              foregroundColor: WidgetStatePropertyAll(cs.onPrimary),
              surfaceTintColor: WidgetStatePropertyAll(cs.surface),
              shape: const WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(Arcane.radiusControl),
                    topLeft: Radius.circular(Arcane.radiusControl),
                  ),
                ),
              ),
            ),
            onPressed: () {
              if (widget.loading) return;
              widget.onPlay();
            },
            child: Container(
              alignment: Alignment.center,
              height: Arcane.buttonHeight,
              child: Text(
                widget.loading ? widget.loadingLabel : widget.playLabel,
              ),
            ),
          ),
        ),
        Container(color: cs.surface, height: Arcane.buttonHeight, width: 0.5),
        ArcaneDropdown(
          controller: controller,
          builder: (context) {
            final options = widget.optionsBuilder?.call(
              context,
              controller.removeOverlayEntry,
            );
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [if (options != null) options],
            );
          },
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(cs.primary),
              foregroundColor: WidgetStatePropertyAll(cs.onPrimary),
              surfaceTintColor: WidgetStatePropertyAll(cs.surface),
              shape: const WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(Arcane.radiusControl),
                    topRight: Radius.circular(Arcane.radiusControl),
                  ),
                ),
              ),
            ),
            onPressed: () {},
            child: Container(
              alignment: Alignment.center,
              height: Arcane.buttonHeight,
              child: const Icon(LucideIcons.ellipsis),
            ),
          ),
        ),
      ],
    );
  }
}
