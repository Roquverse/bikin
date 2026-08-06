import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primaryBackground,
      primaryColor: AppColors.accentCta,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentCta,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceElevated,
        background: AppColors.primaryBackground,
        error: AppColors.error,
        onPrimary: AppColors.primaryBackground,
        onSecondary: AppColors.offWhite,
        onSurface: AppColors.offWhite,
        onBackground: AppColors.offWhite,
        onError: AppColors.offWhite,
      ),
      textTheme: AppTextTheme.getTheme(AppColors.offWhite),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.offWhite),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.tertiaryNeutral,
        thickness: 1,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.offWhite,
      primaryColor: AppColors.accentCta,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentCta,
        secondary: AppColors.secondary,
        surface: Colors.white,
        background: AppColors.offWhite,
        error: AppColors.error,
        onPrimary: AppColors.primaryBackground,
        onSecondary: Colors.white,
        onSurface: AppColors.primaryBackground,
        onBackground: AppColors.primaryBackground,
        onError: Colors.white,
      ),
      textTheme: AppTextTheme.getTheme(AppColors.primaryBackground),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.offWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.primaryBackground),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.tertiaryNeutral,
        thickness: 1,
      ),
    );
  }
}
