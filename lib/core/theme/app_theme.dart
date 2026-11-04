import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static (String, List<String>) _getFontConfig(Locale locale) {
    switch (locale.languageCode) {
      case 'hi':
        return (
          'Noto Sans Devanagari',
          const ['Inter', 'Noto Sans Gujarati'],
        );
      case 'gu':
        return (
          'Noto Sans Gujarati',
          const ['Inter', 'Noto Sans Devanagari'],
        );
      case 'en':
      default:
        return (
          'Inter',
          const ['Noto Sans Devanagari', 'Noto Sans Gujarati'],
        );
    }
  }

  static ThemeData getLightTheme(Locale locale) {
    final base = ThemeData.light(useMaterial3: true);
    final (fontFamily, fontFallback) = _getFontConfig(locale);

    const colorScheme = ColorScheme.light(
      primary: AppColors.lightPrimary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      error: AppColors.lightDanger,
      outline: AppColors.lightBorder,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: colorScheme,
      textTheme: base.textTheme.apply(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        bodyColor: AppColors.lightText,
        displayColor: AppColors.lightText,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightDanger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AppColors.lightPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          minimumSize: const Size(48, 48),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightBackground,
        selectedItemColor: AppColors.lightPrimary,
        unselectedItemColor: AppColors.lightMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData getDarkTheme(Locale locale) {
    final base = ThemeData.dark(useMaterial3: true);
    final (fontFamily, fontFallback) = _getFontConfig(locale);

    const colorScheme = ColorScheme.dark(
      primary: AppColors.darkPrimary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      error: AppColors.lightDanger,
      outline: AppColors.darkBorder,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: colorScheme,
      textTheme: base.textTheme.apply(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        bodyColor: AppColors.darkText,
        displayColor: AppColors.darkText,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightDanger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkBackground,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AppColors.darkPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          minimumSize: const Size(48, 48),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
