import 'package:flutter/material.dart';

/// 全局设计 tokens：圆角、间距、布局、阴影、动效。
///
/// 统一设计语言，任何视觉常量只能在此定义，页面不得再手写
/// BoxDecoration / BoxShadow / 魔法数字。
abstract final class Arcane {
  // 圆角
  static const double radiusControl = 4; // 输入框、按钮
  static const double radiusCard = 8; // 卡片、overlay
  static const double radiusTag = 24; // 药丸标签

  // 布局
  static const double sidebarWidth = 320;
  static const double controlHeight = 40; // 服务行高
  static const double buttonHeight = 48; // 开始游戏按钮高
  static const double formLabelWidth = 96;
  static const double pageGap = 16;

  // 阴影（全项目唯一写法）
  static List<BoxShadow> shadow(ColorScheme cs) => [
    BoxShadow(
      blurRadius: 16,
      offset: const Offset(0, 2),
      color: cs.shadow.withValues(alpha: 0.125),
    ),
  ];

  // 控件描边
  static Color border(ColorScheme cs) => cs.shadow.withValues(alpha: 0.125);

  // 动效
  static const Duration duration = Duration(milliseconds: 200);
  static const Curve curve = Curves.easeInOutCubic;

  // 日志区水印（签名元素）
  static TextStyle watermark(ColorScheme cs) => TextStyle(
    color: cs.shadow.withValues(alpha: 0.05),
    fontSize: 120,
    fontWeight: FontWeight.bold,
  );
}
