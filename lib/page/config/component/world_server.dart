import 'package:arcane_launcher/di.dart';
import 'package:arcane_launcher/view_model/server_view_model.dart';
import 'package:arcane_launcher/view_model/world_server_view_model.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class WorldServerConfigPage extends StatefulWidget {
  const WorldServerConfigPage({super.key});

  @override
  State<WorldServerConfigPage> createState() => _State();
}

class _State extends State<WorldServerConfigPage> {
  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final config = getIt<WorldServerViewModel>().config;
        controller.text = config;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(border: InputBorder.none),
                maxLines: null,
              ),
            ),
            ElevatedButton(onPressed: _store, child: const Text('Save')),
          ],
        );
      },
    );
  }

  void _store() async {
    final server = getIt<ServerViewModel>().activeServer;
    await getIt<WorldServerViewModel>().storeConfig(server, controller.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Saved')));
  }
}
