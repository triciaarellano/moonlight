import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0118);
  static const Color surface = Color(0xFF1C0A4A);
  static const Color cardSurface = Color(0xFF3D1E6F);
  static const Color modalSurface = Color(0xFF2D1265);
  static const Color accent = Color(0xFF7C5FDD);
  static const Color label = Color(0xFFB5A957);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient screenBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.surface,
      AppColors.background,
      AppColors.modalSurface,
    ],
    stops: [0.0, 0.5, 1.0],
  );
}
