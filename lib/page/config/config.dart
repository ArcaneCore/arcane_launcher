import 'package:arcane_launcher/page/config/component/auth_server.dart';
import 'package:arcane_launcher/page/config/component/world_server.dart';
import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:arcane_launcher/widget/card.dart';
import 'package:arcane_launcher/widget/page_layout.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
              leading: const Icon(LucideIcons.gamepad2),
              title: const Text('World Server'),
              selected: selectedIndex == 0,
              onTap: () => handlePageChanged(0),
            ),
            ListTile(
              leading: const Icon(LucideIcons.user),
              selected: selectedIndex == 1,
              title: const Text('Auth Server'),
              onTap: () => handlePageChanged(1),
            ),
          ],
        ),
        content: PageView.builder(
          controller: controller,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder:
              (context, index) => ArcaneCard(
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
    );
  }

  void handlePageChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
    controller.animateToPage(
      index,
      duration: Arcane.duration,
      curve: Arcane.curve,
    );
  }
}
