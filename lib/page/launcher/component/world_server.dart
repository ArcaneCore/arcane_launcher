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
