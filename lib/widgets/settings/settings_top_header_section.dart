import 'package:flutter/material.dart';

import '../common_top_header_row.dart';

class SettingsTopHeaderSection extends StatelessWidget {
  final VoidCallback onBackPressed;
  final String title;

  const SettingsTopHeaderSection({
    super.key,
    required this.onBackPressed,
    this.title = 'Settings',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonTopHeaderRow(
          title: title,
          onBackPressed: onBackPressed,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
