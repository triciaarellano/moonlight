import 'package:flutter/material.dart';

class CommonTopHeaderRow extends StatelessWidget {
  const CommonTopHeaderRow({
    super.key,
    required this.title,
    this.leading,
    this.onBackPressed,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.titleStyle,
    this.backIconColor = Colors.white,
    this.leadingSpacing = 10,
  });

  final String title;
  final Widget? leading;
  final VoidCallback? onBackPressed;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final Color backIconColor;
  final double leadingSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (onBackPressed != null) ...[
            IconButton(
              icon: Icon(Icons.arrow_back, color: backIconColor, size: 24),
              onPressed: onBackPressed,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
          ],
          if (leading != null) ...[
            leading!,
            SizedBox(width: leadingSpacing),
          ],
          Expanded(
            child: Text(
              title,
              style: titleStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
