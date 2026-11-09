import 'package:arcane_launcher/model/config_document.dart';
import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:arcane_launcher/widget/input.dart';
import 'package:arcane_launcher/widget/switch.dart';
import 'package:flutter/material.dart';

/// Form editor for an INI-style server config.
///
/// Entries are grouped by the file's section banners and only the visible
/// rows are built, so editing a large config stays fast.
class ConfigForm extends StatefulWidget {
  const ConfigForm({super.key, required this.document, required this.onSave});

  final ConfigDocument document;

  /// Persists the document; throws when saving failed.
  final Future<void> Function() onSave;

  @override
  State<ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends State<ConfigForm> {
  final _search = TextEditingController();
  final _changed = ValueNotifier<int>(0);
  String _query = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _changed.value = widget.document.changedCount;
  }

  @override
  void dispose() {
    _search.dispose();
    _changed.dispose();
    super.dispose();
  }

  List<_ConfigRow> _rows() {
    final query = _query.trim().toLowerCase();
    final rows = <_ConfigRow>[];
    for (final section in widget.document.sections) {
      final matches =
          section.entries.where((entry) {
            if (query.isEmpty) return true;
            return entry.key.toLowerCase().contains(query) ||
                entry.description.toLowerCase().contains(query);
          }).toList();
      if (matches.isEmpty) continue;
      rows.add(_SectionRow(section.title, matches.length));
      rows.addAll(matches.map(_EntryRow.new));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _toolbar(context),
        const SizedBox(height: Arcane.space16),
        Expanded(
          child:
              rows.isEmpty
                  ? const Center(child: Text('No matching settings'))
                  : ListView.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      return switch (row) {
                        _SectionRow() => _SectionHeader(row: row),
                        _EntryRow() => _ConfigEntryTile(
                          key: ValueKey(row.entry),
                          entry: row.entry,
                          onChanged: _handleChanged,
                        ),
                      };
                    },
                  ),
        ),
      ],
    );
  }

  Widget _toolbar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: ArcaneInput(
            controller: _search,
            placeholder: 'Search settings',
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        const SizedBox(width: Arcane.space16),
        ValueListenableBuilder<int>(
          valueListenable: _changed,
          builder: (context, changed, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  changed == 0 ? 'No changes' : '$changed changed',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: Arcane.space12),
                ElevatedButton(
                  onPressed: changed == 0 || _saving ? null : _save,
                  child: Text(_saving ? 'Saving...' : 'Save'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _handleChanged() {
    _changed.value = widget.document.changedCount;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.onSave();
      widget.document.acceptChanges();
      _changed.value = 0;
    } catch (_) {
      // The owner of [ConfigForm.onSave] reports the error to the user.
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

sealed class _ConfigRow {
  const _ConfigRow();
}

class _SectionRow extends _ConfigRow {
  const _SectionRow(this.title, this.count);

  final String title;
  final int count;
}

class _EntryRow extends _ConfigRow {
  const _EntryRow(this.entry);

  final ConfigEntry entry;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.row});

  final _SectionRow row;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
        top: Arcane.space24,
        bottom: Arcane.space4,
      ),
      child: Row(
        children: [
          Text(
            row.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: Arcane.space8),
          Text(
            '${row.count}',
            style: TextStyle(fontSize: 12, color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

class _ConfigEntryTile extends StatefulWidget {
  const _ConfigEntryTile({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final ConfigEntry entry;
  final VoidCallback onChanged;

  @override
  State<_ConfigEntryTile> createState() => _ConfigEntryTileState();
}

class _ConfigEntryTileState extends State<_ConfigEntryTile> {
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.entry.type != ConfigValueType.boolean) {
      _controller = TextEditingController(text: widget.entry.displayValue);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Arcane.space8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (entry.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: Arcane.space2),
                    child: Text(
                      entry.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Arcane.space16),
          SizedBox(width: 280, child: _control(entry)),
        ],
      ),
    );
  }

  Widget _control(ConfigEntry entry) {
    switch (entry.type) {
      case ConfigValueType.boolean:
        return Align(
          alignment: Alignment.centerRight,
          child: ArcaneSwitch(
            value: entry.boolValue,
            onChanged: (value) {
              setState(() => entry.boolValue = value);
              widget.onChanged();
            },
          ),
        );
      case ConfigValueType.integer:
      case ConfigValueType.decimal:
      case ConfigValueType.string:
        return ArcaneInput(controller: _controller, onChanged: _handleText);
    }
  }

  void _handleText(String text) {
    final entry = widget.entry;
    final value = text.trim();
    final valid = switch (entry.type) {
      ConfigValueType.boolean => true,
      ConfigValueType.integer => int.tryParse(value) != null,
      ConfigValueType.decimal => double.tryParse(value) != null,
      ConfigValueType.string => true,
    };
    if (!valid) return;
    entry.updateDisplayValue(value);
    widget.onChanged();
  }
}
