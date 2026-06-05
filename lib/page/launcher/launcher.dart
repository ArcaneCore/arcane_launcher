import 'package:arcane_launcher/di.dart';
import 'package:arcane_launcher/page/launcher/component/auth_server.dart';
import 'package:arcane_launcher/page/launcher/component/mysqld.dart';
import 'package:arcane_launcher/page/config/config.dart';
import 'package:arcane_launcher/page/setting/setting.dart';
import 'package:arcane_launcher/page/launcher/component/world_server.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:arcane_launcher/viewmodel/external_application_view_model.dart';
import 'package:arcane_launcher/viewmodel/game_view_model.dart';
import 'package:arcane_launcher/viewmodel/server_view_model.dart';
import 'package:arcane_launcher/widget/dropdown.dart';
import 'package:arcane_launcher/widget/service_tile.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class LauncherPage extends StatelessWidget {
  const LauncherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;
    final shadow = colorScheme.shadow.withValues(alpha: 0.125);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(blurRadius: 16, color: shadow)],
              ),
              padding: const EdgeInsets.all(16),
              width: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('asset/world-of-warcraft.png', fit: BoxFit.cover),
                  const ServiceTileDivider(label: '核心服务'),
                  const MysqldTile(),
                  const WorldServerTile(),
                  const AuthServerTile(),
                  const ServiceTileDivider(label: '设置'),
                  ServiceTile(
                    leading: const Icon(Icons.toggle_on_outlined),
                    name: '模拟器配置',
                    trailing: const SizedBox(),
                    onChanged: () => navigateConfigPage(context),
                  ),
                  ServiceTile(
                    leading: const Icon(Icons.settings_outlined),
                    name: '设置',
                    trailing: const SizedBox(),
                    onChanged: () => navigateSettingPage(context),
                  ),
                  const Expanded(child: _ExternalApplicationTile()),
                  const SizedBox(height: 8),
                  const Text('服务器'),
                  const SizedBox(height: 8),
                  const _ServerSelect(),
                  const SizedBox(height: 8),
                  const _GameStarter(),
                ],
              ),
            ),
            const SizedBox(width: 32),
            const Expanded(
              child: Column(
                children: [
                  Expanded(child: MysqldLog()),
                  SizedBox(height: 16),
                  Expanded(child: WorldServerLog()),
                  SizedBox(height: 16),
                  Expanded(child: AuthServerLog()),
                ],
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
        final vm = getIt<ExternalApplicationViewModel>();
        final apps = vm.applications;
        if (apps.isEmpty) return const SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ServiceTileDivider(label: '外部应用程序'),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ServiceTile(
                    leading: const Icon(Icons.apps_outlined),
                    name: apps[index].name,
                    trailing: Icon(
                      Icons.open_in_new_outlined,
                      color: onSurface,
                    ),
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
  LayerLink link = LayerLink();
  OverlayEntry? entry;
  bool active = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shadow = theme.colorScheme.shadow.withValues(alpha: 0.125);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: insertOverlay,
      child: CompositedTransformTarget(
        link: link,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: shadow),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              SignalBuilder(
                builder: (context) {
                  return Text(getIt<ServerViewModel>().activeServer.name);
                },
              ),
              const Spacer(),
              AnimatedRotation(
                turns: active ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_more_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void insertOverlay() {
    entry = OverlayEntry(
      builder: (context) => _SelectOverlay(link: link, onTap: removeOverlay),
    );
    Overlay.of(context).insert(entry!);
    setState(() => active = !active);
  }

  void removeOverlay() {
    entry?.remove();
    setState(() => active = !active);
  }
}

class _SelectOverlay extends StatelessWidget {
  const _SelectOverlay({required this.link, this.onTap});

  final LayerLink link;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final shadow = theme.colorScheme.shadow.withValues(alpha: 0.125);
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap?.call(),
          child: Container(color: Colors.transparent),
        ),
        CompositedTransformFollower(
          followerAnchor: Alignment.bottomCenter,
          targetAnchor: Alignment.topCenter,
          link: link,
          offset: const Offset(0, -16),
          child: Material(
            child: Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(blurRadius: 16, color: shadow)],
              ),
              width: 288,
              height: 200,
              child: SignalBuilder(
                builder: (context) {
                  final list = getIt<ServerViewModel>().servers;
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(list[index].name),
                        onTap: () => selectServer(list[index]),
                      );
                    },
                    itemCount: list.length,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void selectServer(Server server) {
    getIt<ServerViewModel>().activate(server);
    onTap?.call();
  }
}

class _GameStarter extends StatelessWidget {
  const _GameStarter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final surface = theme.colorScheme.surface;
    return Row(
      children: [
        Expanded(
          child: SignalBuilder(
            builder: (context) {
              final loading = getIt<GameViewModel>().loading;
              return ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(primary),
                  foregroundColor: WidgetStatePropertyAll(onPrimary),
                  surfaceTintColor: WidgetStatePropertyAll(surface),
                  shape: const WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        topLeft: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  if (loading) return;
                  getIt<GameViewModel>().startGame();
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 48,
                  child: Text(loading ? '正在启动' : '开始游戏'),
                ),
              );
            },
          ),
        ),
        Container(color: surface, height: 48, width: 0.5),
        const _GameOption(),
      ],
    );
  }
}

class _GameOption extends StatefulWidget {
  const _GameOption();

  @override
  State<_GameOption> createState() => __GameOptionState();
}

class __GameOptionState extends State<_GameOption> {
  AntDropdownController controller = AntDropdownController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final surface = theme.colorScheme.surface;
    return ArcaneDropdown(
      builder: (context) {
        final gameVM = getIt<GameViewModel>();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('启动所有服务'),
              onTap: () {
                gameVM.startServices();
                controller.removeOverlayEntry();
              },
            ),
            ListTile(
              title: const Text('关闭所有服务'),
              onTap: () {
                gameVM.stopServices();
                controller.removeOverlayEntry();
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('启动客户端'),
              onTap: () {
                gameVM.startClient();
                controller.removeOverlayEntry();
              },
            ),
          ],
        );
      },
      controller: controller,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(primary),
          foregroundColor: WidgetStatePropertyAll(onPrimary),
          surfaceTintColor: WidgetStatePropertyAll(surface),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ),
        ),
        onPressed: () {},
        child: Container(
          alignment: Alignment.center,
          height: 48,
          child: const Icon(Icons.more_horiz_outlined),
        ),
      ),
    );
  }
}
