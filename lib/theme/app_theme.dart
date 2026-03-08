import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ─── Brand Colours ─────────────────────────────────────────────
  static const Color _primaryIndigo = Color(0xFF6264A7);
  static const Color _accentPurple = Color(0xFF7B83EB);
  static const Color _surfaceDark = Color(0xFF1B1A2E);
  static const Color _cardDark = Color(0xFF252440);
  static const Color _cardDarkAlt = Color(0xFF2D2B50);
  static const Color _textPrimary = Color(0xFFF5F5F9);
  static const Color _textSecondary = Color(0xFFB0AFCF);
  static const Color _divider = Color(0xFF3A3860);
  static const Color _errorRed = Color(0xFFFF6B6B);
  static const Color _successGreen = Color(0xFF4ADE80);

  // ─── Gradient ──────────────────────────────────────────────────
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF6264A7), Color(0xFF7B83EB), Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF252440), Color(0xFF2D2B50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Dark Theme ────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _surfaceDark,
      primaryColor: _primaryIndigo,
      colorScheme: const ColorScheme.dark(
        primary: _primaryIndigo,
        secondary: _accentPurple,
        surface: _cardDark,
        error: _errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textPrimary,
        onError: Colors.white,
      ),
      fontFamily: 'Segoe UI',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: _textPrimary),
      ),
      cardTheme: CardThemeData(
        color: _cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _cardDarkAlt,
        hintStyle: const TextStyle(color: _textSecondary, fontSize: 14),
        labelStyle: const TextStyle(color: _textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _divider.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accentPurple, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryIndigo,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      dividerColor: _divider,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: _textPrimary, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: _textSecondary, height: 1.5),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────
  static Color get surfaceDark => _surfaceDark;
  static Color get cardDark => _cardDark;
  static Color get cardDarkAlt => _cardDarkAlt;
  static Color get textPrimary => _textPrimary;
  static Color get textSecondary => _textSecondary;
  static Color get primaryIndigo => _primaryIndigo;
  static Color get accentPurple => _accentPurple;
  static Color get dividerColor => _divider;
  static Color get errorRed => _errorRed;
  static Color get successGreen => _successGreen;
}
