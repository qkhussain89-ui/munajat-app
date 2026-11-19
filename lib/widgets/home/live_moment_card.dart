import 'package:flutter/material.dart';
import 'package:hearth_prayer/controllers/home_moment_controller.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

class LiveMomentCard extends StatefulWidget {
  final VoidCallback? onMakeDua;
  final HomeMomentController? momentController;

  const LiveMomentCard({super.key, this.onMakeDua, this.momentController});

  @override
  State<LiveMomentCard> createState() => _LiveMomentCardState();
}

class _LiveMomentCardState extends State<LiveMomentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.momentController ?? HomeMomentController();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brandTokens = context.brandTokens;
    final headline = controller.headline(controller.current);
    final subheadline =
        controller.subheadline(controller.current);

    debugPrint('[HOME] LiveMoment state = ${controller.current}');

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Semantics(
          label: 'Live blessed moment card',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface,
                  colorScheme.surface.withValues(alpha: 0.7),
                ],
              ),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) {
                    final colors = brandTokens.copperGradient.colors;
                    final stops = List.generate(
                      colors.length,
                      (i) => ((_shimmerController.value * colors.length + i) / colors.length).clamp(0.0, 1.0),
                    );
                    final shimmerGradient = LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                      stops: stops,
                    );
                    return shimmerGradient.createShader(bounds);
                  },
                  child: Text(
                    'It\'s a Blessed Moment — Raise Your Hands',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  headline,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: brandTokens.textMuted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subheadline,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: brandTokens.textMuted.withValues(alpha: 0.75),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.favorite, color: colorScheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: widget.onMakeDua,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            controller.cta(controller.current),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
