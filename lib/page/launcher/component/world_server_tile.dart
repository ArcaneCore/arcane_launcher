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
      final active = switch (provider) {
        AsyncData(:final value) => value.active,
        _ => false
      };
      return ServiceTile(
        active: active,
        leading: const Icon(Icons.sports_esports_outlined),
        loading: active && processIds.isEmpty,
        name: 'World Server',
        processIds: processIds,
        onChanged: () => toggleWorldServerService(ref, active),
      );
    });
  }

  void toggleWorldServerService(WidgetRef ref, bool active) {
    final notifier = ref.read(worldServerInformationNotifierProvider.notifier);
    if (active) {
      notifier.stop();
    } else {
      notifier.start();
    }
  }
}
