import 'package:flutter/material.dart';

class AppTok {
  static const copperStart = Color(0xFFC18245);
  static const copperMid   = Color(0xFFE2B56F);
  static const copperEnd   = Color(0xFFE7D8A6);
  static const copperSolid = Color(0xFFC38C5A);
  static const copperActive = Color(0xFFD09966);

  static const background = Color(0xFF0A0A0A);
  static const bg = background;
  static const surface   = Color(0xFF151515);
  static const surfaceCard = Color(0xFF141414);
  static const surfaceElevated = Color(0xFF191919);
  static const card = surfaceCard;
  static const border    = Color(0xFF2A2320);

  static const textPrimary   = Color(0xFFF2E7D9);
  static const textSecondary = Color(0xFFC9BBA9);
  static const textMuted     = Color(0xFF9E8974);

  static const s16 = 16.0;
  static const rCard = 20.0;

  static BoxDecoration cardDeco = BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: border),
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: border),
  );

  static LinearGradient copperGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [copperStart, copperMid, copperEnd],
    stops: [0.0, 0.5, 1.0],
  );
}

// Alias for convenience
typedef T = AppTok;
