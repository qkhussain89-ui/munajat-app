import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme.dart';

class CopperCircleIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;

  const CopperCircleIcon({
    Key? key,
    required this.icon,
    this.size = 120,
    this.iconSize = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(DesignTokens.copperStart),
            Color(DesignTokens.copperEnd),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(DesignTokens.copperStart).withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }
}
