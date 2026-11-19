import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _wordmarkController;
  late AnimationController _shimmerController;
  late AnimationController _studioController;
  late AnimationController _subtextController;
  
  late Animation<double> _wordmarkOpacity;
  late Animation<double> _studioOpacity;
  late Animation<double> _subtextOpacity;
  
  bool _navigationFired = false;

  @override
  void initState() {
    super.initState();

    // Wordmark fade-in (2.5s easeInOut, delay 0.5s)
    _wordmarkController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _wordmarkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _wordmarkController, curve: Curves.easeInOut),
    );

    // Shimmer animation (2.5s, delay 0.5s, one-time)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // "Dua Studio" sub-wordmark fade-in (1s easeInOut)
    _studioController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _studioOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _studioController, curve: Curves.easeInOut),
    );

    // Quote fade-in (1s easeInOut)
    _subtextController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _subtextOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtextController, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    // Start wordmark and shimmer animation at 500ms
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _wordmarkController.forward();
    _shimmerController.forward();

    // After wordmark fully visible (2.5s) + short gap, show "Dua Studio"
    await Future.delayed(const Duration(milliseconds: 2700)); // ~2.5s + 200ms buffer
    if (!mounted) return;
    _studioController.forward();

    // After another short delay, show the quote
    await Future.delayed(const Duration(milliseconds: 1200)); // 1s fade + 200ms buffer
    if (!mounted) return;
    _subtextController.forward();

    // Fire completion callback at exactly 9000ms total
    // Only fire once regardless of lifecycle or hot reload
    await Future.delayed(const Duration(milliseconds: 5000));
    if (!mounted || _navigationFired) return;
    _navigationFired = true;
    widget.onComplete();
  }

  @override
  void dispose() {
    _wordmarkController.dispose();
    _shimmerController.dispose();
    _studioController.dispose();
    _subtextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shift content up by ~60px
            Transform.translate(
              offset: const Offset(0, -24),
              child: Column(
                children: [
                  // Wordmark with gradient + shimmer
                  FadeTransition(
                    opacity: _wordmarkOpacity,
                    child: _buildWordmark(),
                  ),
                  const SizedBox(height: 16),
                  // "Dua Studio" sub-wordmark (appears after wordmark)
                  FadeTransition(
                    opacity: _studioOpacity,
                    child: _buildSubWordmark(),
                  ),
                  const SizedBox(height: 10),
                  // Quote (hadith)
                  FadeTransition(
                    opacity: _subtextOpacity,
                    child: _buildSubtext(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordmark() {
    // Scale up ~1.3x and reduce weight slightly vs previous
    return _LocalShimmerWordmark(text: 'Munājāt', fontSize: 70);
  }

  Widget _buildSubWordmark() {
    // Color should match the existing quote color (copper tone)
    final cs = Theme.of(context).colorScheme;
    final duoColor = cs.brightness == Brightness.dark
        ? const Color(0xFFC9A76E)
        : const Color(0xFFC9A76E);

    return Text(
      'Dua Studio',
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: duoColor,
        letterSpacing: 0.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtext() {
    // Quote color should now match the old "Dua Studio" color (muted label)
    final labelColor = Theme.of(context).textTheme.labelSmall?.color ??
        Theme.of(context).colorScheme.onSurfaceVariant;
    
    return Text(
      '"Dua (supplication) is Worship"',
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: labelColor,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}

// Local shimmer wordmark that mirrors the shared component's behavior,
// but allows a slightly lighter weight (w100) and larger size for splash.
class _LocalShimmerWordmark extends StatefulWidget {
  final String text;
  final double fontSize;
  const _LocalShimmerWordmark({required this.text, this.fontSize = 54});

  @override
  State<_LocalShimmerWordmark> createState() => _LocalShimmerWordmarkState();
}

class _LocalShimmerWordmarkState extends State<_LocalShimmerWordmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _anim = Tween<double>(begin: 1.0, end: -1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    // Match the shared shimmer's 500ms delayed single pass
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const baseStyleColor = Colors.white; // masked by gradient
    final baseStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.w100, // slightly thinner than previous w200
      fontSize: widget.fontSize,
      letterSpacing: 0.5,
      height: 1.0,
      color: baseStyleColor,
    );

    // Copper gradient base similar to shared component
    const baseGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFB87333), Color(0xFFFFD9A0)],
    );

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final shimmerGradient = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Color.fromARGB(190, 255, 255, 255),
            Colors.transparent,
          ],
          stops: [0.35, 0.5, 0.65],
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (rect) => baseGradient.createShader(rect),
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: baseStyle,
                ),
              ),
              Positioned.fill(
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (rect) {
                    final dx = rect.width * _anim.value;
                    final shiftedRect =
                        Rect.fromLTWH(dx, rect.top, rect.width, rect.height);
                    return shimmerGradient.createShader(shiftedRect);
                  },
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    style: baseStyle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
