import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class ProgressBar extends StatelessWidget {
  final double progress;

  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        backgroundColor: T.surfaceCard,
        valueColor: AlwaysStoppedAnimation<Color>(T.copperSolid),
      ),
    );
  }
}
