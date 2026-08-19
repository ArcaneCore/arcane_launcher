import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:arcane_launcher/widget/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// 主操作按钮组：主按钮（左侧圆角）+ 选项下拉（右侧圆角），中间以细线分隔。
class ArcaneStartButton extends StatefulWidget {
  const ArcaneStartButton({
    super.key,
    required this.onPlay,
    this.loading = false,
    this.playLabel = '开始游戏',
    this.loadingLabel = '正在启动',
    this.optionsBuilder,
  });

  final VoidCallback onPlay;
  final bool loading;
  final String playLabel;
  final String loadingLabel;

  /// 下拉菜单内容，[close] 用于点击菜单项后收起下拉。
  final Widget Function(BuildContext context, VoidCallback close)? optionsBuilder;

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
            final options = widget.optionsBuilder
                ?.call(context, controller.removeOverlayEntry);
            return Column(mainAxisSize: MainAxisSize.min, children: [
              if (options != null) options,
            ]);
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
