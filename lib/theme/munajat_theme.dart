import 'package:flutter/material.dart';

class CopperGradient extends ThemeExtension<CopperGradient> {
  final Color start;
  final Color mid;
  final Color end;
  final Color solid;

  const CopperGradient({
    required this.start,
    required this.mid,
    required this.end,
    required this.solid,
  });

  LinearGradient get copperGradient => LinearGradient(
    colors: [start, mid, end],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  ThemeExtension<CopperGradient> copyWith({
    Color? start,
    Color? mid,
    Color? end,
    Color? solid,
  }) =>
    CopperGradient(
      start: start ?? this.start,
      mid: mid ?? this.mid,
      end: end ?? this.end,
      solid: solid ?? this.solid,
    );

  @override
  ThemeExtension<CopperGradient> lerp(
    ThemeExtension<CopperGradient>? other,
    double t,
  ) {
    if (other is! CopperGradient) return this;
    return CopperGradient(
      start: Color.lerp(start, other.start, t) ?? start,
      mid: Color.lerp(mid, other.mid, t) ?? mid,
      end: Color.lerp(end, other.end, t) ?? end,
      solid: Color.lerp(solid, other.solid, t) ?? solid,
    );
  }
}

class MunajatTheme {
  static const _copperStart = Color(0xFFC18245);
  static const _copperMid = Color(0xFFE2B56F);
  static const _copperEnd = Color(0xFFE7D8A6);
  static const _copperSolid = Color(0xFFC38C5A);

  static const _darkBackground = Color(0xFF0A0A0A);
  static const _darkSurfaceCard = Color(0xFF141414);
  static const _darkSurfaceElevated = Color(0xFF191919);
  static const _darkTextPrimary = Color(0xFFF2E7D9);
  static const _darkTextSecondary = Color(0xFFC9BBA9);
  static const _darkTextMuted = Color(0xFF9E8974);
  static const _darkBorder = Color(0xFF2A2320);

  static const _lightBackground = Color(0xFFFAF8F5);
  static const _lightSurfaceCard = Color(0xFFFFFBF7);
  static const _lightSurfaceElevated = Color(0xFFFFFFFF);
  static const _lightTextPrimary = Color(0xFF2A2520);
  static const _lightTextSecondary = Color(0xFF6B6259);
  static const _lightTextMuted = Color(0xFF9E8974);
  static const _lightBorder = Color(0xFFE5DDD0);

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _copperSolid,
      onPrimary: Colors.white,
      surface: _lightSurfaceCard,
      surfaceContainerHighest: _lightSurfaceElevated,
      onSurface: _lightTextPrimary,
      onSurfaceVariant: _lightTextSecondary,
      outline: _lightBorder,
      background: _lightBackground,
    ),
    scaffoldBackgroundColor: _lightBackground,
    extensions: [
      CopperGradient(
        start: _copperStart,
        mid: _copperMid,
        end: _copperEnd,
        solid: _copperSolid,
      ),
    ],
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 26,
        fontWeight: FontWeight.w300,
        height: 1.3,
        color: _lightTextPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _lightTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _lightTextSecondary,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: _lightTextMuted,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _copperSolid, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(color: _lightTextMuted),
    ),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _copperSolid,
      onPrimary: Colors.white,
      surface: _darkSurfaceCard,
      surfaceContainerHighest: _darkSurfaceElevated,
      onSurface: _darkTextPrimary,
      onSurfaceVariant: _darkTextSecondary,
      outline: _darkBorder,
      background: _darkBackground,
    ),
    scaffoldBackgroundColor: _darkBackground,
    extensions: [
      CopperGradient(
        start: _copperStart,
        mid: _copperMid,
        end: _copperEnd,
        solid: _copperSolid,
      ),
    ],
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 26,
        fontWeight: FontWeight.w300,
        height: 1.3,
        color: _darkTextPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _darkTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _darkTextSecondary,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: _darkTextMuted,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _copperSolid, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(color: _darkTextMuted),
    ),
  );
}
