import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String countdown;
  final String quote;
  final String ref;
  final IconData icon;

  const EventCard({
    super.key,
    required this.title,
    required this.countdown,
    required this.quote,
    required this.ref,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(T.rCard),
        border: Border.all(color: T.border, width: 1),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [T.surfaceCard, T.surfaceElevated],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w400, color: T.textPrimary)),
              Icon(icon, size: 20, color: T.copperSolid),
            ],
          ),
          const SizedBox(height: 8),
          Text(countdown,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: T.copperSolid,
              )),
          const SizedBox(height: 12),
          Text(
            quote,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              color: T.textSecondary.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text("— $ref",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w300,
                color: T.textMuted.withValues(alpha: 0.7),
              )),
        ],
      ),
    );
  }
}
