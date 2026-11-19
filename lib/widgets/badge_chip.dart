import 'package:flutter/material.dart';

enum BadgeChipVariant { defaultStyle, secondary }

class BadgeChip extends StatelessWidget {
  final String label;
  final BadgeChipVariant variant;
  final VoidCallback? onPressed;
  final bool selected;
  final int? count;

  const BadgeChip({
    required this.label,
    this.variant = BadgeChipVariant.defaultStyle,
    this.onPressed,
    this.selected = false,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final outline = theme.colorScheme.outline;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: variant == BadgeChipVariant.secondary ? primary : Colors.white,
          ),
        ),
      ],
    );

    if (variant == BadgeChipVariant.defaultStyle) {
      return Container(
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withValues(alpha: 0.3)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: content,
      );
    } else {
      return GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? surface.withValues(alpha: 0.8) : surface,
            border: Border.all(
              color: selected ? primary : outline,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: content,
        ),
      );
    }
  }
}
