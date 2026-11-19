import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hearth_prayer/theme/tokens.dart';

class AppColorsLight {
  static const background = Color(0xFFFFFDF9);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFCF6EE);
  static const surfaceAccent = Color(0xFFF7EADA);
  static const textPrimary = Color(0xFF2C2114);
  static const textSecondary = Color(0xFF5C4A32);
  static const textMuted = Color(0xFF9C886C);
  static const border = Color(0xFFE3D6C6);
  static const divider = Color(0xFFE3D6C6);
  static const copperStart = Color(0xFFE3B675);
  static const copperMid = Color(0xFFD19C5F);
  static const copperEnd = Color(0xFFC1884A);
  static const copperSolid = Color(0xFFC68A4A);
  static const copperHover = Color(0xFFD49B5E);
}

class AppColorsDark {
  static const background = Color(0xFF0A0A0A);
  static const surfaceCard = Color(0xFF141414);
  static const surfaceElevated = Color(0xFF191919);
  static const surfaceAccent = Color(0xFF161616);
  static const textPrimary = Color(0xFFF2E7D9);
  static const textSecondary = Color(0xFFC9BBA9);
  static const textMuted = Color(0xFF9E8974);
  static const border = Color(0xFF2A2320);
  static const divider = Color(0xFF2A2320);
  static const copperStart = Color(0xFFC18245);
  static const copperMid = Color(0xFFE2B56F);
  static const copperEnd = Color(0xFFE7D8A6);
  static const copperSolid = Color(0xFFC38C5A);
  static const copperHover = Color(0xFFD09966);
  static const badgeStart = Color(0xFFC28A4A);
  static const badgeEnd = Color(0xFFE1C18B);
  static const btnOutline = Color(0xFF2A2A2A);
  static const btnBg = Color(0xFF0E0E0E);
  static const goldText = Color(0xFFB98B4D);
}

LinearGradient copperGradient(Brightness b) {
  final dark = b == Brightness.dark;
  return LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: dark
        ? const [AppColorsDark.copperStart, AppColorsDark.copperMid, AppColorsDark.copperEnd]
        : const [AppColorsLight.copperStart, AppColorsLight.copperMid, AppColorsLight.copperEnd],
  );
}

LinearGradient badgeGradient() => const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColorsDark.badgeStart, AppColorsDark.badgeEnd],
);

ThemeData buildAppTheme(Brightness b) {
  final dark = b == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: dark ? AppTok.bg : AppColorsLight.background,
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      titleLarge: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w300,
        height: 1.3,
        color: dark ? AppTok.textPrimary : AppColorsLight.textPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: dark ? AppTok.textPrimary : AppColorsLight.textPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: dark ? AppTok.textPrimary : AppColorsLight.textPrimary,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: dark ? AppTok.textSecondary : AppColorsLight.textSecondary,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w300,
        color: dark ? AppTok.textMuted : AppColorsLight.textMuted,
      ),
    ),
    dividerColor: dark ? AppTok.border : AppColorsLight.divider,
    cardColor: dark ? AppTok.card : AppColorsLight.surfaceCard,
    iconTheme: IconThemeData(
      color: dark ? AppTok.textMuted : AppColorsLight.textMuted,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: (dark ? AppTok.bg : AppColorsLight.background).withValues(alpha: 0.8),
      foregroundColor: dark ? AppTok.textPrimary : AppColorsLight.textPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? AppTok.card : AppColorsLight.surfaceCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: dark ? AppTok.border : AppColorsLight.border,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: dark ? AppTok.border : AppColorsLight.border,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: dark ? AppTok.copperSolid : AppColorsLight.copperSolid,
          width: 2,
        ),
      ),
    ),
  );
}

// Design Tokens - Production Ready (legacy)
class DesignTokens {
  static const int copperStart = 0xFFB87333;
  static const int copperEnd = 0xFFFFD9A0;
  static const int darkBg = 0xFF0A0A0A;
  static const int darkSurface = 0xFF151515;
  static const int darkCard = 0xFF1C1C1C;
  static const int textPrimaryDark = 0xFFF3E7C1;
  static const int textSecondaryDark = 0xFFB8AA8C;
  static const int lightBg = 0xFFF9F7F2;
  static const int lightSurface = 0xFFFFFFFF;
  static const int lightCard = 0xFFF3EFE7;
  static const int textPrimaryLight = 0xFF2A2318;
  static const int textSecondaryLight = 0xFF5C4F3A;
  static const double spacing24 = 24.0;
  static const double radiusXL = 24.0;
}

// Legacy support
class AppColors {
  // New palette
  static const textPrimaryDark = AppColorsDark.textPrimary;
  static const textSecondaryDark = AppColorsDark.textSecondary;
  static const textPrimaryLight = AppColorsLight.textPrimary;
  static const textSecondaryLight = AppColorsLight.textSecondary;
  static const darkCard = Color(0xFF191919);
  static const lightCard = Color(0xFFFCF6EE);
  static const darkSurface = Color(0xFF141414);
  static const lightSurface = Color(0xFFFFFFFF);

  // Copper-Gold
  static const Color copper = Color(0xFFB87333);
  static const Color copperLight = Color(0xFFE3B675);
  static const Color copperDark = Color(0xFF8B5A2B);
  static const Color gradientStart = Color(0xFFB87333);
  static const Color gradientMiddle = Color(0xFFD19C5F);
  static const Color gradientEnd = Color(0xFFFFD9A0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color lightError = Color(0xFFBA1A1A);
  static const Color darkBg = Color(0xFF0A0A0A);
  static const Color lightBg = Color(0xFFFFFDF9);
}

ThemeData get lightTheme => buildAppTheme(Brightness.light);
ThemeData get darkTheme => buildAppTheme(Brightness.dark);
