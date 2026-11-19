import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

/// MissionMessageGate (Phase 1)
/// - Full-screen, non-dismissible gate shown before proceeding from Preview/Result
/// - Requires user to scroll to ~end to enable CTAs
class MissionMessageGate extends StatefulWidget {
  const MissionMessageGate({super.key});

  @override
  State<MissionMessageGate> createState() => _MissionMessageGateState();
}

class _MissionMessageGateState extends State<MissionMessageGate> {
  final ScrollController _scrollController = ScrollController();
  bool _ctasEnabled = false;
  bool _showScrollHint = true;
  final GlobalKey _ctaKey = GlobalKey();
  double _ctaHeight = 0;
  double _scrollProgress = 0; // 0..1 normalized to unlock threshold

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureCta());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // Unlock when the user is within ~5% of the end or 24px from bottom
    final nearEndByPercent = position.pixels >= (position.maxScrollExtent * 0.95);
    final nearEndByExtent = position.extentAfter <= 24;
    double raw = position.maxScrollExtent == 0
        ? 0
        : (position.pixels / (position.maxScrollExtent));
    final normalized = (raw / 0.95).clamp(0.0, 1.0);
    setState(() {
      _scrollProgress = normalized;
      if ((nearEndByPercent || nearEndByExtent) && !_ctasEnabled) {
        _ctasEnabled = true;
        _showScrollHint = false;
      }
    });
  }

  void _measureCta() {
    final ctx = _ctaKey.currentContext;
    if (ctx == null) return;
    final render = ctx.findRenderObject();
    if (render is RenderBox) {
      final h = render.size.height;
      if (h != _ctaHeight) {
        setState(() => _ctaHeight = h);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final brand = context.brandTokens;

    return WillPopScope(
      onWillPop: () async => false, // Non-dismissible via back
      child: Scaffold(
        backgroundColor: colors.background,
        body: Stack(
          children: [
            // Subtle vertical background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.background,
                    colors.surfaceContainerHighest.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),

            // Main content card centered with comfortable margins
            SafeArea(
              child: Padding(
                // Bottom space is handled inside scroll content with dynamic CTA-aware padding
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(22), // 20\u201324px rounded
                        border: Border.all(color: brand.border),
                        boxShadow: [brand.cardShadowLight],
                      ),
                      padding: const EdgeInsets.fromLTRB(26, 26, 26, 26), // generous internal padding
                      child: _ScrollableMissionContent(
                        controller: _scrollController,
                        bottomPadding: _ctaHeight + 20,
                        progress01: _scrollProgress,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Sticky CTA bar at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: _StickyCtas(
                key: _ctaKey,
                enabled: _ctasEnabled,
                showHint: _showScrollHint,
                onShare: () {
                  // Phase 1: placeholder behavior \u2014 do not dismiss
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share triggered')),
                  );
                },
                onContinue: () {
                  // Phase 1: navigate to Home
                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollableMissionContent extends StatelessWidget {
  final ScrollController controller;
  final double bottomPadding;
  final double progress01; // normalized to unlock threshold
  const _ScrollableMissionContent({
    required this.controller,
    required this.bottomPadding,
    required this.progress01,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final brand = context.brandTokens;

    final bodyStyle = theme.textTheme.bodyLarge?.copyWith(
      fontSize: 16,
      height: 1.56,
      color: colors.onSurface.withValues(alpha: 0.92),
    );
    final headingBase = theme.textTheme.titleLarge?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: colors.onSurface,
    );
    final bismillahBase = theme.textTheme.titleLarge?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
    );

    Widget gradientText(String text, TextStyle? base, {TextAlign align = TextAlign.start}) {
      if (base == null) return Text(text, textAlign: align);
      return ShaderMask(
        shaderCallback: (bounds) => brand.copperGradient.createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Text(
          text,
          textAlign: align,
          style: base.copyWith(color: Colors.white),
        ),
      );
    }

    Widget sectionHeading(String text) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: gradientText(text, headingBase),
        );

    Widget divider() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Divider(
            height: 1,
            thickness: 1,
            color: brand.divider.withValues(alpha: 0.2),
          ),
        );

    return Stack(
      children: [
        // Thin top progress bar (2px)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 2,
            child: Stack(
              children: [
                Container(color: colors.outline.withValues(alpha: 0.15)),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress01.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(gradient: brand.copperGradient),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Scrollable content
        Padding(
          padding: const EdgeInsets.only(top: 8), // small gap below progress
          child: SingleChildScrollView(
            controller: controller,
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Bismillah \u2014 centered, slightly larger
              Center(
                child: gradientText(
                  '\u0628\u0650\u0633\u0652\u0645\u0650 \u0671\u0644\u0644\u0651\u064e\u0640\u0647\u0650 \u0671\u0644\u0631\u0651\u064e\u062d\u0652\u0645\u064e\u0640\u0646\u0650 \u0671\u0644\u0631\u0651\u064e\u062d\u0650\u064a\u0645\u0650',
                  bismillahBase,
                  align: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 1 \u2014 Opening
              Text(
                'The Prophet \uFDFA said: "Du\'a is worship."',
                style: bodyStyle,
              ),
              const SizedBox(height: 12),
              Text(
                '(Sunan al-Tirmidh\u012B 3247 \u2014 \u1E62a\u1E25\u012B\u1E25)',
                style: bodyStyle?.copyWith(
                  fontSize: 14,
                  color: colors.onSurface.withValues(alpha: 0.65),
                ),
              ),

              const SizedBox(height: 14),
              Text(
                'Yet many of us stand before Allah and struggle to find the words.\n\nWe know He is listening.\nWe know He is near.\nWe feel it in our hearts \u2014 but when we raise our hands, the words fall short of what we carry inside.\n\nMun\u0101j\u0101t was built for that moment.',
                style: bodyStyle,
              ),

              divider(),

              // SECTION 2 \u2014 WHAT MUN\u0100J\u0100T IS
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 6),
                child: Text(
                  'WHAT MUN\u0100J\u0100T IS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 12,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                    color: colors.primary.withValues(alpha: 0.85),
                  ),
                ),
              ),
              sectionHeading('What Mun\u0101j\u0101t Is'),
              Text(
                'Mun\u0101j\u0101t helps you turn what is in your heart into a du\'\u0101\' that honours the etiquettes taught by the Prophet \uFDFA and the scholars of this Ummah.\n\nYou speak or type what is on your mind \u2014 your worries, your hopes, your gratitude, your pain \u2014 and Mun\u0101j\u0101t shapes it into a structured supplication that:\n\n\u2014 Opens with praise of Allah by His Beautiful Names\n\u2014 Sends \u1E63alaw\u0101t upon the Prophet \uFDFA\n\u2014 Seeks forgiveness before asking\n\u2014 Presents your need with humility and conviction\n\u2014 Closes with trust in Allah\'s decree\n\nThis is not a replacement for learning du\'\u0101\' yourself. It is a companion for the moments when your heart is full but your tongue is tied.',
                style: bodyStyle,
              ),

              divider(),

              // SECTION 3 \u2014 A SHARED RESPONSIBILITY
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 6),
                child: Text(
                  'A SHARED RESPONSIBILITY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 12,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                    color: colors.primary.withValues(alpha: 0.85),
                  ),
                ),
              ),
              sectionHeading('\u{1F90D} A Responsibility We Share'),
              Text(
                'The Prophet \uFDFA said: "I and the one who sponsors an orphan will be in Paradise like this" \u2014 and he held his two fingers together.\n(\u1E62a\u1E25\u012B\u1E25 al-Bukh\u0101r\u012B 6005)\n\nA portion of Mun\u0101j\u0101t\'s monthly subscription revenue is dedicated to supporting orphans through trusted Muslim charities.\n\nThis is not a marketing promise. It is an \'\u0101hd \u2014 a covenant \u2014 with Allah before it is a commitment to you.\n\nOnce Mun\u0101j\u0101t reaches 10,000 active subscribers, monthly donations begin and continue permanently, in sh\u0101\' All\u0101h.',
                style: bodyStyle,
              ),

              divider(),

              // THE MILESTONE (unchanged)
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 6),
                child: Text(
                  'THE MILESTONE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 12,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                    color: colors.primary.withValues(alpha: 0.85),
                  ),
                ),
              ),
              sectionHeading('\u{1F3AF} How This Becomes Possible'),
              Text(
                'To begin donating sustainably, Mun\u0101j\u0101t must reach an initial milestone of:',
                style: bodyStyle,
              ),
              const SizedBox(height: 10),
              // Big number callout
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '10,000',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ACTIVE MONTHLY SUBSCRIBERS',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        color: colors.primary.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'From there, the hope is to grow \u2014 step by step \u2014 to '),
                    TextSpan(
                      text: '100,000',
                      style: bodyStyle?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: ', '),
                    TextSpan(
                      text: '500,000',
                      style: bodyStyle?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: ', and eventually '),
                    TextSpan(
                      text: '1 million',
                      style: bodyStyle?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: ' people connected through du\u02BF\u0101\u02BE and shared good.'),
                  ],
                ),
                style: bodyStyle,
              ),

              divider(),

              // SECTION 4 \u2014 YOUR ROLE
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 6),
                child: Text(
                  'YOUR ROLE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 12,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                    color: colors.primary.withValues(alpha: 0.85),
                  ),
                ),
              ),
              sectionHeading('\u{1F501} Your Part in This'),
              Text(
                'You are already part of this effort.\n\nEvery du\'\u0101\' you make through Mun\u0101j\u0101t is a turning to Allah with intention. Every subscription sustains the work. And every share carries the potential for \u1E63adaqah j\u0101riyah \u2014 ongoing reward.\n\nIf this app helped you put something meaningful into words \u2014 even once \u2014 then sharing it may help someone else who is struggling to ask.',
                style: bodyStyle,
              ),

              const SizedBox(height: 16),

              // Quote block
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: colors.primary.withValues(alpha: 0.25), width: 3),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u201CWhoever guides someone to goodness will have a reward like the one who does it.\u201D',
                      style: bodyStyle?.copyWith(fontStyle: FontStyle.italic, fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    Text('\u2014 Prophet Mu\u1E25ammad \uFDFA (\u1E62a\u1E25\u012B\u1E25 Muslim 1893)', style: bodyStyle?.copyWith(fontSize: 15)),
                  ],
                ),
              ),

              divider(),

              // SECTION 5 \u2014 A Final Du\u02BF\u0101\u02BE (unchanged)
              sectionHeading('A Final Du\u02BF\u0101\u02BE'),
              Text(
                'May Allah accept from all of us, place barakah in this effort, and make it a source of lasting good for the Ummah in this life and the next.',
                style: bodyStyle,
              ),
              const SizedBox(height: 14),
              Text('\u0100m\u012Bn.', style: bodyStyle),

              const SizedBox(height: 24),
              // Removed artificial bottom spacer to eliminate dead-space tail
            ],
          ),
        ),
        ),
      ],
    );
  }
}

class _StickyCtas extends StatelessWidget {
  final bool enabled;
  final bool showHint;
  final VoidCallback onShare;
  final VoidCallback onContinue;

  const _StickyCtas({
    super.key,
    required this.enabled,
    required this.showHint,
    required this.onShare,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final brand = context.brandTokens;
    return Material(
      color: colors.surface,
      elevation: 0,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.outline.withValues(alpha: 0.2))),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedOpacity(
                opacity: showHint ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Text(
                  'Scroll to the end to continue',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: (theme.textTheme.labelSmall?.fontSize ?? 11) + 1,
                    color: colors.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Primary button (copper gradient background; reduced opacity when disabled)
              SizedBox(
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: enabled ? brand.copperGradient : null,
                    color: enabled ? null : theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: enabled ? onShare : null,
                      child: Center(
                        child: Text(
                          '\u{1F90D} Share Mun\u0101j\u0101t',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: enabled ? Colors.white : colors.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Secondary button
              SizedBox(
                height: 44,
                child: TextButton(
                  onPressed: enabled ? onContinue : null,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    foregroundColor: theme.colorScheme.primary,
                    disabledForegroundColor: theme.colorScheme.outline.withValues(alpha: 0.6),
                  ),
                  child: const Text('Continue to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
