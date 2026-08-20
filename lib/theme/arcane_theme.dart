import 'package:flutter/material.dart';

/// Global design tokens: radii, spacing, layout, shadows, motion.
///
/// Unified design language. All visual constants must be defined here;
/// pages must not hand-write BoxDecoration / BoxShadow / magic numbers.
abstract final class Arcane {
  // Radii
  static const double radiusControl = 4; // inputs, buttons
  static const double radiusCard = 8; // cards, overlays
  static const double radiusTag = 24; // pill tags
  static const double radiusPill = 50; // capsule (switch)

  // Layout
  static const double sidebarWidth = 320;
  static const double controlHeight = 40; // service row height
  static const double buttonHeight = 48; // play button height
  static const double formLabelWidth = 96;

  // Spacing scale (single source; never hand-write spacing numbers)
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;

  // Shadows (the only allowed form in the project)
  static List<BoxShadow> shadow(ColorScheme cs) => [
    BoxShadow(
      blurRadius: 16,
      offset: const Offset(0, 2),
      color: cs.shadow.withValues(alpha: 0.125),
    ),
  ];

  // Control border
  static Color border(ColorScheme cs) => cs.shadow.withValues(alpha: 0.125);

  // Motion
  static const Duration duration = Duration(milliseconds: 200);
  static const Curve curve = Curves.easeInOutCubic;

  // Log area watermark (signature element)
  static TextStyle watermark(ColorScheme cs) => TextStyle(
    color: cs.shadow.withValues(alpha: 0.05),
    fontSize: 120,
    fontWeight: FontWeight.bold,
  );
}
