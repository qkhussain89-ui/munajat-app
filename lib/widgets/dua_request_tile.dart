import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class DuaRequestTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String category;
  final int hearts;

  const DuaRequestTile({
    super.key,
    required this.emoji,
    required this.title,
    required this.category,
    required this.hearts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: T.cardDecoration,
      padding: const EdgeInsets.all(T.s16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: T.surfaceElevated, shape: BoxShape.circle
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w400, color: T.textPrimary),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: T.border),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                          color: T.textMuted.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.favorite_border, size: 14, color: T.textMuted),
                        const SizedBox(width: 4),
                        Text("$hearts",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: T.textSecondary,
                            )),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
