import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Precomposed Munājāt with ā (U+0101)
const String kWordmark = 'Mun\u0101j\u0101t';

// Common style for base + shimmer layers
final TextStyle kWordmarkStyle = GoogleFonts.poppins(
  fontWeight: FontWeight.w200,
  fontSize: 54,
  letterSpacing: 0.5,
  fontFeatures: const <FontFeature>[FontFeature.enable('kern')],
  height: 1.0,
  color: Colors.white,
);

class ShimmerWordmark extends StatefulWidget {
  final String text;
  final double fontSize;
  const ShimmerWordmark({
    super.key,
    required this.text,
    this.fontSize = 54,
  });

  @override
  State<ShimmerWordmark> createState() => _ShimmerWordmarkState();
}

class _ShimmerWordmarkState extends State<ShimmerWordmark>
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
    // One pass after 500ms delay to mimic design
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
    // Copper gradient base behind text (static)
    final baseGradient = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFB87333), Color(0xFFFFD9A0)],
    );

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        // Moving white shimmer band; we slide the gradient across the text.
        final shimmerGradient = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Colors.transparent,
            Color.fromARGB(190, 255, 255, 255), // ~0.75 opacity
            Colors.transparent,
          ],
          stops: const [0.35, 0.5, 0.65],
        );

        // We achieve "inside the letters only" by stacking:
        // 1) Base text with copper gradient using ShaderMask
        // 2) Shimmer pass with ShaderMask + BlendMode.srcIn over the same text
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (rect) => baseGradient.createShader(rect),
                child: Text(
                  kWordmark,
                  textAlign: TextAlign.center,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: kWordmarkStyle.copyWith(fontSize: widget.fontSize),
                ),
              ),
              // Shimmer layer
              Positioned.fill(
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (rect) {
                    // Slide from right -> left using anim value (-1..1 across width)
                    final dx = rect.width * _anim.value;
                    final shiftedRect =
                        Rect.fromLTWH(dx, rect.top, rect.width, rect.height);
                    return shimmerGradient.createShader(shiftedRect);
                  },
                  child: Text(
                    kWordmark,
                    textAlign: TextAlign.center,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    style: kWordmarkStyle.copyWith(fontSize: widget.fontSize),
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
