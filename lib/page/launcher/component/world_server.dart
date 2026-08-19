import 'package:arcane_launcher/di.dart';
import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/view_model/server_view_model.dart';
import 'package:arcane_launcher/view_model/world_server_view_model.dart';
import 'package:arcane_launcher/widget/service_tile.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:signals/signals_flutter.dart';

class WorldServerTile extends StatelessWidget {
  const WorldServerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final vm = getIt<WorldServerViewModel>();
        final info = vm.info;
        return ServiceTile(
          active: info.status != ServiceStatus.stopped,
          leading: const Icon(LucideIcons.gamepad2),
          loading: info.status == ServiceStatus.starting,
          name: 'World Server',
          processIds: info.processIds,
          onChanged: () => vm.toggle(getIt<ServerViewModel>().activeServer),
        );
      },
    );
  }
}

class WorldServerLog extends StatelessWidget {
  const WorldServerLog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final shadow = theme.colorScheme.shadow.withValues(alpha: 0.125);
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(blurRadius: 16, color: shadow, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Center(
            child: Text(
              'WORLD SERVER',
              maxLines: 1,
              style: TextStyle(
                color: shadow.withValues(alpha: 0.05),
                fontSize: 120,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SignalBuilder(
            builder: (context) {
              final logs = getIt<WorldServerViewModel>().info.logs;
              return ListView.builder(
                itemBuilder:
                    (context, index) => Text(logs.reversed.toList()[index]),
                itemCount: logs.length,
                reverse: true,
              );
            },
          ),
        ],
      ),
    );
  }
}
