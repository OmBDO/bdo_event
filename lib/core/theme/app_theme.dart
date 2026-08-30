import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light({bool highContrast = false}) => ThemeData(
    brightness: Brightness.light,
    colorScheme: highContrast
        ? const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
            secondary: Colors.black,
            onSecondary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          )
        : const ColorScheme.light(
            primary: AppColors.primaryLight,
            onPrimary: Colors.white,
            secondary: AppColors.secondaryLight,
            onSecondary: Colors.white,
            tertiary: AppColors.tertiaryLight,
            onTertiary: Colors.white,
            surface: AppColors.surfaceLight,
            onSurface: AppColors.onSurfaceLight,
            error: Color(0xFFBA1A1A),
            onError: Colors.white,
          ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
  );

  static ThemeData dark({bool highContrast = false}) => ThemeData(
    brightness: Brightness.dark,
    colorScheme: highContrast
        ? const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            secondary: Colors.white,
            onSecondary: Colors.black,
            surface: Colors.black,
            onSurface: Colors.white,
          )
        : const ColorScheme.dark(
            primary: AppColors.primaryDark,
            onPrimary: Colors.black,
            secondary: AppColors.secondaryDark,
            onSecondary: Colors.black,
            tertiary: AppColors.tertiaryDark,
            onTertiary: Colors.black,
            surface: AppColors.surfaceDark,
            onSurface: AppColors.onSurfaceDark,
            error: Color(0xFFFFB4AB),
            onError: Color(0xFF690005),
          ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
  );
}