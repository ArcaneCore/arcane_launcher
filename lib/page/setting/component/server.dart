import 'package:arcane_launcher/provider/server.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:arcane_launcher/widget/form_item.dart';
import 'package:arcane_launcher/widget/input.dart';
import 'package:arcane_launcher/widget/switch.dart';
import 'package:arcane_launcher/widget/tag.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServersPage extends StatelessWidget {
  const ServersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final provider = ref.watch(serversNotifierProvider);
      final List<Server> servers = switch (provider) {
        AsyncData(:final value) => value,
        _ => [],
      };
      return ListView.builder(
        itemBuilder: (context, index) {
          if (index == servers.length) return const _CreateServerButton();
          return _ServerTile(server: servers[index]);
        },
        itemCount: servers.length + 1,
      );
    });
  }
}

class _CreateServerButton extends StatelessWidget {
  const _CreateServerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.add_outlined), Text('新增服务器')],
      ),
      onTap: () => createServer(context),
    );
  }

  void createServer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _ServerForm(server: Server());
      },
    );
  }
}

class _ServerTile extends StatelessWidget {
  const _ServerTile({super.key, required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    Widget? subtitle;
    if (server.description.isNotEmpty) {
      subtitle = Text(server.description);
    }
    final label = server.local ? '本地' : '远程';
    TagType type = TagType.tertiary;
    if (server.local) {
      type = TagType.secondary;
    }
    return ListTile(
      leading: const Icon(Icons.dns_outlined),
      subtitle: subtitle,
      title: Row(
        children: [
          Text(server.name),
          if (server.version.isNotEmpty) ...[
            const SizedBox(width: 8),
            Tag(label: server.version, type: TagType.primary),
          ],
          const SizedBox(width: 8),
          Tag(label: label, type: type)
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chevron_right_outlined),
          IconButton(
            onPressed: () => destroyServer(context, server),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      onTap: () => editServer(context, server),
    );
  }

  void editServer(BuildContext context, Server server) {
    showDialog(
      context: context,
      builder: (context) => _ServerForm(server: server),
    );
  }

  void destroyServer(BuildContext context, Server server) {
    showDialog(
      context: context,
      builder: (context) => _ServerAlertDialog(server: server),
    );
  }
}

class _ServerAlertDialog extends StatelessWidget {
  const _ServerAlertDialog({super.key, required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('删除服务器'),
      content: const Text('你确认要删除这个服务器吗？删除后不可恢复。'),
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
    final notifier = ref.read(serversNotifierProvider.notifier);
    await notifier.destroy(server);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}

class _ServerForm extends StatefulWidget {
  const _ServerForm({super.key, required this.server});

  final Server server;

  @override
  State<_ServerForm> createState() => _ServerFormState();
}

class _ServerFormState extends State<_ServerForm> {
  TextEditingController nameController = TextEditingController();
  TextEditingController versionController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController mysqldPathController = TextEditingController();
  TextEditingController worldServerPathController = TextEditingController();
  TextEditingController worldServerConfigController = TextEditingController();
  TextEditingController worldServerLogController = TextEditingController();
  TextEditingController authServerPathController = TextEditingController();
  TextEditingController authServerConfigController = TextEditingController();
  TextEditingController authServerLogController = TextEditingController();
  TextEditingController realmListController = TextEditingController();
  TextEditingController clientPathController = TextEditingController();

  late bool local = widget.server.local;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.server.name;
    versionController.text = widget.server.version;
    descriptionController.text = widget.server.description;
    mysqldPathController.text = widget.server.mysqldPath;
    worldServerPathController.text = widget.server.worldServerPath;
    worldServerConfigController.text = widget.server.worldServerConfig;
    worldServerLogController.text = widget.server.worldServerLog;
    authServerPathController.text = widget.server.authServerPath;
    authServerConfigController.text = widget.server.authServerConfig;
    authServerLogController.text = widget.server.authServerLog;
    realmListController.text = widget.server.realmList;
    clientPathController.text = widget.server.clientPath;
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
                  onPressed: () => cancel(context),
                  icon: const Icon(Icons.close_outlined),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AntFormItem(
                    label: '名称',
                    child: AntInput(controller: nameController),
                  ),
                ),
                Expanded(
                  child: AntFormItem(
                    label: '版本',
                    child: AntInput(controller: versionController),
                  ),
                ),
              ],
            ),
            AntFormItem(
              label: '描述',
              child: AntInput(controller: descriptionController),
            ),
            AntFormItem(
              label: '是否本地',
              child: Align(
                alignment: Alignment.centerLeft,
                child: UnconstrainedBox(
                  child: AntSwitch(value: local, onChanged: updateLocal),
                ),
              ),
            ),
            if (local) ...[
              AntFormItem(
                label: 'Mysqld',
                child: Row(
                  children: [
                    Expanded(child: AntInput(controller: mysqldPathController)),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: updateMysqldPath,
                      icon: const Icon(Icons.more_horiz_outlined),
                    )
                  ],
                ),
              ),
              AntFormItem(
                label: 'World Server',
                child: Row(
                  children: [
                    Expanded(
                      child: AntInput(controller: worldServerPathController),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: updateWorldServerPath,
                      icon: const Icon(Icons.more_horiz_outlined),
                    )
                  ],
                ),
              ),
              AntFormItem(
                label: 'World Server Config',
                child: Row(
                  children: [
                    Expanded(
                      child: AntInput(controller: worldServerConfigController),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: updateWorldServerConfig,
                      icon: const Icon(Icons.more_horiz_outlined),
                    )
                  ],
                ),
              ),
              AntFormItem(
                label: 'World Server Log',
                child: Row(
                  children: [
                    Expanded(
                      child: AntInput(controller: worldServerLogController),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: updateWorldServerLog,
                      icon: const Icon(Icons.more_horiz_outlined),
                    )
                  ],
                ),
              ),
              AntFormItem(
                label: 'Auth Server',
                child: Row(
                  children: [
                    Expanded(
                      child: AntInput(controller: authServerPathController),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: updateAuthServerPath,
                      icon: const Icon(Icons.more_horiz_outlined),
                    )
                  ],
                ),
              ),
              AntFormItem(
                label: 'Auth Server Config',
                child: Row(
                  children: [
                    Expanded(
                      child: AntInput(controller: authServerConfigController),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: updateAuthServerConfig,
                      icon: const Icon(Icons.more_horiz_outlined),
                    )
                  ],
                ),
              ),
              AntFormItem(
                label: 'Auth Server Log',
                child: Row(
                  children: [
                    Expanded(
                      child: AntInput(controller: authServerLogController),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: updateAuthServerLog,
                      icon: const Icon(Icons.more_horiz_outlined),
                    )
                  ],
                ),
              ),
            ],
            if (!local)
              AntFormItem(
                label: '地址',
                child: AntInput(controller: realmListController),
              ),
            AntFormItem(
              label: 'Client',
              child: Row(
                children: [
                  Expanded(
                    child: AntInput(controller: clientPathController),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: updateClientPath,
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

  void updateLocal(bool value) {
    setState(() {
      local = value;
    });
  }

  void updateMysqldPath() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final path = result.files.single.path!;
    mysqldPathController.text = path;
  }

  void updateWorldServerPath() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final path = result.files.single.path!;
    worldServerPathController.text = path;
  }

  void updateWorldServerConfig() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final path = result.files.single.path!;
    worldServerConfigController.text = path;
  }

  void updateWorldServerLog() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final path = result.files.single.path!;
    worldServerLogController.text = path;
  }

  void updateAuthServerPath() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final path = result.files.single.path!;
    authServerPathController.text = path;
  }

  void updateAuthServerConfig() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final path = result.files.single.path!;
    authServerConfigController.text = path;
  }

  void updateAuthServerLog() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final path = result.files.single.path!;
    authServerLogController.text = path;
  }

  void updateClientPath() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final path = result.files.single.path!;
    clientPathController.text = path;
  }

  void store(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(serversNotifierProvider.notifier);
    final server = Server();
    server.id = widget.server.id;
    server.name = nameController.text;
    server.description = descriptionController.text;
    server.version = versionController.text;
    server.local = local;
    server.realmList = realmListController.text;
    server.mysqldPath = mysqldPathController.text;
    server.worldServerPath = worldServerPathController.text;
    server.worldServerConfig = worldServerConfigController.text;
    server.worldServerLog = worldServerLogController.text;
    server.authServerPath = authServerPathController.text;
    server.authServerConfig = authServerConfigController.text;
    server.authServerLog = authServerLogController.text;
    server.clientPath = clientPathController.text;
    await notifier.store(server);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  void cancel(BuildContext context) {
    Navigator.of(context).pop();
  }
}
