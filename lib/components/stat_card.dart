import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hearth_prayer/theme.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;
  final double? progress;

  const StatCard({
    Key? key,
    required this.icon,
    required this.number,
    required this.label,
    this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Color(DesignTokens.copperStart),
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: secondaryColor,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: secondaryColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(DesignTokens.copperStart),
                ),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
