import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class AppScreenPalette {
  const AppScreenPalette({
    required this.isDay,
    required this.background,
    required this.gradient,
    required this.systemOverlayStyle,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.inactiveText,
    required this.surface,
    required this.cardSurface,
    required this.modalSurface,
    required this.cardBorder,
    required this.accent,
    required this.accentAlt,
    required this.accentSoft,
    required this.accentText,
    required this.onAccent,
    required this.destructive,
  });

  final bool isDay;
  final Color background;
  final LinearGradient gradient;
  final SystemUiOverlayStyle systemOverlayStyle;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color inactiveText;
  final Color surface;
  final Color cardSurface;
  final Color modalSurface;
  final Color cardBorder;
  final Color accent;
  final Color accentAlt;
  final Color accentSoft;
  final Color accentText;
  final Color onAccent;
  final Color destructive;

  factory AppScreenPalette.fromIsDay(bool isDay) {
    return isDay ? AppScreenPalette.day() : AppScreenPalette.night();
  }

  factory AppScreenPalette.day() {
    return AppScreenPalette(
      isDay: true,
      background: const Color(0xFFFFF1D5),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFDFA3),
          Color(0xFFFFF8EA),
          Color(0xFFFFC48A),
        ],
        stops: [0.0, 0.52, 1.0],
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFFFFF1D5),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      primaryText: const Color(0xFF352112),
      secondaryText: const Color(0xFF725039),
      mutedText: const Color(0xFF9B7358),
      inactiveText: const Color(0xFFB58A68),
      surface: const Color(0xFFFFE5BF).withValues(alpha: 0.82),
      cardSurface: const Color(0xFFFFFAEF).withValues(alpha: 0.88),
      modalSurface: const Color(0xFFFFFAEF),
      cardBorder: const Color(0xFFE99543).withValues(alpha: 0.34),
      accent: const Color(0xFFE9742A),
      accentAlt: const Color(0xFFFFB545),
      accentSoft: const Color(0xFFFFD18B).withValues(alpha: 0.5),
      accentText: const Color(0xFF9B4214),
      onAccent: Colors.white,
      destructive: const Color(0xFFB3261E),
    );
  }

  factory AppScreenPalette.night() {
    return AppScreenPalette(
      isDay: false,
      background: AppColors.background,
      gradient: AppGradients.screenBackground,
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      primaryText: Colors.white,
      secondaryText: const Color(0xFFD7D0E9),
      mutedText: const Color(0xFFA59BB8),
      inactiveText: const Color(0xFF746B86),
      surface: AppColors.surface,
      cardSurface: AppColors.cardSurface.withValues(alpha: 0.7),
      modalSurface: AppColors.modalSurface,
      cardBorder: AppColors.accent.withValues(alpha: 0.2),
      accent: AppColors.accent,
      accentAlt: AppColors.label,
      accentSoft: AppColors.accent.withValues(alpha: 0.22),
      accentText: const Color(0xFFE5DFFF),
      onAccent: Colors.white,
      destructive: Colors.red,
    );
  }
}
