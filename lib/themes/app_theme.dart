import 'package:flutter/material.dart';
import 'app_colors.dart';


class AppTheme {
  AppTheme._();

  static const headingColor = Color(0xFF1F4568);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.light,
      primary: AppColors.blue,
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
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
            titleLarge: base.textTheme.titleLarge?.copyWith(
              color: headingColor,
              fontWeight: FontWeight.w600,
            ),
            titleMedium: base.textTheme.titleMedium?.copyWith(
              color: headingColor,
              fontWeight: FontWeight.w600,
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
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          iconColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.blue.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: AppColors.blue.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
