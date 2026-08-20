import 'package:arcane_launcher/di.dart';
import 'package:arcane_launcher/page/launcher/component/auth_server.dart';
import 'package:arcane_launcher/page/launcher/component/mysqld.dart';
import 'package:arcane_launcher/page/config/config.dart';
import 'package:arcane_launcher/page/setting/setting.dart';
import 'package:arcane_launcher/page/launcher/component/world_server.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:arcane_launcher/view_model/auth_server_view_model.dart';
import 'package:arcane_launcher/view_model/application_view_model.dart';
import 'package:arcane_launcher/view_model/game_view_model.dart';
import 'package:arcane_launcher/view_model/mysqld_view_model.dart';
import 'package:arcane_launcher/view_model/server_view_model.dart';
import 'package:arcane_launcher/view_model/world_server_view_model.dart';
import 'package:arcane_launcher/widget/dropdown.dart';
import 'package:arcane_launcher/widget/log_view.dart';
import 'package:arcane_launcher/widget/page_layout.dart';
import 'package:arcane_launcher/widget/service_tile.dart';
import 'package:arcane_launcher/widget/start_button.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:signals/signals_flutter.dart';

class LauncherPage extends StatelessWidget {
  const LauncherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ArcanePageLayout(
        sidebar: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('asset/world-of-warcraft.png', fit: BoxFit.cover),
            const ServiceTileDivider(label: 'Core Services'),
            const MysqldTile(),
            const WorldServerTile(),
            const AuthServerTile(),
            const ServiceTileDivider(label: 'Settings'),
            ServiceTile(
              leading: const Icon(LucideIcons.toggleRight),
              name: 'Emulator Config',
              trailing: const SizedBox(),
              onChanged: () => navigateConfigPage(context),
            ),
            ServiceTile(
              leading: const Icon(LucideIcons.settings),
              name: 'Settings',
              trailing: const SizedBox(),
              onChanged: () => navigateSettingPage(context),
            ),
            const Expanded(child: _ExternalApplicationTile()),
            const ServiceTileDivider(label: 'Servers'),
            const _ServerSelect(),
            const SizedBox(height: Arcane.space8),
            _GameStarter(),
          ],
        ),
        content: Column(
          children: [
            Expanded(
              child: SignalBuilder(
                builder: (context) {
                  return ArcaneLogView(
                    watermark: 'MYSQLD',
                    logs: getIt<MysqldViewModel>().info.logs,
                  );
                },
              ),
            ),
            const SizedBox(height: Arcane.space16),
            Expanded(
              child: SignalBuilder(
                builder: (context) {
                  return ArcaneLogView(
                    watermark: 'WORLD SERVER',
                    logs: getIt<WorldServerViewModel>().info.logs,
                  );
                },
              ),
            ),
            const SizedBox(height: Arcane.space16),
            Expanded(
              child: SignalBuilder(
                builder: (context) {
                  return ArcaneLogView(
                    watermark: 'AUTH SERVER',
                    logs: getIt<AuthServerViewModel>().info.logs,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateConfigPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ConfigPage()));
  }

  void navigateSettingPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingPage()));
  }
}

class _ExternalApplicationTile extends StatelessWidget {
  const _ExternalApplicationTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface.withValues(alpha: 0.25);
    return SignalBuilder(
      builder: (context) {
        final vm = getIt<ApplicationViewModel>();
        final apps = vm.applications;
        if (apps.isEmpty) return const SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ServiceTileDivider(label: 'External Applications'),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ServiceTile(
                    leading: const Icon(LucideIcons.blocks),
                    name: apps[index].name,
                    trailing: Icon(LucideIcons.externalLink, color: onSurface),
                    onChanged: () => vm.start(index),
                  );
                },
                itemCount: apps.length,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ServerSelect extends StatefulWidget {
  const _ServerSelect();

  @override
  State<_ServerSelect> createState() => _ServerSelectState();
}

class _ServerSelectState extends State<_ServerSelect> {
  final controller = ArcaneDropdownController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ArcaneDropdown(
      controller: controller,
      width: 288,
      builder: (context) {
        return SignalBuilder(
          builder: (context) {
            final list = getIt<ServerViewModel>().servers;
            return ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(list[index].name),
                  onTap: () => selectServer(list[index]),
                );
              },
              itemCount: list.length,
            );
          },
        );
      },
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Arcane.border(cs)),
              borderRadius: BorderRadius.circular(Arcane.radiusControl),
            ),
            padding: const EdgeInsets.all(Arcane.space8),
            child: Row(
              children: [
                SignalBuilder(
                  builder: (context) {
                    return Text(getIt<ServerViewModel>().activeServer.name);
                  },
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: controller.showOverlay ? 0.5 : 0,
                  duration: Arcane.duration,
                  child: const Icon(LucideIcons.chevronDown),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void selectServer(ServerEntity server) {
    getIt<ServerViewModel>().activate(server);
    controller.removeOverlayEntry();
  }
}

class _GameStarter extends StatelessWidget {
  const _GameStarter();

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final gameVM = getIt<GameViewModel>();
        return ArcaneStartButton(
          onPlay: gameVM.startGame,
          loading: gameVM.loading,
          optionsBuilder: (context, close) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Start All Services'),
                onTap: () {
                  gameVM.startServices();
                  close();
                },
              ),
              ListTile(
                title: const Text('Stop All Services'),
                onTap: () {
                  gameVM.stopServices();
                  close();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Launch Client'),
                onTap: () {
                  gameVM.startClient();
                  close();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
