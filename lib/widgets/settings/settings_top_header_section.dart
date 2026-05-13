import 'package:flutter/material.dart';

import '../common_top_header_row.dart';

class SettingsTopHeaderSection extends StatelessWidget {
  final VoidCallback onBackPressed;
  final String title;
  final Color textColor;

  const SettingsTopHeaderSection({
    super.key,
    required this.onBackPressed,
    this.title = 'Settings',
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonTopHeaderRow(
          title: title,
          onBackPressed: onBackPressed,
          backIconColor: textColor,
          titleStyle: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
