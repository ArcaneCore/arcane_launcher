import 'package:arcane_launcher/page/config/component/server_config_page.dart';
import 'package:arcane_launcher/view_model/auth_server_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AuthServerConfigPage extends StatelessWidget {
  const AuthServerConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ServerConfigPage(
      viewModel: GetIt.instance.get<AuthServerViewModel>(),
    );
  }
}
