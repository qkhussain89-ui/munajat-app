import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme.dart';

class CrescentBadge extends StatelessWidget {
  const CrescentBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 90,
    height: 90,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: badgeGradient(),
    ),
    alignment: Alignment.center,
    child: const Text(
      '☪',
      style: TextStyle(fontSize: 48, color: Colors.white),
    ),
  );
}
