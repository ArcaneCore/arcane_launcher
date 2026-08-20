import 'package:arcane_launcher/di.dart';
import 'package:arcane_launcher/schema/external_application.dart';
import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:arcane_launcher/view_model/external_application_view_model.dart';
import 'package:arcane_launcher/widget/dialog.dart';
import 'package:arcane_launcher/widget/form_item.dart';
import 'package:arcane_launcher/widget/input.dart';
import 'package:arcane_launcher/widget/tag.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
        children: [Icon(LucideIcons.plus), Text('Add External App')],
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
      leading: const Icon(LucideIcons.server),
      subtitle: subtitle,
      title: Row(
        children: [
          Text(application.name),
          const SizedBox(width: Arcane.space8),
          ArcaneTag(label: application.path, type: ArcaneTagType.tertiary),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.chevronRight),
          IconButton(
            onPressed: () => _destroyDialog(context),
            icon: const Icon(LucideIcons.trash2),
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
      builder: (context) => ArcaneConfirmDialog(
        title: 'Delete External App',
        content: 'Are you sure you want to delete this external app? This cannot be undone.',
        onConfirm: () => getIt<ExternalApplicationViewModel>().destroy(
          application,
        ),
      ),
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
    return ArcaneFormDialog(
      title: 'External App Details',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ArcaneFormItem(label: 'Name', child: ArcaneInput(controller: nameCtrl)),
          ArcaneFormItem(label: 'Description', child: ArcaneInput(controller: descCtrl)),
          ArcaneFormItem(
            label: 'Client',
            child: Row(
              children: [
                Expanded(child: ArcaneInput(controller: pathCtrl)),
                const SizedBox(width: Arcane.space8),
                IconButton(
                  onPressed: _pickPath,
                  icon: const Icon(LucideIcons.ellipsis),
                ),
              ],
            ),
          ),
          ElevatedButton(onPressed: _store, child: const Text('Save')),
        ],
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
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
