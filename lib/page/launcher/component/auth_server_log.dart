import 'package:arcane_launcher/provider/auth_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthServerLog extends StatelessWidget {
  const AuthServerLog({super.key});

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
      child: Consumer(builder: (context, ref, child) {
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
    );
  }
}
