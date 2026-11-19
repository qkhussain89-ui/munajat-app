import 'package:flutter/material.dart';

class AppTheme {
  static const _light = _BrandColors(
    background: Color(0xFFFFFDF9),
    surfaceCard: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFCF6EE),
    textPrimary: Color(0xFF2C2114),
    textSecondary: Color(0xFF5C4A32),
    textMuted: Color(0xFF9C886C),
    copperSolid: Color(0xFFC68A4A),
    copperHover: Color(0xFFD49B5E),
    border: Color(0xFFE3D6C6),
  );

  static const _dark = _BrandColors(
    background: Color(0xFF0A0A0A),
    surfaceCard: Color(0xFF141414),
    surfaceElevated: Color(0xFF191919),
    textPrimary: Color(0xFFF2E7D9),
    textSecondary: Color(0xFFC9BBA9),
    textMuted: Color(0xFF9E8974),
    copperSolid: Color(0xFFC38C5A),
    copperHover: Color(0xFFD09966),
    border: Color(0xFF2A2320),
  );

  static ThemeData light() => _themeFrom(_light, Brightness.light);
  static ThemeData dark() => _themeFrom(_dark, Brightness.dark);

  static ThemeData _themeFrom(_BrandColors c, Brightness b) {
    final colorScheme = ColorScheme(
      brightness: b,
      primary: c.copperSolid,
      onPrimary: Colors.white,
      secondary: c.textSecondary,
      onSecondary: c.textPrimary,
      surface: c.surfaceCard,
      onSurface: c.textPrimary,
      error: const Color(0xFFE26262),
      onError: Colors.white,
      tertiary: c.surfaceElevated,
      onTertiary: c.textPrimary,
      primaryContainer: c.copperHover,
      onPrimaryContainer: Colors.white,
      secondaryContainer: c.surfaceElevated,
      onSecondaryContainer: c.textPrimary,
      surfaceContainerHighest: c.surfaceElevated,
      surfaceContainerLowest: c.surfaceCard,
      outline: c.border,
    );

    final textTheme = TextTheme(
      bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0.25, color: c.textPrimary),
      bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: c.textPrimary),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: c.textPrimary),
      headlineSmall: TextStyle(fontSize: 26, fontWeight: FontWeight.w300, letterSpacing: 0.2, color: c.textPrimary),
      displayMedium: TextStyle(color: c.textPrimary),
      displaySmall: TextStyle(color: c.textPrimary),
      headlineMedium: TextStyle(color: c.textPrimary),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: c.background.withValues(alpha: 0.9),
        foregroundColor: c.textPrimary,
        elevation: 0,
      ),
      dividerColor: c.border,
      cardTheme: CardThemeData(
        color: c.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: c.border)),
        elevation: b == Brightness.light ? 1 : 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: b == Brightness.light ? Colors.white : c.surfaceCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.copperSolid, width: 2),
        ),
      ),
    );
  }
}

class _BrandColors {
  final Color background, surfaceCard, surfaceElevated, textPrimary, textSecondary, textMuted, copperSolid, copperHover, border;
  const _BrandColors({
    required this.background,
    required this.surfaceCard,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.copperSolid,
    required this.copperHover,
    required this.border,
  });
}
