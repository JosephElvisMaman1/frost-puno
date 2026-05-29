import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.mutedTeal,
      brightness: Brightness.light,
      primary: AppColors.deepNavy,
      secondary: AppColors.mutedTeal,
      tertiary: AppColors.iceBlue,
      error: AppColors.warmAmber,
      surface: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme:
          const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
            titleMedium: TextStyle(
              fontSize: 18,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
            labelSmall: TextStyle(
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ).apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.softWhite,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.mutedTeal),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.mutedTeal),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.deepNavy, width: 1.4),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      ),
    );
  }
}
