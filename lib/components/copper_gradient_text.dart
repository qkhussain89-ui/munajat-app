import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hearth_prayer/theme.dart';

class CopperGradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  const CopperGradientText(
    this.text, {
    Key? key,
    this.fontSize = 42,
    this.fontWeight = FontWeight.w300,
    this.textAlign = TextAlign.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(DesignTokens.copperStart),
          Color(DesignTokens.copperEnd),
        ],
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white,
        ),
      ),
    );
  }
}
