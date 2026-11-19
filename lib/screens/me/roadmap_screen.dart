import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/brand_theme.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Builder(
                builder: (context) {
                  final bt = context.brandTokens;
                  return Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.background,
                      border: Border(
                        bottom: BorderSide(
                          color: bt.border.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 44,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 22,
                                color: theme.colorScheme.secondary,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              padding: EdgeInsets.zero,
                              tooltip: 'Back',
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: ShaderMask(
                            shaderCallback: (bounds) => bt.copperGradient.createShader(bounds),
                            child: Text(
                              'Roadmap',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: theme.textTheme.titleLarge?.fontSize ?? 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Builder(
                builder: (context) {
                  final bt = context.brandTokens;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header area — centred icon + tagline
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.rocket_launch_outlined,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Built with purpose. Growing with you.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Roadmap items
                      _buildRoadmapItem(
                        context,
                        Icons.volunteer_activism_outlined,
                        'Charity Partnerships',
                        'Establishing partnerships with charitable organisations across the UK and globally to fulfil our 10% revenue donation pledge.',
                        'In Progress',
                        theme,
                        bt,
                      ),
                      _buildRoadmapItem(
                        context,
                        Icons.tune_outlined,
                        'Du\u02BFā Length Control',
                        'Choose between short, medium, or long du\u02BFās to suit your time and moment.',
                        'Coming Soon',
                        theme,
                        bt,
                      ),
                      _buildRoadmapItem(
                        context,
                        Icons.people_outline,
                        'Community Du\u02BFā Feed',
                        'Share your struggles and ask the community to make du\u02BFā for you. A safe, moderated space built on the spirit of tawassul.',
                        'Planned',
                        theme,
                        bt,
                      ),
                      _buildRoadmapItem(
                        context,
                        Icons.translate_outlined,
                        'More Languages',
                        'Expanding language support so Muslims worldwide can make du\u02BFā in the language closest to their heart.',
                        'Planned',
                        theme,
                        bt,
                      ),
                      _buildRoadmapItem(
                        context,
                        Icons.brush_outlined,
                        'UI & Experience Improvements',
                        'Continuous refinements based on your feedback to make Munājāt more beautiful and intuitive.',
                        'Ongoing',
                        theme,
                        bt,
                      ),

                      // Closing message
                      const SizedBox(height: 16),
                      Text(
                        'Have a feature idea? Let us know through Help & Support — we build Munājāt for you.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadmapItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    String status,
    ThemeData theme,
    BrandTokens bt,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bt.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
