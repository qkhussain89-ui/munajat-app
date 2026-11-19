import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hearth_prayer/theme/brand_theme.dart';
import 'package:hearth_prayer/components/copper_button.dart';

class IntroLandingScreen extends StatelessWidget {
  final VoidCallback onComplete;
  final bool isLoading;
  const IntroLandingScreen({
    super.key, 
    required this.onComplete,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brandTokens = Theme.of(context).extension<BrandTokens>() ??
        const BrandTokens(
          surfaceElevated: Color(0xFF0A0A0A),
          surfaceAccent: Color(0xFF0A0A0A),
          border: Color(0xFF0A0A0A),
          divider: Color(0xFF0A0A0A),
          textMuted: Color(0xFF0A0A0A),
          copperHover: Color(0xFF0A0A0A),
          copperGradient: LinearGradient(colors: [Color(0xFFC68A4A)]),
          cardShadowLight: BoxShadow(color: Color(0x00000000)),
          cardShadowHoverLight: BoxShadow(color: Color(0x00000000)),
          controlTrackOn: Color(0xFF0A0A0A),
          controlTrackOff: Color(0xFF0A0A0A),
          controlThumb: Color(0xFF0A0A0A),
          controlOutline: Color(0xFF0A0A0A),
        );
    final copper = colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),

                  // ── App Logo Area ──
                  // Bismillah calligraphy text
                  Text(
                    'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Scheherazade New',
                      fontSize: 24,
                      height: 1.6,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // "Munājāt" wordmark with copper gradient
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (rect) =>
                        brandTokens.copperGradient.createShader(rect),
                    child: Text(
                      'Munājāt',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.w100,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // "Dua Studio" sub-wordmark
                  Text(
                    'Dua Studio',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFC9A76E),
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── Value Proposition Row 1 ──
                  _ValuePropRow(
                    icon: Icons.auto_awesome,
                    iconColor: copper,
                    heading: 'The world\'s first AI-powered du\'ā creator',
                    subtitle: 'Your words. Your voice. Guided by the Sunnah.',
                    brandTokens: brandTokens,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: 28),

                  // ── Value Proposition Row 2 ──
                  _ValuePropRow(
                    icon: Icons.language,
                    iconColor: copper,
                    heading: 'Du\'ā in your language',
                    subtitle:
                        'English · العربية · اردو · Türkçe · Bahasa and more',
                    brandTokens: brandTokens,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: 28),

                  // ── Value Proposition Row 3 ──
                  _ValuePropRow(
                    icon: Icons.favorite,
                    iconColor: copper,
                    heading: 'Every du\'ā gives back',
                    subtitle:
                        '10% of revenue goes to charitable causes',
                    brandTokens: brandTokens,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: 32),

                  // ── "Experience it for yourself" heading ──
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (rect) =>
                        brandTokens.copperGradient.createShader(rect),
                    child: Text(
                      'Experience it for yourself',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── CTA Button ──
                  SizedBox(
                    width: double.infinity,
                    child: CopperButton(
                      text: isLoading ? '' : 'Create your first du\'ā — it\'s free',
                      onPressed: isLoading ? null : onComplete,
                      variant: CopperButtonVariant.primary,
                      size: CopperButtonSize.lg,
                      isLoading: isLoading,
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// _ValuePropRow — icon + heading + subtitle
// ─────────────────────────────────────────────
class _ValuePropRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String heading;
  final String subtitle;
  final BrandTokens brandTokens;
  final ColorScheme colorScheme;

  const _ValuePropRow({
    required this.icon,
    required this.iconColor,
    required this.heading,
    required this.subtitle,
    required this.brandTokens,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 22, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (rect) =>
                    brandTokens.copperGradient.createShader(rect),
                child: Text(
                  heading,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.secondary.withValues(alpha: 0.65),
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// _GradientText — UNCHANGED (preserved for other code)
// ─────────────────────────────────────────────
class _GradientText extends StatelessWidget {
  final String text;

  const _GradientText({required this.text});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFB87333), Color(0xFFFFD9A0)],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.w300,
          color: Colors.white,
          height: 1.3,
          letterSpacing: 0.01,
        ),
      ),
    );
  }
}
