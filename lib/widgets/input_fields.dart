import 'package:flutter/material.dart';

class InputFields extends StatelessWidget {
  const InputFields({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.prefixIcon,
    this.textColor = Colors.white,
    this.hintColor = Colors.white54,
    this.fillColor = const Color(0xFF1C0A4A),
    this.borderColor = const Color(0xFF7C5FDD),
    this.focusedBorderColor,
    this.borderRadius = 8,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Color textColor;
  final Color hintColor;
  final Color fillColor;
  final Color borderColor;
  final Color? focusedBorderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: color),
      );
    }

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor),
        border: border(borderColor),
        enabledBorder: border(borderColor),
        focusedBorder:
            focusedBorderColor == null ? null : border(focusedBorderColor!),
        filled: true,
        fillColor: fillColor,
        prefixIcon: prefixIcon,
      ),
    );
  }
}
