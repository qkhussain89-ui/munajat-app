import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:hearth_prayer/components/google_icon.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final dynamic icon; // IconData or Widget
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  Widget _normalizedIcon(BuildContext context, dynamic iconData) {
    // Use a single, identical box for both icons so they match exactly.
    // Chosen to align Apple to the current Google "G" footprint.
    const double iconBox = 17;

    final cs = Theme.of(context).colorScheme;

    if (iconData is GoogleIcon) {
      // Recreate with tint to preserve existing color behavior
      final g = GoogleIcon(size: iconBox, tintColor: cs.primary);
      return SizedBox(
        width: iconBox,
        height: iconBox,
        child: FittedBox(fit: BoxFit.contain, child: g),
      );
    } else if (iconData is IconData) {
      final a = Icon(iconData, color: cs.primary, size: iconBox);
      return SizedBox(
        width: iconBox,
        height: iconBox,
        child: FittedBox(fit: BoxFit.contain, child: a),
      );
    } else if (iconData is Widget) {
      // Fallback for any custom widget icon; wrap and contain
      return SizedBox(
        width: iconBox,
        height: iconBox,
        child: FittedBox(fit: BoxFit.contain, child: iconData),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 54,
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: cs.surface,
          side: BorderSide(color: cs.outline, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: onPressed,
        // Center the whole group: [icon + gap + text]
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _normalizedIcon(context, icon),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: cs.primary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.25,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
