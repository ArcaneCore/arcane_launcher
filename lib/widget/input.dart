import 'package:arcane_launcher/theme/arcane_theme.dart';
import 'package:flutter/material.dart';

class ArcaneInput extends StatelessWidget {
  const ArcaneInput({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Arcane.space8),
      decoration: BoxDecoration(
        border: Border.all(color: Arcane.border(Theme.of(context).colorScheme)),
        borderRadius: BorderRadius.circular(Arcane.radiusControl),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration.collapsed(
          hintText: placeholder ?? 'Enter',
        ),
        onChanged: onChanged,
      ),
    );
  }
}
