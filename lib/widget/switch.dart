import 'dart:math';

import 'package:flutter/material.dart';

class AntSwitch extends StatelessWidget {
  const AntSwitch({
    super.key,
    this.loading = false,
    required this.value,
    required this.onChanged,
  });

  final bool loading;
  final bool value;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;
    var surfaceVariant = colorScheme.surfaceVariant;
    var primary = colorScheme.primary;
    var cursor = SystemMouseCursors.click;
    if (loading) {
      cursor = SystemMouseCursors.forbidden;
      surfaceVariant = surfaceVariant.withOpacity(0.5);
      primary = primary.withOpacity(0.5);
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: handleTap,
      child: MouseRegion(
        cursor: cursor,
        child: AnimatedContainer(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          width: 52,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: value ? primary : surfaceVariant,
          ),
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(2),
          child: UnconstrainedBox(
            child: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: surface,
                shape: BoxShape.circle,
              ),
              child: loading ? const _AntSwitchLoadingIndicator() : null,
            ),
          ),
        ),
      ),
    );
  }

  void handleTap() {
    if (loading) return;
    onChanged?.call(!value);
  }
}

class _AntSwitchLoadingIndicator extends StatefulWidget {
  const _AntSwitchLoadingIndicator({super.key});

  @override
  State<_AntSwitchLoadingIndicator> createState() =>
      __AntSwitchLoadingIndicatorState();
}

class __AntSwitchLoadingIndicatorState extends State<_AntSwitchLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;
    return UnconstrainedBox(
      child: SizedBox(
        height: 18,
        width: 18,
        child: AnimatedBuilder(
          animation: Tween(begin: 0.0, end: 1).animate(controller),
          builder: (context, child) {
            return CustomPaint(
              painter: _AntSwitchLoadingIndicatorPainter(
                color: primary,
                startAngle: controller.value * pi * 2,
              ),
              size: const Size(18, 18),
            );
          },
        ),
      ),
    );
  }
}

class _AntSwitchLoadingIndicatorPainter extends CustomPainter {
  _AntSwitchLoadingIndicatorPainter({
    required this.color,
    required this.startAngle,
  });
  final Color color;
  final double startAngle;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, startAngle, pi / 2, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
