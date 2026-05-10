import 'package:flutter/material.dart';

import '../common_top_header_row.dart';

class SettingsTopHeaderSection extends StatelessWidget {
  final VoidCallback onBackPressed;

  const SettingsTopHeaderSection({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonTopHeaderRow(
          title: 'Settings',
          onBackPressed: onBackPressed,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
