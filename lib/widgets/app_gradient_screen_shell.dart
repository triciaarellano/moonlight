import 'package:flutter/material.dart';

import '../theme/app_style_tokens.dart';

class AppGradientScreenShell extends StatelessWidget {
  const AppGradientScreenShell({
    super.key,
    required this.child,
    this.useSafeArea = true,
    this.gradient = AppGradients.screenBackground,
  });

  final Widget child;
  final bool useSafeArea;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
        ),
        child: useSafeArea ? SafeArea(child: child) : child,
      ),
    );
  }
}
