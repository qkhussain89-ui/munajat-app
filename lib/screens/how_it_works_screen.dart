import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

class HowItWorksScreen extends StatefulWidget {
  const HowItWorksScreen({super.key});

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen>
    with SingleTickerProviderStateMixin {
  bool _aExpanded = false;
  bool _bExpanded = false;
  bool _cExpanded = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final brandTokens = context.brandTokens;

    return Scaffold(
      backgroundColor: t.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header row: back button | centered title | spacer (44)
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 22,
                            color: t.colorScheme.secondary,
                          ),
                          onPressed: () => Navigator.of(context).maybePop(),
                          padding: EdgeInsets.zero,
                          tooltip: 'Back',
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: ShaderMask(
                            shaderCallback: (bounds) =>
                                brandTokens.copperGradient.createShader(bounds),
                            child: const Text(
                              'How It Works',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                height: 1.3,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section cards (accordion style)
                _buildSectionCard(
                  title: 'How to Make Duʿāʾ',
                  subtitle:
                      'A simple Sunnah-based guide to making duʿāʾ with adab.',
                  expanded: _aExpanded,
                  onToggle: () => setState(() => _aExpanded = !_aExpanded),
                  child: _buildSectionA(context),
                ),
                const SizedBox(height: 12),
                _buildSectionCard(
                  title: "What Happens When You Tap 'Create Duʿāʾ'",
                  subtitle:
                      'A simple explanation of how the app refines your words.',
                  expanded: _bExpanded,
                  onToggle: () => setState(() => _bExpanded = !_bExpanded),
                  child: _buildSectionB(context),
                ),
                const SizedBox(height: 12),
                _buildSectionCard(
                  title: 'Your Controls',
                  subtitle:
                      'What the options in ‘Refine Your Duʿāʾ’ actually do.',
                  expanded: _cExpanded,
                  onToggle: () => setState(() => _cExpanded = !_cExpanded),
                  child: _buildSectionC(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required bool expanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    final t = Theme.of(context);
    final brandTokens = context.brandTokens;
    final accent = t.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        border: Border.all(color: brandTokens.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            InkWell(
              onTap: onToggle,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header title (no underline per spec)
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: t.colorScheme.onSurface,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: brandTokens.textMuted,
                              fontFamily: 'Poppins',
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 160),
                      turns: expanded ? 0.5 : 0,
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: t.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: child,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubheading(String title) {
    final t = Theme.of(context);
    final accent = t.colorScheme.primary;
    // Color only the label prefix (e.g., "A1) ", "C2) ") in accent
    String prefix = '';
    String rest = title;
    final idx = title.indexOf(')');
    if (idx != -1) {
      prefix = title.substring(0, idx + 1);
      // Preserve any following space without trimming layout-related spacing
      rest = title.substring(idx + 1);
    }
    final baseStyle =
        t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            if (prefix.isNotEmpty)
              TextSpan(text: prefix, style: baseStyle?.copyWith(color: accent)),
            TextSpan(text: rest, style: baseStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildBullets(List<String> items) {
    final t = Theme.of(context);
    final accent = t.colorScheme.primary.withValues(alpha: 0.65);
    // Ensure readable, dark neutral text on all backgrounds (incl. beige card)
    final textStyle = (t.textTheme.bodyMedium ?? const TextStyle())
        .copyWith(color: t.colorScheme.onSurface);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final it in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: RichText(
              text: TextSpan(
                style: textStyle,
                children: [
                  TextSpan(
                      text: '• ', style: textStyle?.copyWith(color: accent)),
                  TextSpan(text: it, style: textStyle),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // SECTION A content
  Widget _buildSectionA(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubheading('A1) The Heart of Duʿāʾ (Core mindset)'),
        _buildBullets([
          'Ikhlāṣ (sincerity) — ask Allah alone',
          'Yaqīn (certainty) — believe Allah responds',
          'Hope + fear — ask with humility',
          'Don’t be hasty — keep making duʿāʾ',
        ]),
        _buildSubheading('A2) The Prophetic Flow (simple steps)'),
        _buildBullets([
          'Praise Allah',
          'Ṣalawāt on the Prophet ﷺ',
          'Call Allah by His Beautiful Names',
          'Istighfār (seek forgiveness)',
          'Ask clearly (big and small)',
          'End with ṣalawāt + Āmīn',
        ]),
        _buildSubheading(
            'A3) What can block barakah / acceptance (gentle reminders)'),
        _buildBullets([
          'Heedless heart / distracted duʿāʾ',
          'Asking for sinful things or cutting family ties',
          'ظلم (oppression)',
          'Ḥarām earnings/food (general reminder)',
        ]),
        _buildSubheading('A4) Examples (short + long)'),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '“Short example”',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text(
                'Yā Allah, forgive me and guide my heart. Āmīn.',
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '“Long example”',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text(
              'Yā Allah, You are Ar-Raḥmān, Ar-Raḥīm. Send ṣalawāt upon our Prophet ﷺ. I seek Your forgiveness for my sins and shortcomings. Grant me guidance, strength, and goodness in my family and Rizq. Accept this from me with Your mercy. Āmīn.',
            ),
          ],
        ),
      ],
    );
  }

  // SECTION B content
  Widget _buildSectionB(BuildContext context) {
    final t = Theme.of(context);
    final brandTokens = context.brandTokens;
    final steps = const [
      'You type or speak what’s on your heart',
      'The app sends your words to the Duʿāʾ Refiner',
      'The refiner follows a Sunnah-based checklist',
      'It rewrites your duʿāʾ in a clearer, structured way',
      'The refined duʿāʾ is returned to your screen',
      'You can save it, copy it, or edit it',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RichText(
                  text: TextSpan(
                    style: t.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '${i + 1}. ',
                        style: t.textTheme.bodyMedium?.copyWith(
                          color: t.colorScheme.primary.withValues(alpha: 0.65),
                        ),
                      ),
                      TextSpan(text: steps[i]),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Trust & Safety block
        Container(
          decoration: BoxDecoration(
            color: brandTokens.surfaceAccent,
            borderRadius: BorderRadius.circular(16),
            // Subtle accent top border; keep other borders unchanged
            border: Border(
              top: BorderSide(color: t.colorScheme.primary, width: 2),
              left: BorderSide(color: brandTokens.border, width: 1),
              right: BorderSide(color: brandTokens.border, width: 1),
              bottom: BorderSide(color: brandTokens.border, width: 1),
            ),
          ),
          padding: const EdgeInsets.all(12),
          // Force explicit foreground paints to avoid any upstream style or
          // shader interference that could result in invisible text. This is
          // scoped strictly to this beige card per guardrails.
          child: Container(
            decoration: BoxDecoration(
              color: brandTokens.surfaceAccent,
              borderRadius: BorderRadius.circular(16),
              // Subtle accent top border; keep other borders unchanged
              border: Border(
                top: BorderSide(color: t.colorScheme.primary, width: 2),
                left: BorderSide(color: brandTokens.border, width: 1),
                right: BorderSide(color: brandTokens.border, width: 1),
                bottom: BorderSide(color: brandTokens.border, width: 1),
              ),
            ),
            padding: const EdgeInsets.all(12),
            // Force explicit foreground paints to avoid any upstream style or
            // shader interference that could result in invisible text. This is
            // scoped strictly to this beige card per guardrails.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trust & Safety',
                  style: (t.textTheme.titleSmall ?? const TextStyle()).copyWith(
                    fontWeight: FontWeight.w600,
                    // Use foreground paint to guarantee painting
                    foreground: Paint()..color = t.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                // Local bullet rendering to ensure explicit paints and prevent
                // any RichText style edge-cases from hiding content.
                for (final it in const [
                  'This is not Qur’an.',
                  'This is not a fatwa.',
                  'It helps you express duʿāʾ with better structure and adab.',
                  'You can always edit the output.',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '•',
                          style: (t.textTheme.bodyMedium ?? const TextStyle())
                              .copyWith(
                            height: 1.5,
                            foreground: Paint()
                              ..color =
                                  t.colorScheme.primary.withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            it,
                            style: (t.textTheme.bodyMedium ?? const TextStyle())
                                .copyWith(
                              height: 1.5,
                              foreground: Paint()
                                ..color = t.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // SECTION C content
  Widget _buildSectionC(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubheading('C1) Duʿāʾ Length'),
        _buildBullets([
          'Short — brief and easy to recite',
          'Long — more detail and expansion',
          'Auto — the refiner chooses a sensible length',
        ]),
        _buildSubheading('C2) Include Sayyid al-Istighfār'),
        _buildBullets([
          'Adds a strong forgiveness segment (or its meaning)',
        ]),
        _buildSubheading('C3) Primary Focus'),
        _buildBullets([
          'Helps emphasise your main theme (e.g., Forgiveness, Rizq, Family, Healing, etc.)',
        ]),
      ],
    );
  }
}
