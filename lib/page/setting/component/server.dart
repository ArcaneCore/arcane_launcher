import 'package:arcane_launcher/di.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:arcane_launcher/view_model/server_view_model.dart';
import 'package:arcane_launcher/widget/dialog.dart';
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
    final type = server.local ? ArcaneTagType.secondary : ArcaneTagType.tertiary;
    return ListTile(
      leading: const Icon(LucideIcons.server),
      subtitle: subtitle,
      title: Row(
        children: [
          Text(server.name),
          if (server.version.isNotEmpty) ...[
            const SizedBox(width: 8),
            ArcaneTag(label: server.version, type: ArcaneTagType.primary),
          ],
          const SizedBox(width: 8),
          ArcaneTag(label: label, type: type),
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
      builder: (context) => ArcaneConfirmDialog(
        title: '删除服务器',
        content: '你确认要删除这个服务器吗？删除后不可恢复。',
        onConfirm: () => getIt<ServerViewModel>().destroy(server),
      ),
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
    return ArcaneFormDialog(
      title: '服务器信息',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ArcaneFormItem(
                  label: '名称',
                  child: ArcaneInput(controller: nameCtrl),
                ),
              ),
              Expanded(
                child: ArcaneFormItem(
                  label: '版本',
                  child: ArcaneInput(controller: versionCtrl),
                ),
              ),
            ],
          ),
          ArcaneFormItem(label: '描述', child: ArcaneInput(controller: descCtrl)),
          ArcaneFormItem(
            label: '是否本地',
            child: Align(
              alignment: Alignment.centerLeft,
              child: UnconstrainedBox(
                child: ArcaneSwitch(
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
            ArcaneFormItem(
              label: '地址',
              child: ArcaneInput(controller: realmListCtrl),
            ),
          _pathField(
            'Client',
            clientPathCtrl,
            () => _pickFile(clientPathCtrl),
          ),
          ElevatedButton(onPressed: _store, child: const Text('保存')),
        ],
      ),
    );
  }

  Widget _pathField(
    String label,
    TextEditingController ctrl,
    VoidCallback onPick,
  ) {
    return ArcaneFormItem(
      label: label,
      child: Row(
        children: [
          Expanded(child: ArcaneInput(controller: ctrl)),
          const SizedBox(width: 8),
          IconButton(onPressed: onPick, icon: const Icon(LucideIcons.ellipsis)),
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
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
