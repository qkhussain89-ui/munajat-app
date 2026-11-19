import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// BrandTokens: Centralized theme extension for brand colors not in standard ColorScheme
class BrandTokens extends ThemeExtension<BrandTokens> {
  final Color surfaceElevated;
  final Color surfaceAccent;
  final Color border;
  final Color divider;
  final Color textMuted;
  final Color copperHover;
  final LinearGradient copperGradient;
  final BoxShadow cardShadowLight;
  final BoxShadow cardShadowHoverLight;
  final Color controlTrackOn;
  final Color controlTrackOff;
  final Color controlThumb;
  final Color controlOutline;

  const BrandTokens({
    required this.surfaceElevated,
    required this.surfaceAccent,
    required this.border,
    required this.divider,
    required this.textMuted,
    required this.copperHover,
    required this.copperGradient,
    required this.cardShadowLight,
    required this.cardShadowHoverLight,
    required this.controlTrackOn,
    required this.controlTrackOff,
    required this.controlThumb,
    required this.controlOutline,
  });

  @override
  ThemeExtension<BrandTokens> copyWith({
    Color? surfaceElevated,
    Color? surfaceAccent,
    Color? border,
    Color? divider,
    Color? textMuted,
    Color? copperHover,
    LinearGradient? copperGradient,
    BoxShadow? cardShadowLight,
    BoxShadow? cardShadowHoverLight,
    Color? controlTrackOn,
    Color? controlTrackOff,
    Color? controlThumb,
    Color? controlOutline,
  }) =>
      BrandTokens(
        surfaceElevated: surfaceElevated ?? this.surfaceElevated,
        surfaceAccent: surfaceAccent ?? this.surfaceAccent,
        border: border ?? this.border,
        divider: divider ?? this.divider,
        textMuted: textMuted ?? this.textMuted,
        copperHover: copperHover ?? this.copperHover,
        copperGradient: copperGradient ?? this.copperGradient,
        cardShadowLight: cardShadowLight ?? this.cardShadowLight,
        cardShadowHoverLight: cardShadowHoverLight ?? this.cardShadowHoverLight,
        controlTrackOn: controlTrackOn ?? this.controlTrackOn,
        controlTrackOff: controlTrackOff ?? this.controlTrackOff,
        controlThumb: controlThumb ?? this.controlThumb,
        controlOutline: controlOutline ?? this.controlOutline,
      );

  @override
  ThemeExtension<BrandTokens> lerp(covariant ThemeExtension<BrandTokens>? other, double t) {
    if (other is! BrandTokens) return this;
    return BrandTokens(
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t) ?? surfaceElevated,
      surfaceAccent: Color.lerp(surfaceAccent, other.surfaceAccent, t) ?? surfaceAccent,
      border: Color.lerp(border, other.border, t) ?? border,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      copperHover: Color.lerp(copperHover, other.copperHover, t) ?? copperHover,
      copperGradient: LinearGradient.lerp(copperGradient, other.copperGradient, t) ?? copperGradient,
      cardShadowLight: BoxShadow.lerp(cardShadowLight, other.cardShadowLight, t) ?? cardShadowLight,
      cardShadowHoverLight: BoxShadow.lerp(cardShadowHoverLight, other.cardShadowHoverLight, t) ?? cardShadowHoverLight,
      controlTrackOn: Color.lerp(controlTrackOn, other.controlTrackOn, t) ?? controlTrackOn,
      controlTrackOff: Color.lerp(controlTrackOff, other.controlTrackOff, t) ?? controlTrackOff,
      controlThumb: Color.lerp(controlThumb, other.controlThumb, t) ?? controlThumb,
      controlOutline: Color.lerp(controlOutline, other.controlOutline, t) ?? controlOutline,
    );
  }
}

/// Unified theme system with Light and Dark variants
class BrandTheme {
  // Light Mode Palette
  static const _lightBackground = Color(0xFFFFFDF9);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightSurfaceElevated = Color(0xFFFCF6EE);
  static const _lightSurfaceAccent = Color(0xFFF7EADA);
  static const _lightPrimary = Color(0xFFC68A4A);
  static const _lightSecondary = Color(0xFF5C4A32);
  static const _lightOnSecondary = Color(0xFF2C2114);
  static const _lightOnPrimary = Color(0xFFFFFFFF);
  static const _lightOnBackground = Color(0xFF2C2114);
  static const _lightOnSurface = Color(0xFF2C2114);
  static const _lightOutline = Color(0xFFE3D6C6);
  static const _lightBorder = Color(0xFFE3D6C6);
  static const _lightDivider = Color(0xFFE3D6C6);
  static const _lightTextMuted = Color(0xFF9C886C);
  static const _lightCopperHover = Color(0xFFD49B5E);
  static const _lightError = Color(0xFFE26262);
  static const _lightControlTrackOn = Color(0xFFC68A4A);
  static const _lightControlTrackOff = Color(0xFFE9DFD2);
  static const _lightControlThumb = Color(0xFFFFFFFF);
  static const _lightControlOutline = Color(0xFFC9B28D);

  // Dark Mode Palette
  static const _darkBackground = Color(0xFF0A0A0A);
  static const _darkSurface = Color(0xFF141414);
  static const _darkSurfaceElevated = Color(0xFF191919);
  static const _darkSurfaceAccent = Color(0xFF161616);
  static const _darkPrimary = Color(0xFFC38C5A);
  static const _darkSecondary = Color(0xFFC9BBA9);
  static const _darkOnSecondary = Color(0xFF0A0A0A);
  static const _darkOnPrimary = Color(0xFFFFFFFF);
  static const _darkOnBackground = Color(0xFFF2E7D9);
  static const _darkOnSurface = Color(0xFFF2E7D9);
  static const _darkOutline = Color(0xFF2A2320);
  static const _darkBorder = Color(0xFF2A2320);
  static const _darkDivider = Color(0xFF2A2320);
  static const _darkTextMuted = Color(0xFF9E8974);
  static const _darkCopperHover = Color(0xFFD09966);
  static const _darkError = Color(0xFFE26262);
  static const _darkControlTrackOn = Color(0xFFC38C5A);
  static const _darkControlTrackOff = Color(0xFF2A2320);
  static const _darkControlThumb = Color(0xFF0A0A0A);
  static const _darkControlOutline = Color(0xFF3A2F24);

  // Copper Gradient (Light)
  static const _lightCopperStart = Color(0xFFE3B675);
  static const _lightCopperMid = Color(0xFFD19C5F);
  static const _lightCopperEnd = Color(0xFFC1884A);

  // Copper Gradient (Dark)
  static const _darkCopperStart = Color(0xFFC18245);
  static const _darkCopperMid = Color(0xFFE2B56F);
  static const _darkCopperEnd = Color(0xFFE7D8A6);

  // Card Shadows (Light mode only)
  static const _lightCardShadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );
  static const _lightCardShadowHover = BoxShadow(
    color: Color(0x19000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static ThemeData light() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      background: _lightBackground,
      onBackground: _lightOnBackground,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      secondary: _lightSecondary,
      onSecondary: _lightOnSecondary,
      error: _lightError,
      onError: Colors.white,
      outline: _lightOutline,
      surfaceContainerHighest: _lightSurfaceElevated,
      surfaceContainerLowest: _lightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBackground,
      textTheme: _buildLightTextTheme(_lightOnSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightBackground.withValues(alpha: 0.9),
        foregroundColor: _lightOnSurface,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _lightBorder),
        ),
        elevation: 1,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        hintStyle: const TextStyle(color: _lightTextMuted),
      ),
      dividerColor: _lightDivider,
      extensions: [
        BrandTokens(
          surfaceElevated: _lightSurfaceElevated,
          surfaceAccent: _lightSurfaceAccent,
          border: _lightBorder,
          divider: _lightDivider,
          textMuted: _lightTextMuted,
          copperHover: _lightCopperHover,
          copperGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_lightCopperStart, _lightCopperMid, _lightCopperEnd],
            stops: [0.0, 0.5, 1.0],
          ),
          cardShadowLight: _lightCardShadow,
          cardShadowHoverLight: _lightCardShadowHover,
          controlTrackOn: _lightControlTrackOn,
          controlTrackOff: _lightControlTrackOff,
          controlThumb: _lightControlThumb,
          controlOutline: _lightControlOutline,
        ),
      ],
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      background: _darkBackground,
      onBackground: _darkOnBackground,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      secondary: _darkSecondary,
      onSecondary: _darkOnSecondary,
      error: _darkError,
      onError: Colors.white,
      outline: _darkOutline,
      surfaceContainerHighest: _darkSurfaceElevated,
      surfaceContainerLowest: _darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground,
      textTheme: _buildDarkTextTheme(_darkOnSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBackground.withValues(alpha: 0.9),
        foregroundColor: _darkOnSurface,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _darkBorder),
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        hintStyle: const TextStyle(color: _darkTextMuted),
      ),
      dividerColor: _darkDivider,
      extensions: [
        BrandTokens(
          surfaceElevated: _darkSurfaceElevated,
          surfaceAccent: _darkSurfaceAccent,
          border: _darkBorder,
          divider: _darkDivider,
          textMuted: _darkTextMuted,
          copperHover: _darkCopperHover,
          copperGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_darkCopperStart, _darkCopperMid, _darkCopperEnd],
            stops: [0.0, 0.5, 1.0],
          ),
          cardShadowLight: const BoxShadow(color: Colors.transparent),
          cardShadowHoverLight: const BoxShadow(color: Colors.transparent),
          controlTrackOn: _darkControlTrackOn,
          controlTrackOff: _darkControlTrackOff,
          controlThumb: _darkControlThumb,
          controlOutline: _darkControlOutline,
        ),
      ],
    );
  }

  static TextTheme _buildLightTextTheme(Color textColor) => TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 32,
          fontWeight: FontWeight.w300,
          height: 1.3,
          color: textColor,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 28,
          fontWeight: FontWeight.w300,
          height: 1.4,
          color: textColor,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w300,
          height: 1.4,
          color: textColor,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 26,
          fontWeight: FontWeight.w300,
          height: 1.3,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: textColor,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: textColor,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: textColor,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: textColor,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: textColor,
        ),
      );

  static TextTheme _buildDarkTextTheme(Color textColor) => TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 32,
          fontWeight: FontWeight.w300,
          height: 1.3,
          color: textColor,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 28,
          fontWeight: FontWeight.w300,
          height: 1.4,
          color: textColor,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w300,
          height: 1.4,
          color: textColor,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 26,
          fontWeight: FontWeight.w300,
          height: 1.3,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: textColor,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: textColor,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: textColor,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: textColor,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: textColor,
        ),
      );
}
