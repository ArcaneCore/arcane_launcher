import 'dart:async';

import 'package:arcane_launcher/di.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:arcane_launcher/util/server_discovery.dart';
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
        children: [Icon(LucideIcons.plus), Text('Add Server')],
      ),
      onTap: () => _createServer(context),
    );
  }

  void _createServer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ServerForm(server: ServerEntity()),
    );
  }
}

class _ServerTile extends StatelessWidget {
  const _ServerTile({required this.server});

  final ServerEntity server;

  @override
  Widget build(BuildContext context) {
    Widget? subtitle;
    if (server.description.isNotEmpty) subtitle = Text(server.description);
    final label = server.local ? 'Local' : 'Remote';
    final type = server.local ? ArcaneTagType.secondary : ArcaneTagType.tertiary;
    return ListTile(
      leading: const Icon(LucideIcons.server),
      subtitle: subtitle,
      title: Row(
        children: [
          Text(server.name),
          if (server.version.isNotEmpty) ...[
            const SizedBox(width: Arcane.space8),
            ArcaneTag(label: server.version, type: ArcaneTagType.primary),
          ],
          const SizedBox(width: Arcane.space8),
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
        title: 'Delete Server',
        content: 'Are you sure you want to delete this server? This cannot be undone.',
        onConfirm: () => getIt<ServerViewModel>().destroy(server),
      ),
    );
  }
}

class _ServerForm extends StatefulWidget {
  const _ServerForm({required this.server});

  final ServerEntity server;

  @override
  State<_ServerForm> createState() => _ServerFormState();
}

class _ServerFormState extends State<_ServerForm> {
  final nameCtrl = TextEditingController();
  final versionCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final serverDirCtrl = TextEditingController();
  final clientDirCtrl = TextEditingController();
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
  late bool advancedExpanded = widget.server.id != null;
  bool discovering = false;
  bool discovered = false;
  List<String> warnings = [];
  Timer? debounce;

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
  void dispose() {
    debounce?.cancel();
    nameCtrl.dispose();
    versionCtrl.dispose();
    descCtrl.dispose();
    serverDirCtrl.dispose();
    clientDirCtrl.dispose();
    mysqldPathCtrl.dispose();
    worldServerPathCtrl.dispose();
    worldServerConfigCtrl.dispose();
    worldServerLogCtrl.dispose();
    authServerPathCtrl.dispose();
    authServerConfigCtrl.dispose();
    authServerLogCtrl.dispose();
    realmListCtrl.dispose();
    clientPathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ArcaneFormDialog(
      title: 'Server Details',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ArcaneFormItem(
                  label: 'Name',
                  child: ArcaneInput(controller: nameCtrl),
                ),
              ),
              Expanded(
                child: ArcaneFormItem(
                  label: 'Version',
                  child: ArcaneInput(controller: versionCtrl),
                ),
              ),
            ],
          ),
          ArcaneFormItem(label: 'Description', child: ArcaneInput(controller: descCtrl)),
          ArcaneFormItem(
            label: 'Local',
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
            _directoryField(
              'Server Directory',
              serverDirCtrl,
              'Select the emulator root; config is auto-discovered',
            ),
            _directoryField(
              'Client Directory',
              clientDirCtrl,
              'Select the client root; the executable is auto-discovered',
            ),
            _discoveryStatus(),
            _advancedSection(),
          ] else
            ArcaneFormItem(
              label: 'Address',
              child: ArcaneInput(controller: realmListCtrl),
            ),
          ElevatedButton(onPressed: _store, child: const Text('Save')),
        ],
      ),
    );
  }

  /// Directory input row: path input (debounced discovery) + folder picker.
  Widget _directoryField(
    String label,
    TextEditingController ctrl,
    String placeholder,
  ) {
    return ArcaneFormItem(
      label: label,
      child: Row(
        children: [
          Expanded(
            child: ArcaneInput(
              controller: ctrl,
              placeholder: placeholder,
              onChanged: (_) => scheduleDiscover(),
            ),
          ),
          const SizedBox(width: Arcane.space8),
          IconButton(
            onPressed: () => pickDirectory(ctrl),
            icon: const Icon(LucideIcons.folder),
          ),
        ],
      ),
    );
  }

  /// Discovery status row: in-progress hint, missing-item warnings, all-found.
  Widget _discoveryStatus() {
    final cs = Theme.of(context).colorScheme;
    if (discovering) {
      return const Padding(
        padding: EdgeInsets.only(bottom: Arcane.space16),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: Arcane.space8),
            Text('Discovering configuration...'),
          ],
        ),
      );
    }
    if (!discovered) return const SizedBox.shrink();
    if (warnings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: Arcane.space16),
        child: Row(
          children: [
            const Icon(LucideIcons.checkCircle2, size: 18, color: Colors.green),
            const SizedBox(width: Arcane.space8),
            const Text('All configuration items discovered'),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: Arcane.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final warning in warnings)
            Padding(
              padding: const EdgeInsets.only(bottom: Arcane.space4),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.alertTriangle,
                    size: 16,
                    color: cs.error,
                  ),
                  const SizedBox(width: Arcane.space8),
                  Expanded(
                    child: Text(
                      warning,
                      style: TextStyle(color: cs.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Collapsible advanced section: all discovered fields, manually editable.
  Widget _advancedSection() {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => advancedExpanded = !advancedExpanded),
          borderRadius: BorderRadius.circular(Arcane.radiusControl),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Arcane.space4),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: advancedExpanded ? 0.5 : 0,
                  duration: Arcane.duration,
                  child: const Icon(LucideIcons.chevronDown, size: 18),
                ),
                const SizedBox(width: Arcane.space4),
                const Text('Advanced'),
              ],
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: Arcane.duration,
            curve: Arcane.curve,
            child: advancedExpanded
                ? Padding(
                    padding: const EdgeInsets.only(left: Arcane.space16),
                    child: Column(
                      children: [
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
                        ArcaneFormItem(
                          label: 'Realm List',
                          child: ArcaneInput(
                            controller: realmListCtrl,
                            placeholder: 'Default: 127.0.0.1',
                          ),
                        ),
                        _pathField(
                          'Client Executable',
                          clientPathCtrl,
                          () => _pickFile(clientPathCtrl),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
        const SizedBox(height: Arcane.space8),
      ],
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
          const SizedBox(width: Arcane.space8),
          IconButton(onPressed: onPick, icon: const Icon(LucideIcons.ellipsis)),
        ],
      ),
    );
  }

  void scheduleDiscover() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 400), discover);
  }

  Future<void> pickDirectory(TextEditingController ctrl) async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null) return;
    ctrl.text = path;
    await discover();
  }

  Future<void> discover() async {
    final serverDir = serverDirCtrl.text.trim();
    final clientDir = clientDirCtrl.text.trim();
    if (serverDir.isEmpty && clientDir.isEmpty) return;
    setState(() => discovering = true);
    final result = await discoverServer(
      serverDir: serverDir,
      clientDir: clientDir,
    );
    if (!mounted) return;
    setState(() {
      discovering = false;
      discovered = true;
      warnings = result.warnings;
      advancedExpanded = true;
      applyDiscovery(result.server);
    });
  }

  /// Applies discovery results to the form; only non-empty fields are
  /// overwritten, and the name is filled only when empty.
  void applyDiscovery(ServerEntity discovered) {
    if (nameCtrl.text.isEmpty && discovered.name.isNotEmpty) {
      nameCtrl.text = discovered.name;
    }
    void cover(TextEditingController ctrl, String value) {
      if (value.isNotEmpty) ctrl.text = value;
    }

    cover(mysqldPathCtrl, discovered.mysqldPath);
    cover(worldServerPathCtrl, discovered.worldServerPath);
    cover(worldServerConfigCtrl, discovered.worldServerConfig);
    cover(worldServerLogCtrl, discovered.worldServerLog);
    cover(authServerPathCtrl, discovered.authServerPath);
    cover(authServerConfigCtrl, discovered.authServerConfig);
    cover(authServerLogCtrl, discovered.authServerLog);
    if (discovered.realmList.isNotEmpty && discovered.realmList != '127.0.0.1') {
      realmListCtrl.text = discovered.realmList;
    }
    cover(clientPathCtrl, discovered.clientPath);
  }

  void _pickFile(TextEditingController ctrl) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    ctrl.text = result.files.single.path!;
  }

  void _store() async {
    final server = ServerEntity();
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
