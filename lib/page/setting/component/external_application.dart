import 'package:arcane_launcher/provider/external_application.dart';
import 'package:arcane_launcher/schema/external_application.dart';
import 'package:arcane_launcher/widget/form_item.dart';
import 'package:arcane_launcher/widget/input.dart';
import 'package:arcane_launcher/widget/tag.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExternalApplicationsPage extends StatelessWidget {
  const ExternalApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final provider = ref.watch(externalApplicationsNotifierProvider);
      final List<ExternalApplication> servers = switch (provider) {
        AsyncData(:final value) => value,
        _ => [],
      };
      return ListView.builder(
        itemBuilder: (context, index) {
          if (index == servers.length) {
            return const _CreateExternalApplicationButton();
          }
          return _ExternalApplicationTile(application: servers[index]);
        },
        itemCount: servers.length + 1,
      );
    });
  }
}

class _CreateExternalApplicationButton extends StatelessWidget {
  const _CreateExternalApplicationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.add_outlined), Text('新增外部程序')],
      ),
      onTap: () => createExternalApplication(context),
    );
  }

  void createExternalApplication(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _ExternalApplicationForm(application: ExternalApplication());
      },
    );
  }
}

class _ExternalApplicationTile extends StatelessWidget {
  const _ExternalApplicationTile({super.key, required this.application});

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
          Tag(label: application.path, type: TagType.tertiary)
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chevron_right_outlined),
          IconButton(
            onPressed: () => destroyExternalApplication(context, application),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      onTap: () => editExternalApplication(context, application),
    );
  }

  void editExternalApplication(
      BuildContext context, ExternalApplication application) {
    showDialog(
      context: context,
      builder: (context) => _ExternalApplicationForm(application: application),
    );
  }

  void destroyExternalApplication(
      BuildContext context, ExternalApplication application) {
    showDialog(
      context: context,
      builder: (context) {
        return _ExternalApplicationAlertDialog(application: application);
      },
    );
  }
}

class _ExternalApplicationAlertDialog extends StatelessWidget {
  const _ExternalApplicationAlertDialog({super.key, required this.application});

  final ExternalApplication application;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('删除外部程序'),
      content: const Text('你确认要删除这个外部程序吗？删除后不可恢复。'),
      actions: [
        TextButton(
          onPressed: () => cancelDestroy(context),
          child: const Text('取消'),
        ),
        Consumer(builder: (context, ref, child) {
          return TextButton(
            onPressed: () => confirmDestroy(context, ref),
            child: const Text('确认'),
          );
        })
      ],
    );
  }

  void cancelDestroy(BuildContext context) {
    Navigator.of(context).pop();
  }

  void confirmDestroy(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(externalApplicationsNotifierProvider.notifier);
    await notifier.destroy(application);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}

class _ExternalApplicationForm extends StatefulWidget {
  const _ExternalApplicationForm({super.key, required this.application});

  final ExternalApplication application;

  @override
  State<_ExternalApplicationForm> createState() =>
      _ExternalApplicationFormState();
}

class _ExternalApplicationFormState extends State<_ExternalApplicationForm> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController pathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.application.name;
    descriptionController.text = widget.application.description;
    pathController.text = widget.application.path;
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
                  onPressed: () => cancel(context),
                  icon: const Icon(Icons.close_outlined),
                )
              ],
            ),
            const SizedBox(height: 16),
            AntFormItem(
              label: '名称',
              child: AntInput(controller: nameController),
            ),
            AntFormItem(
              label: '描述',
              child: AntInput(controller: descriptionController),
            ),
            AntFormItem(
              label: 'Client',
              child: Row(
                children: [
                  Expanded(
                    child: AntInput(controller: pathController),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: updatePath,
                    icon: const Icon(Icons.more_horiz_outlined),
                  )
                ],
              ),
            ),
            Consumer(builder: (context, ref, child) {
              return ElevatedButton(
                onPressed: () => store(context, ref),
                child: const Text('保存'),
              );
            })
          ],
        ),
      ),
    );
  }

  void updatePath() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final path = result.files.single.path!;
    pathController.text = path;
  }

  void store(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(externalApplicationsNotifierProvider.notifier);
    final application = ExternalApplication();
    application.id = widget.application.id;
    application.name = nameController.text;
    application.description = descriptionController.text;
    application.path = pathController.text;
    await notifier.store(application);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  void cancel(BuildContext context) {
    Navigator.of(context).pop();
  }
}
