import 'package:arcane_launcher/di.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:arcane_launcher/viewmodel/server_view_model.dart';
import 'package:arcane_launcher/widget/form_item.dart';
import 'package:arcane_launcher/widget/input.dart';
import 'package:arcane_launcher/widget/switch.dart';
import 'package:arcane_launcher/widget/tag.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:signals/signals_flutter.dart';

class ServersPage extends StatelessWidget {
  const ServersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final list = getIt<ServerViewModel>().servers;
        return ListView.builder(
          itemBuilder: (context, index) {
            if (index == list.length) return const _CreateServerButton();
            return _ServerTile(server: list[index]);
          },
          itemCount: list.length + 1,
        );
      },
    );
  }
}

class _CreateServerButton extends StatelessWidget {
  const _CreateServerButton();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(LucideIcons.plus), Text('新增服务器')],
      ),
      onTap: () => _createServer(context),
    );
  }

  void _createServer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ServerForm(server: Server()),
    );
  }
}

class _ServerTile extends StatelessWidget {
  const _ServerTile({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    Widget? subtitle;
    if (server.description.isNotEmpty) subtitle = Text(server.description);
    final label = server.local ? '本地' : '远程';
    final type = server.local ? TagType.secondary : TagType.tertiary;
    return ListTile(
      leading: const Icon(LucideIcons.server),
      subtitle: subtitle,
      title: Row(
        children: [
          Text(server.name),
          if (server.version.isNotEmpty) ...[
            const SizedBox(width: 8),
            Tag(label: server.version, type: TagType.primary),
          ],
          const SizedBox(width: 8),
          Tag(label: label, type: type),
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
      builder: (context) => _ServerForm(server: server),
    );
  }

  void _destroyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ServerAlertDialog(server: server),
    );
  }
}

class _ServerAlertDialog extends StatelessWidget {
  const _ServerAlertDialog({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('删除服务器'),
      content: const Text('你确认要删除这个服务器吗？删除后不可恢复。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () async {
            await getIt<ServerViewModel>().destroy(server);
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: const Text('确认'),
        ),
      ],
    );
  }
}

class _ServerForm extends StatefulWidget {
  const _ServerForm({required this.server});

  final Server server;

  @override
  State<_ServerForm> createState() => _ServerFormState();
}

class _ServerFormState extends State<_ServerForm> {
  final nameCtrl = TextEditingController();
  final versionCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final mysqldPathCtrl = TextEditingController();
  final worldServerPathCtrl = TextEditingController();
  final worldServerConfigCtrl = TextEditingController();
  final worldServerLogCtrl = TextEditingController();
  final authServerPathCtrl = TextEditingController();
  final authServerConfigCtrl = TextEditingController();
  final authServerLogCtrl = TextEditingController();
  final realmListCtrl = TextEditingController();
  final clientPathCtrl = TextEditingController();
  late bool local = widget.server.local;

  @override
  void initState() {
    super.initState();
    final s = widget.server;
    nameCtrl.text = s.name;
    versionCtrl.text = s.version;
    descCtrl.text = s.description;
    mysqldPathCtrl.text = s.mysqldPath;
    worldServerPathCtrl.text = s.worldServerPath;
    worldServerConfigCtrl.text = s.worldServerConfig;
    worldServerLogCtrl.text = s.worldServerLog;
    authServerPathCtrl.text = s.authServerPath;
    authServerConfigCtrl.text = s.authServerConfig;
    authServerLogCtrl.text = s.authServerLog;
    realmListCtrl.text = s.realmList;
    clientPathCtrl.text = s.clientPath;
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
                const Text('服务器信息'),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AntFormItem(
                    label: '名称',
                    child: AntInput(controller: nameCtrl),
                  ),
                ),
                Expanded(
                  child: AntFormItem(
                    label: '版本',
                    child: AntInput(controller: versionCtrl),
                  ),
                ),
              ],
            ),
            AntFormItem(label: '描述', child: AntInput(controller: descCtrl)),
            AntFormItem(
              label: '是否本地',
              child: Align(
                alignment: Alignment.centerLeft,
                child: UnconstrainedBox(
                  child: AntSwitch(
                    value: local,
                    onChanged: (v) => setState(() => local = v),
                  ),
                ),
              ),
            ),
            if (local) ...[
              _pathField(
                'Mysqld',
                mysqldPathCtrl,
                () => _pickFile(mysqldPathCtrl),
              ),
              _pathField(
                'World Server',
                worldServerPathCtrl,
                () => _pickFile(worldServerPathCtrl),
              ),
              _pathField(
                'World Server Config',
                worldServerConfigCtrl,
                () => _pickFile(worldServerConfigCtrl),
              ),
              _pathField(
                'World Server Log',
                worldServerLogCtrl,
                () => _pickFile(worldServerLogCtrl),
              ),
              _pathField(
                'Auth Server',
                authServerPathCtrl,
                () => _pickFile(authServerPathCtrl),
              ),
              _pathField(
                'Auth Server Config',
                authServerConfigCtrl,
                () => _pickFile(authServerConfigCtrl),
              ),
              _pathField(
                'Auth Server Log',
                authServerLogCtrl,
                () => _pickFile(authServerLogCtrl),
              ),
            ],
            if (!local)
              AntFormItem(
                label: '地址',
                child: AntInput(controller: realmListCtrl),
              ),
            _pathField(
              'Client',
              clientPathCtrl,
              () => _pickFile(clientPathCtrl),
            ),
            ElevatedButton(onPressed: _store, child: const Text('保存')),
          ],
        ),
      ),
    );
  }

  Widget _pathField(
    String label,
    TextEditingController ctrl,
    VoidCallback onPick,
  ) {
    return AntFormItem(
      label: label,
      child: Row(
        children: [
          Expanded(child: AntInput(controller: ctrl)),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onPick,
            icon: const Icon(LucideIcons.ellipsis),
          ),
        ],
      ),
    );
  }

  void _pickFile(TextEditingController ctrl) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    ctrl.text = result.files.single.path!;
  }

  void _store() async {
    final server = Server();
    server.id = widget.server.id;
    server.name = nameCtrl.text;
    server.description = descCtrl.text;
    server.version = versionCtrl.text;
    server.local = local;
    server.realmList = realmListCtrl.text;
    server.mysqldPath = mysqldPathCtrl.text;
    server.worldServerPath = worldServerPathCtrl.text;
    server.worldServerConfig = worldServerConfigCtrl.text;
    server.worldServerLog = worldServerLogCtrl.text;
    server.authServerPath = authServerPathCtrl.text;
    server.authServerConfig = authServerConfigCtrl.text;
    server.authServerLog = authServerLogCtrl.text;
    server.clientPath = clientPathCtrl.text;
    await getIt<ServerViewModel>().store(server);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}
