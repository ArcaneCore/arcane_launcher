import 'package:arcane_launcher/model/service_information.dart';
import 'package:arcane_launcher/view_model/auth_server_view_model.dart';
import 'package:arcane_launcher/view_model/server_view_model.dart';
import 'package:arcane_launcher/widget/service_tile.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:signals/signals_flutter.dart';

class AuthServerTile extends StatelessWidget {
  const AuthServerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final vm = GetIt.instance.get<AuthServerViewModel>();
        final info = vm.info;
        return ServiceTile(
          active: info.status != ServiceStatus.stopped,
          leading: const Icon(LucideIcons.user),
          loading: info.status == ServiceStatus.starting,
          name: 'Auth Server',
          processIds: info.processIds,
          onChanged:
              () =>
                  vm.toggle(GetIt.instance.get<ServerViewModel>().activeServer),
        );
      },
    );
  }
}
