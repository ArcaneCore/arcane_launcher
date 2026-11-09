import 'package:arcane_launcher/model/config_document.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:arcane_launcher/view_model/config_view_model.dart';
import 'package:arcane_launcher/view_model/server_view_model.dart';
import 'package:arcane_launcher/widget/config_form.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Loads the active server's config file when opened and edits it as a form.
class ServerConfigPage extends StatefulWidget {
  const ServerConfigPage({super.key, required this.viewModel});

  final ConfigViewModel viewModel;

  @override
  State<ServerConfigPage> createState() => _ServerConfigPageState();
}

class _ServerConfigPageState extends State<ServerConfigPage> {
  ConfigDocument? _document;
  String? _error;
  bool _loading = true;

  ServerEntity get _server =>
      GetIt.instance.get<ServerViewModel>().activeServer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await widget.viewModel.fetchConfig(_server);
      if (!mounted) return;
      setState(() {
        _document = widget.viewModel.document;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to read config: $error';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    final document = _document;
    if (document == null) {
      return const Center(child: Text('No config file configured'));
    }
    return ConfigForm(document: document, onSave: _save);
  }

  Future<void> _save() async {
    try {
      await widget.viewModel.storeConfig(_server);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Saved')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Save failed: $error')));
      }
      rethrow;
    }
  }
}
