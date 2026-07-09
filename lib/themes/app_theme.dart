import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const headingColor = AppColors.text;

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.aquaDeep,
      brightness: Brightness.light,
      primary: AppColors.aquaDeep,
      secondary: AppColors.teal,
      surface: Colors.white,
    );

    final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: base.textTheme
          .apply(
            bodyColor: AppColors.text,
            displayColor: headingColor,
          )
          .copyWith(
            headlineSmall: base.textTheme.headlineSmall?.copyWith(
              color: headingColor,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
            titleLarge: base.textTheme.titleLarge?.copyWith(
              color: headingColor,
              fontWeight: FontWeight.w700,
            ),
            titleMedium: base.textTheme.titleMedium?.copyWith(
              color: headingColor,
              fontWeight: FontWeight.w700,
            ),
          ),
      cardTheme: const CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dividerColor: AppColors.line,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.aquaDeep,
          foregroundColor: Colors.white,
          iconColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.aquaDeep.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(99),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.aquaText,
          side: BorderSide(color: AppColors.sky.withValues(alpha: 0.7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(99),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.78),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.sky.withValues(alpha: 0.45)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.blue.withValues(alpha: 0.22)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.aqua, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
