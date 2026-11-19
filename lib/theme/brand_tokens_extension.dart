import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/brand_theme.dart';

/// Extension to easily access BrandTokens from any BuildContext
extension BrandTokensExt on BuildContext {
  BrandTokens get brandTokens => Theme.of(this).extension<BrandTokens>()!;
}
