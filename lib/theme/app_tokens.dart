import 'package:flutter/material.dart';

/// Light mode colors (from TSX globals.css)
class AppTokensLight {
  // Background & Surfaces
  static const background = Color(0xFFFFFDF9);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFCF6EE);

  // Text Colors
  static const textPrimary = Color(0xFF2C2114);
  static const textSecondary = Color(0xFF5C4A32);
  static const textMuted = Color(0xFF9C886C);

  // Borders & UI Elements
  static const border = Color(0xFFE3D6C6);
  static const copperSolid = Color(0xFFC68A4A);
  static const copperHover = Color(0xFFD49B5E);

  // Copper Gradient (start, mid, end)
  static const copperStart = Color(0xFFE3B675);
  static const copperMid = Color(0xFFD19C5F);
  static const copperEnd = Color(0xFFC1884A);
}

/// Dark mode colors (for future use)
class AppTokensDark {
  static const background = Color(0xFF0A0A0A);
  static const surfaceCard = Color(0xFF141414);
  static const surfaceElevated = Color(0xFF191919);
  static const textPrimary = Color(0xFFF2E7D9);
  static const textSecondary = Color(0xFFC9BBA9);
  static const textMuted = Color(0xFF9E8974);
  static const border = Color(0xFF2A2320);
  static const copperSolid = Color(0xFFC38C5A);
  static const copperHover = Color(0xFFD09966);
  static const copperStart = Color(0xFFC18245);
  static const copperMid = Color(0xFFE2B56F);
  static const copperEnd = Color(0xFFE7D8A6);
}

/// Spacing tokens
class AppTokensSpacing {
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
}

/// Border radius tokens
class AppTokensRadius {
  static const radiusCard = 16.0;
  static const radiusButton = 16.0;
}

/// Typography sizes (in pixels)
class AppTokensTypography {
  static const headerXL = 26.0; // weight 300 for main titles
  static const header = 24.0; // weight 300 for large numbers
  static const headingLarge = 22.0; // weight 400
  static const headingMedium = 20.0; // weight 400
  static const headingSmall = 18.0; // weight 400
  static const body = 16.0; // weight 400 for body text
  static const small = 14.0; // weight 400
  static const micro = 13.0; // weight 300 for subtitle text
  static const xs = 12.0; // weight 400
  static const xxs = 11.0; // weight 300 for labels
}

/// Copper gradient for use in ShaderMask or Paint
LinearGradient copperGradientLight() => const LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    AppTokensLight.copperStart,
    AppTokensLight.copperMid,
    AppTokensLight.copperEnd,
  ],
);

/// Card decoration
BoxDecoration cardDecorationLight({bool isCopperBorder = false, double borderWidth = 1.0}) => BoxDecoration(
  color: AppTokensLight.surfaceCard,
  borderRadius: BorderRadius.circular(AppTokensRadius.radiusCard),
  border: Border.all(
    color: isCopperBorder ? AppTokensLight.copperSolid : AppTokensLight.border,
    width: borderWidth,
  ),
);

/// Dark gradient for Tahajjud card
LinearGradient tahajjudGradient() => const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF1A1A1A),
    Color(0xFF0A0A0A),
  ],
);

// Convenience typedef for light mode
typedef AT = AppTokensLight;
typedef ATSpacing = AppTokensSpacing;
typedef ATRadius = AppTokensRadius;
typedef ATTypography = AppTokensTypography;
