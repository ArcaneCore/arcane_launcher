import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/widget/service_tile.dart';
import 'package:arcane_launcher/provider/world_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorldServerTile extends StatelessWidget {
  const WorldServerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final provider = ref.watch(worldServerInformationNotifierProvider);
      final List<int> processIds = switch (provider) {
        AsyncData(:final value) => value.processIds,
        _ => []
      };
      final status = switch (provider) {
        AsyncData(:final value) => value.status,
        _ => ServiceStatus.stopped
      };
      return ServiceTile(
        active: status != ServiceStatus.stopped,
        leading: const Icon(Icons.sports_esports_outlined),
        loading: status == ServiceStatus.starting,
        name: 'World Server',
        processIds: processIds,
        onChanged: () => toggleWorldServerService(ref),
      );
    });
  }

  void toggleWorldServerService(WidgetRef ref) {
    final notifier = ref.read(worldServerInformationNotifierProvider.notifier);
    notifier.toggle();
  }
}

class WorldServerLog extends StatelessWidget {
  const WorldServerLog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;
    final shadow = colorScheme.shadow.withOpacity(0.125);
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(blurRadius: 16, color: shadow)],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Center(
            child: Text(
              'WORLD SERVER',
              maxLines: 1,
              style: TextStyle(
                color: shadow.withOpacity(0.05),
                fontSize: 120,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Consumer(builder: (context, ref, child) {
            final provider = ref.watch(worldServerInformationNotifierProvider);
            final logs = switch (provider) {
              AsyncData(:final value) => value.logs,
              _ => []
            };
            return ListView.builder(
              itemBuilder: (context, index) {
                return Text(logs.reversed.toList()[index]);
              },
              itemCount: logs.length,
              reverse: true,
            );
          }),
        ],
      ),
    );
  }
}
