import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

class SnapshotCard extends StatelessWidget {
  const SnapshotCard({super.key});

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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Barakah Snapshot',
            style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SnapshotLine(
                text: 'You whispered 5 duʿās today.',
              ),
              const SizedBox(height: 8),
              _SnapshotLine(
                text: 'You read 6 verses.',
              ),
              const SizedBox(height: 8),
              _SnapshotLine(
                text: 'You remembered Allah after Fajr.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              // No-op for now
            },
            child: Text(
              'See my journey →',
              style: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotLine extends StatelessWidget {
  final String text;

  const _SnapshotLine({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final brandTokens = context.brandTokens;
    return Text(
      text,
      style: textTheme.bodyMedium?.copyWith(
        height: 1.5,
        color: brandTokens.textMuted,
      ),
      softWrap: true,
    );
  }
}
