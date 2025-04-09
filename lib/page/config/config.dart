import 'package:arcane_launcher/page/config/component/auth_server.dart';
import 'package:arcane_launcher/page/config/component/world_server.dart';
import 'package:flutter/material.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _SettingState();
}

class _SettingState extends State<ConfigPage> {
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
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;
    final shadow = colorScheme.shadow.withValues(alpha: 0.125);
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
                  onTap: () => handleTap(context),
                ),
                ListTile(
                  leading: const Icon(Icons.sports_esports_outlined),
                  title: const Text('World Server'),
                  selected: selectedIndex == 0,
                  onTap: () => handlePageChanged(0),
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  selected: selectedIndex == 1,
                  title: const Text('Auth Server'),
                  onTap: () => handlePageChanged(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(blurRadius: 16, color: shadow)],
                ),
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                child: switch (selectedIndex) {
                  0 => const WorldServerConfigPage(),
                  1 => const AuthServerConfigPage(),
                  _ => const SizedBox(),
                },
              ),
              itemCount: 2,
              scrollDirection: Axis.vertical,
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void handleTap(BuildContext context) {
    Navigator.of(context).pop();
  }

  void handlePageChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
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
