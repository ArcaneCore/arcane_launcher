import 'package:arcane_launcher/di.dart';
import 'package:arcane_launcher/page/setting/component/external_application.dart';
import 'package:arcane_launcher/page/setting/component/server.dart';
import 'package:arcane_launcher/viewmodel/setting_view_model.dart';
import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final shadow = theme.colorScheme.shadow.withValues(alpha: 0.125);
    return Scaffold(
      body: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(blurRadius: 16, color: shadow)],
            ),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.arrow_back_outlined),
                  title: const Text('返回'),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.dns_outlined),
                  title: const Text('服务器'),
                  selected: selectedIndex == 0,
                  onTap: () => handlePageChanged(0),
                ),
                ListTile(
                  leading: const Icon(Icons.apps_outlined),
                  selected: selectedIndex == 1,
                  title: const Text('外部应用'),
                  onTap: () => handlePageChanged(1),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outlined),
                  title: const Text('关于'),
                  onTap: () => showAbout(context),
                ),
                const Spacer(),
                const _ThemeTile(),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder:
                  (context, index) => Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(blurRadius: 16, color: shadow)],
                    ),
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    child: switch (selectedIndex) {
                      0 => const ServersPage(),
                      1 => const ExternalApplicationsPage(),
                      _ => const SizedBox(),
                    },
                  ),
              itemCount: 2,
              scrollDirection: Axis.vertical,
            ),
          ),
        ],
      ),
    );
  }

  void handlePageChanged(int index) {
    setState(() => selectedIndex = index);
    controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.bounceInOut,
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
        final iconData =
            s.darkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined;
        return Wrap(
          runSpacing: 8,
          spacing: 8,
          children: [
            ...List.generate(Colors.primaries.length, (index) {
              final color = Colors.primaries[index];
              final bg = WidgetStatePropertyAll(color);
              Widget icon = Icon(Icons.check_outlined, color: onPrimary);
              if (color.value != s.color) {
                icon = const SizedBox();
              }
              return IconButton(
                icon: icon,
                onPressed: () => vm.updateColor(color.value),
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
