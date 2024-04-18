import 'package:flutter/material.dart';

class AntFormItem extends StatelessWidget {
  const AntFormItem({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            alignment: Alignment.centerRight,
            width: 96,
            child: Text(label, textAlign: TextAlign.end),
          ),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}
