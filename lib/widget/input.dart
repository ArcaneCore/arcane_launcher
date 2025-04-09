import 'package:flutter/material.dart';

class AntInput extends StatelessWidget {
  const AntInput({
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final shadow = colorScheme.shadow.withValues(alpha: 0.125);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: shadow),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration.collapsed(
          hintText: placeholder ?? '请输入',
        ),
        onChanged: onChanged,
      ),
    );
  }
}
