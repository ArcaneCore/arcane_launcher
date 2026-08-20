import 'package:arcane_launcher/di.dart';
import 'package:arcane_launcher/page/setting/component/application.dart';
import 'package:arcane_launcher/page/setting/component/server.dart';
import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:arcane_launcher/view_model/setting_view_model.dart';
import 'package:arcane_launcher/widget/card.dart';
import 'package:arcane_launcher/widget/page_layout.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:signals/signals_flutter.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingState();
}

class _SettingState extends State<SettingPage> {
  int selectedIndex = 0;
  PageController controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ArcanePageLayout(
        sidebar: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.arrowLeft),
              title: const Text('Back'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(LucideIcons.server),
              title: const Text('Servers'),
              selected: selectedIndex == 0,
              onTap: () => handlePageChanged(0),
            ),
            ListTile(
              leading: const Icon(LucideIcons.blocks),
              selected: selectedIndex == 1,
              title: const Text('External Apps'),
              onTap: () => handlePageChanged(1),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(LucideIcons.info),
              title: const Text('About'),
              onTap: () => showAbout(context),
            ),
            const Spacer(),
            const _ThemeTile(),
          ],
        ),
        content: PageView.builder(
          controller: controller,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder:
              (context, index) => ArcaneCard(
                child: switch (selectedIndex) {
                  0 => const ServersPage(),
                  1 => const ApplicationsPage(),
                  _ => const SizedBox(),
                },
              ),
          itemCount: 2,
          scrollDirection: Axis.vertical,
        ),
      ),
    );
  }

  void handlePageChanged(int index) {
    setState(() => selectedIndex = index);
    controller.animateToPage(
      index,
      duration: Arcane.duration,
      curve: Arcane.curve,
    );
  }

  void showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Arcane Launcher',
      applicationVersion: '1.0.0+1',
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final theme = Theme.of(context);
        final onPrimary = theme.colorScheme.onPrimary;
        final vm = getIt<SettingViewModel>();
        final s = vm.setting;
        final iconData = s.darkMode ? LucideIcons.sun : LucideIcons.moon;
        return Wrap(
          runSpacing: Arcane.space8,
          spacing: Arcane.space8,
          children: [
            ...List.generate(Colors.primaries.length, (index) {
              final color = Colors.primaries[index];
              final bg = WidgetStatePropertyAll(color);
              Widget icon = Icon(LucideIcons.check, color: onPrimary);
              if (color.toARGB32() != s.color) {
                icon = const SizedBox();
              }
              return IconButton(
                icon: icon,
                onPressed: () => vm.updateColor(color.toARGB32()),
                style: ButtonStyle(backgroundColor: bg),
              );
            }),
            IconButton(
              onPressed: () => vm.toggleBrightness(),
              icon: Icon(iconData),
            ),
          ],
        );
      },
    );
  }
}
