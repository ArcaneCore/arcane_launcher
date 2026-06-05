import 'package:arcane_launcher/di.dart';
import 'package:arcane_launcher/schema/external_application.dart';
import 'package:arcane_launcher/viewmodel/external_application_view_model.dart';
import 'package:arcane_launcher/widget/form_item.dart';
import 'package:arcane_launcher/widget/input.dart';
import 'package:arcane_launcher/widget/tag.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class ExternalApplicationsPage extends StatelessWidget {
  const ExternalApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final apps = getIt<ExternalApplicationViewModel>().applications;
        return ListView.builder(
          itemBuilder: (context, index) {
            if (index == apps.length) {
              return const _CreateButton();
            }
            return _Tile(application: apps[index]);
          },
          itemCount: apps.length + 1,
        );
      },
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.add_outlined), Text('新增外部程序')],
      ),
      onTap: () => _create(context),
    );
  }

  void _create(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _Form(application: ExternalApplication()),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.application});

  final ExternalApplication application;

  @override
  Widget build(BuildContext context) {
    Widget? subtitle;
    if (application.description.isNotEmpty) {
      subtitle = Text(application.description);
    }
    return ListTile(
      leading: const Icon(Icons.dns_outlined),
      subtitle: subtitle,
      title: Row(
        children: [
          Text(application.name),
          const SizedBox(width: 8),
          Tag(label: application.path, type: TagType.tertiary),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chevron_right_outlined),
          IconButton(
            onPressed: () => _destroyDialog(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      onTap: () => _edit(context),
    );
  }

  void _edit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _Form(application: application),
    );
  }

  void _destroyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AlertDialog(application: application),
    );
  }
}

class _AlertDialog extends StatelessWidget {
  const _AlertDialog({required this.application});

  final ExternalApplication application;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('删除外部程序'),
      content: const Text('你确认要删除这个外部程序吗？删除后不可恢复。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () async {
            await getIt<ExternalApplicationViewModel>().destroy(application);
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: const Text('确认'),
        ),
      ],
    );
  }
}

class _Form extends StatefulWidget {
  const _Form({required this.application});

  final ExternalApplication application;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final pathCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameCtrl.text = widget.application.name;
    descCtrl.text = widget.application.description;
    pathCtrl.text = widget.application.path;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('外部程序信息'),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_outlined),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AntFormItem(label: '名称', child: AntInput(controller: nameCtrl)),
            AntFormItem(label: '描述', child: AntInput(controller: descCtrl)),
            AntFormItem(
              label: 'Client',
              child: Row(
                children: [
                  Expanded(child: AntInput(controller: pathCtrl)),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _pickPath,
                    icon: const Icon(Icons.more_horiz_outlined),
                  ),
                ],
              ),
            ),
            ElevatedButton(onPressed: _store, child: const Text('保存')),
          ],
        ),
      ),
    );
  }

  void _pickPath() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    pathCtrl.text = result.files.single.path!;
  }

  void _store() async {
    final app = ExternalApplication();
    app.id = widget.application.id;
    app.name = nameCtrl.text;
    app.description = descCtrl.text;
    app.path = pathCtrl.text;
    await getIt<ExternalApplicationViewModel>().store(app);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}
