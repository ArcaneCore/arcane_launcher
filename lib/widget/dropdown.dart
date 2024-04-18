import 'package:flutter/material.dart';

class AntDropdown extends StatefulWidget {
  const AntDropdown({
    super.key,
    this.controller,
    this.builder,
    required this.child,
  });

  final AntDropdownController? controller;
  final Widget Function(BuildContext)? builder;
  final Widget child;

  @override
  State<AntDropdown> createState() => AntDropdownState();
}

class AntDropdownState extends State<AntDropdown> {
  LayerLink link = LayerLink();
  OverlayEntry? entry;
  bool active = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(() {
      if (!mounted) return;
      if (widget.controller?.showOverlay == false) {
        removeOverlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: insertOverlay,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AbsorbPointer(
          child: CompositedTransformTarget(link: link, child: widget.child),
        ),
      ),
    );
  }

  void insertOverlay() {
    entry = OverlayEntry(builder: (context) {
      return _AntDropdownOverlay(
        builder: widget.builder,
        link: link,
        onTap: removeOverlay,
      );
    });
    final overlay = Overlay.of(context);
    overlay.insert(entry!);
    setState(() {
      active = !active;
    });
    widget.controller?.showOverlay = true;
  }

  void removeOverlay() {
    entry?.remove();
    setState(() {
      active = !active;
    });
  }
}

class _AntDropdownOverlay extends StatelessWidget {
  const _AntDropdownOverlay({
    super.key,
    this.builder,
    required this.link,
    this.onTap,
  });

  final Widget Function(BuildContext)? builder;
  final LayerLink link;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;
    final shadow = colorScheme.shadow.withOpacity(0.125);
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: handleTap,
          child: Container(color: Colors.transparent),
        ),
        if (builder != null)
          CompositedTransformFollower(
            followerAnchor: Alignment.bottomLeft,
            targetAnchor: Alignment.bottomRight,
            link: link,
            offset: const Offset(16, 0),
            child: Material(
              child: Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(blurRadius: 16, color: shadow)],
                ),
                constraints: const BoxConstraints(
                  maxHeight: 200,
                  maxWidth: 160,
                  minWidth: 160,
                ),
                child: builder?.call(context),
              ),
            ),
          ),
      ],
    );
  }

  void handleTap() {
    onTap?.call();
  }
}

class AntDropdownController extends ChangeNotifier {
  bool showOverlay = false;

  void removeOverlayEntry() {
    showOverlay = false;
    notifyListeners();
  }
}
