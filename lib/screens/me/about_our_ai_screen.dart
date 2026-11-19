import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

class AboutOurAiScreen extends StatelessWidget {
  const AboutOurAiScreen({super.key});

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
                              'About Our AI',
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
                              Icons.auto_awesome,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Transparency matters to us.',
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

                      // Section: How It Works
                      ShaderMask(
                        shaderCallback: (bounds) => bt.copperGradient.createShader(bounds),
                        child: const Text(
                          'How It Works',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Munājāt uses advanced AI to transform your words into beautiful du\u02BFās following the etiquettes taught by the Prophet \uFDFA and scholars of Ahl al-Sunnah wal-Jamā\u02BFah.\n\nThe founder spent considerable time meticulously instructing the AI to adhere to sound Islamic methodology, ensuring every generated du\u02BFā reflects authentic Sunnah etiquette.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.7,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Section: Important to Know
                      ShaderMask(
                        shaderCallback: (bounds) => bt.copperGradient.createShader(bounds),
                        child: const Text(
                          'Important to Know',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'AI is a powerful tool, but it is not perfect. Here are some things to keep in mind:\n\n\u2022 Occasionally, the AI may produce phrasing that doesn\u2019t perfectly reflect Islamic theology. This is rare, but possible.\n\n\u2022 AI technology is rapidly developing \u2014 as it improves, so will Munājāt.\n\n\u2022 If you ever notice anything incorrect, please let us know through Help & Support. Your feedback helps us improve.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.7,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Section: Your Duʿā, Your Heart
                      ShaderMask(
                        shaderCallback: (bounds) => bt.copperGradient.createShader(bounds),
                        child: const Text(
                          'Your Du\u02BFā, Your Heart',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'The beauty of du\u02BFā is that it comes from your heart. Even if the AI\u2019s wording isn\u2019t perfect, your sincerity with Allah is what matters most.\n\nUse the generated du\u02BFā as a starting point \u2014 add to it, personalise it, make it yours.\n\nMay Allah accept your du\u02BFās and ours. Āmīn.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.7,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
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
}
