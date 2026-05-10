import 'package:flutter/material.dart';

class ModalHeaderRow extends StatelessWidget {
  const ModalHeaderRow({
    super.key,
    required this.title,
    required this.onClose,
    this.titleStyle,
    this.iconColor = Colors.white,
  });

  final String title;
  final VoidCallback onClose;
  final TextStyle? titleStyle;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: titleStyle ??
              const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: iconColor),
          onPressed: onClose,
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
