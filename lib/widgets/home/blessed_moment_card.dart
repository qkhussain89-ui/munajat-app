import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

class BlessedMomentCard extends StatelessWidget {
  final String title;
  final String daysRemaining;
  final String virtue;
  final String source;

  const BlessedMomentCard({
    super.key,
    required this.title,
    required this.daysRemaining,
    required this.virtue,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final brandTokens = context.brandTokens;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandTokens.border, width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.surface, brandTokens.surfaceElevated],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                daysRemaining,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                virtue,
                style: textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  color: brandTokens.textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                source,
                style: textTheme.labelSmall?.copyWith(
                  color: brandTokens.textMuted.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Learn more →',
            style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
