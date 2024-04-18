import 'package:arcane_launcher/provider/auth_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthServerConfigPage extends StatefulWidget {
  const AuthServerConfigPage({super.key});

  @override
  State<AuthServerConfigPage> createState() => _AuthServerConfigPageState();
}

class _AuthServerConfigPageState extends State<AuthServerConfigPage> {
  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final provider = ref.watch(authServerConfigNotifierProvider);
      final config = switch (provider) {
        AsyncData(:final value) => value,
        _ => '',
      };
      controller.text = config;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
          ),
          ElevatedButton(
            onPressed: () => handlePressed(context, ref),
            child: const Text('保存'),
          )
        ],
      );
    });
  }

  void handlePressed(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(authServerConfigNotifierProvider.notifier);
    await notifier.store(controller.text);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(const SnackBar(content: Text('保存成功')));
  }
}
