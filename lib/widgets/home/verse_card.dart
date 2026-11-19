import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

class VerseCard extends StatelessWidget {
  final VoidCallback? onMakeDua;

  const VerseCard({
    super.key,
    this.onMakeDua,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final brandTokens = context.brandTokens;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandTokens.border, width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verse to Carry Today',
            style: textTheme.bodySmall?.copyWith(color: brandTokens.textMuted),
          ),
          const SizedBox(height: 12),
          Text(
            '"Call upon Me; I will respond to you."',
            style: textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: colorScheme.onSurface,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 8),
          Text(
            '— Qurʾān 40:60',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onMakeDua ?? () {},
            child: Text(
              'Make duʿā from this →',
              style: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
