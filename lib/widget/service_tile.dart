import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:arcane_launcher/widget/switch.dart';
import 'package:flutter/material.dart';

class ServiceTile extends StatelessWidget {
  const ServiceTile({
    super.key,
    this.active = false,
    this.leading,
    this.loading = false,
    required this.name,
    this.processIds = const [],
    this.trailing,
    this.onChanged,
  });

  final bool active;
  final Widget? leading;
  final bool loading;
  final String name;
  final List<int> processIds;
  final Widget? trailing;
  final void Function()? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final defaultTrailing = ArcaneSwitch(
      loading: loading,
      value: active,
      onChanged: handleChange,
    );
    var cursor = SystemMouseCursors.click;
    if (loading) {
      cursor = SystemMouseCursors.forbidden;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: handleTap,
      child: MouseRegion(
        cursor: cursor,
        child: Container(
          alignment: Alignment.center,
          height: Arcane.controlHeight,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: Arcane.space8),
              ],
              Text(name),
              if (processIds.isNotEmpty) ...[
                const SizedBox(width: Arcane.space8),
                Text(
                  processIds.join(', '),
                  style: TextStyle(color: onSurface, fontSize: 12),
                ),
              ],
              const Spacer(),
              trailing ?? defaultTrailing,
            ],
          ),
        ),
      ),
    );
  }

  void handleChange(bool value) {
    onChanged?.call();
  }

  void handleTap() {
    if (loading) return;
    onChanged?.call();
  }
}

class ServiceTileDivider extends StatelessWidget {
  const ServiceTileDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurface = colorScheme.onSurface.withValues(alpha: 0.5);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Arcane.space32,
        vertical: Arcane.space8,
      ),
      child: Text(label, style: TextStyle(color: onSurface)),
    );
  }
}
