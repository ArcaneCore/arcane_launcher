import 'package:arcane_launcher/page/launcher/component/auth_server.dart';
import 'package:arcane_launcher/page/launcher/component/mysqld.dart';
import 'package:arcane_launcher/page/config/config.dart';
import 'package:arcane_launcher/page/setting/setting.dart';
import 'package:arcane_launcher/provider/external_application.dart';
import 'package:arcane_launcher/provider/server.dart';
import 'package:arcane_launcher/schema/external_application.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:arcane_launcher/widget/dropdown.dart';
import 'package:arcane_launcher/widget/service_tile.dart';
import 'package:arcane_launcher/page/launcher/component/world_server.dart';
import 'package:arcane_launcher/provider/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void navigateConfigPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const ConfigPage();
    }));
  }

  void navigateSettingPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const SettingPage();
    }));
  }
}

class _ExternalApplicationTile extends StatelessWidget {
  const _ExternalApplicationTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurface = colorScheme.onSurface.withValues(alpha: 0.25);
    return Consumer(builder: (context, ref, child) {
      final provider = ref.watch(externalApplicationsNotifierProvider);
      final List<ExternalApplication> applications = switch (provider) {
        AsyncData(:final value) => value,
        _ => [],
      };
      if (applications.isEmpty) return const SizedBox();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ServiceTileDivider(label: '外部应用程序'),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return ServiceTile(
                  leading: const Icon(Icons.apps_outlined),
                  name: applications[index].name,
                  trailing: Icon(Icons.open_in_new_outlined, color: onSurface),
                  onChanged: () => handleChanged(ref, index),
                );
              },
              itemCount: applications.length,
            ),
          ),
        ],
      );
    });
  }

  void handleChanged(WidgetRef ref, int index) {
    final provider = ref.read(externalApplicationsNotifierProvider.notifier);
    provider.start(index);
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
    final colorScheme = theme.colorScheme;
    final shadow = colorScheme.shadow.withValues(alpha: 0.125);
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
              Consumer(builder: (context, ref, child) {
                final provider = ref.watch(activeServerNotifierProvider);
                final Server server = switch (provider) {
                  AsyncData(:final value) => value,
                  _ => Server(),
                };
                return Text(server.name);
              }),
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
    entry = OverlayEntry(builder: (context) {
      return _SelectOverlay(link: link, onTap: removeOverlay);
    });
    final overlay = Overlay.of(context);
    overlay.insert(entry!);
    setState(() {
      active = !active;
    });
  }

  void removeOverlay() {
    entry?.remove();
    setState(() {
      active = !active;
    });
  }
}

class _SelectOverlay extends StatelessWidget {
  const _SelectOverlay({required this.link, this.onTap});

  final LayerLink link;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;
    final shadow = colorScheme.shadow.withValues(alpha: 0.125);
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: handleTap,
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
              child: Consumer(builder: (context, ref, child) {
                final provider = ref.watch(serversNotifierProvider);
                final List<Server> servers = switch (provider) {
                  AsyncData(:final value) => value,
                  _ => [],
                };
                return ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(servers[index].name),
                      onTap: () => activeServer(ref, servers[index]),
                    );
                  },
                  itemCount: servers.length,
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  void handleTap() {
    onTap?.call();
  }

  void activeServer(WidgetRef ref, Server server) {
    final notifier = ref.read(serversNotifierProvider.notifier);
    notifier.active(server);
    onTap?.call();
  }
}

class _GameStarter extends StatelessWidget {
  const _GameStarter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;
    final onPrimary = colorScheme.onPrimary;
    final surface = colorScheme.surface;
    return Row(
      children: [
        Expanded(
          child: Consumer(builder: (context, ref, child) {
            final provider = ref.watch(gameNotifierProvider);
            final loading = switch (provider) {
              AsyncData(:final value) => value,
              _ => true,
            };
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
              onPressed: () => start(ref),
              child: Container(
                alignment: Alignment.center,
                height: 48,
                child: Text(loading ? '正在启动' : '开始游戏'),
              ),
            );
          }),
        ),
        Container(color: surface, height: 48, width: 0.5),
        const _GameOption(),
      ],
    );
  }

  void start(WidgetRef ref) async {
    final loading = await ref.read(gameNotifierProvider.future);
    if (loading) return;
    final notifier = ref.read(gameNotifierProvider.notifier);
    notifier.start();
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
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;
    final onPrimary = colorScheme.onPrimary;
    final surface = colorScheme.surface;
    return AntDropdown(
      builder: (context) {
        return Consumer(builder: (context, ref, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('启动所有服务'),
                onTap: () => startServices(ref),
              ),
              ListTile(
                title: const Text('关闭所有服务'),
                onTap: () => stopServices(ref),
              ),
              const Divider(),
              ListTile(
                title: const Text('启动客户端'),
                onTap: () => startClient(ref),
              ),
            ],
          );
        });
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

  void startServices(WidgetRef ref) async {
    final notifier = ref.read(gameNotifierProvider.notifier);
    notifier.startServices();
    controller.removeOverlayEntry();
  }

  void stopServices(WidgetRef ref) async {
    final notifier = ref.read(gameNotifierProvider.notifier);
    notifier.stopServices();
    controller.removeOverlayEntry();
  }

  void startClient(WidgetRef ref) async {
    final notifier = ref.read(gameNotifierProvider.notifier);
    notifier.startClient();
    controller.removeOverlayEntry();
  }
}
