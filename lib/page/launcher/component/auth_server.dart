import 'package:arcane_launcher/di.dart';
import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/viewmodel/auth_server_view_model.dart';
import 'package:arcane_launcher/viewmodel/server_view_model.dart';
import 'package:arcane_launcher/widget/service_tile.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:signals/signals_flutter.dart';

class AuthServerTile extends StatelessWidget {
  const AuthServerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final vm = getIt<AuthServerViewModel>();
        final info = vm.info;
        return ServiceTile(
          active: info.status != ServiceStatus.stopped,
          leading: const Icon(LucideIcons.user),
          loading: info.status == ServiceStatus.starting,
          name: 'Auth Server',
          processIds: info.processIds,
          onChanged: () => vm.toggle(getIt<ServerViewModel>().activeServer),
        );
      },
    );
  }
}

class AuthServerLog extends StatelessWidget {
  const AuthServerLog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final shadow = theme.colorScheme.shadow.withValues(alpha: 0.125);
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
              'AUTH SERVER',
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
              final logs = getIt<AuthServerViewModel>().info.logs;
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
