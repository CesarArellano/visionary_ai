import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0D2B6E);
  static const Color primaryVariant = Color(0xFF1A4BAA);
  static const Color accentColor = Color(0xFF4A9EFF);
  static const Color background = Color(0xFF0A0F1E);
  static const Color surface = Color(0xFF131929);
  static const Color surfaceVariant = Color(0xFF1E2D4A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFFE8EDF5);
  static const Color onSurface = Color(0xFFC5CDD8);
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF4CCEA4);

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primaryVariant,
          secondary: accentColor,
          surface: surface,
          error: error,
          onPrimary: onPrimary,
          onSecondary: onPrimary,
          onSurface: onSurface,
          onError: onPrimary,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: onPrimary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryVariant,
            foregroundColor: onPrimary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryVariant,
          foregroundColor: onPrimary,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: onBackground,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 1.5,
            color: onBackground,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: onSurface,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: onSurface,
          ),
        ),
      );
}