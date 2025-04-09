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
    var text = name;
    if (processIds.isNotEmpty) {
      text = '$text ${processIds.toString()}';
    }
    final defaultTrailing = AntSwitch(
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
          height: 40,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 8),
              ],
              Text(text),
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
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Text(label, style: TextStyle(color: onSurface)),
    );
  }
}
