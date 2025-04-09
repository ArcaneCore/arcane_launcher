import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/widget/service_tile.dart';
import 'package:arcane_launcher/provider/auth_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthServerTile extends StatelessWidget {
  const AuthServerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final provider = ref.watch(authServerInformationNotifierProvider);
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
        leading: const Icon(Icons.person_outline),
        loading: status == ServiceStatus.starting,
        name: 'Auth Server',
        processIds: processIds,
        onChanged: () => toggleWorldServerService(ref),
      );
    });
  }

  void toggleWorldServerService(WidgetRef ref) async {
    final notifier = ref.read(authServerInformationNotifierProvider.notifier);
    notifier.toggle();
  }
}

class AuthServerLog extends StatelessWidget {
  const AuthServerLog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;
    final shadow = colorScheme.shadow.withValues(alpha: 0.125);
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
          Consumer(builder: (context, ref, child) {
            final provider = ref.watch(authServerInformationNotifierProvider);
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
