import 'package:flutter/material.dart';

import '../theme/app_style_tokens.dart';

class AppGradientScreenShell extends StatelessWidget {
  const AppGradientScreenShell({
    super.key,
    required this.child,
    this.useSafeArea = true,
  });

  final Widget child;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.screenBackground,
        ),
        child: useSafeArea ? SafeArea(child: child) : child,
      ),
    );
  }
}
