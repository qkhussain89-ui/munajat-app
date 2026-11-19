import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
                              'Terms of Service',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    theme,
                    'INTRODUCTION',
                    'Welcome to Munajat: Dua Studio. By using this app, you agree to these Terms of Service. Please read them carefully.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'SERVICE DESCRIPTION',
                    'Munajat: Dua Studio is an AI-powered app that generates personalised Islamic supplications (du\'ās) rooted in Quran and Sunnah principles. Features include du\'ā creation (text and voice), a saved du\'ā library, a personal journal, prayer times, and multi-language support.',
                  ),
                  const SizedBox(height: 24),
                  _buildSectionWithBullets(
                    theme,
                    'SUBSCRIPTIONS & PAYMENTS',
                    'Munajat Pro is available as a monthly (£2.99/month) or annual (£19.99/year) subscription, both including a 3-day free trial.',
                    [
                      'Payment is charged to your Apple ID at confirmation of purchase.',
                      'Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period.',
                      'Manage or cancel via: Settings → Apple ID → Subscriptions.',
                      'Refund requests are handled by Apple. We do not process refunds directly.',
                      'Free trial converts to paid subscription unless cancelled before the trial ends.',
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'ACCEPTABLE USE',
                    'You agree to use Munajat respectfully and for its intended purpose as a tool for Islamic supplication and spiritual reflection. Misuse of the app or attempts to interfere with its operation are prohibited.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'AI-GENERATED CONTENT',
                    'Du\'ās are generated using artificial intelligence guided by Islamic principles. All content is structured around authentic Quran, Sunnah, and the 99 Names of Allah. Generated du\'ās are a spiritual aid — they are not fatwas and do not replace the guidance of a qualified Islamic scholar.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'USER CONTENT',
                    'Your du\'ā inputs, saved du\'ās, and journal entries belong to you. By using the app, you grant us permission to process your inputs solely for the purpose of generating your du\'ās via our AI service.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'INTELLECTUAL PROPERTY',
                    'The app, its design, code, and brand are the property of Munajat: Dua Studio. Du\'ās generated for you are yours to use freely for personal worship and sharing.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'ACCOUNT DELETION',
                    'You may delete your account at any time. Contact us at munajatduastudio@gmail.com and we will delete your account and all associated data within 48 hours.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'LIMITATION OF LIABILITY',
                    'The app is provided "as is". We are not liable for any damages arising from your use of the app. Prayer times are provided for convenience and should be verified with local sources.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'CHANGES TO TERMS',
                    'We may update these terms. Continued use of the app after changes constitutes acceptance of the revised terms.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'GOVERNING LAW',
                    'These terms are governed by the laws of England and Wales.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'CONTACT',
                    'Questions? Email us: munajatduastudio@gmail.com',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.copper,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionWithBullets(
    ThemeData theme,
    String title,
    String intro,
    List<String> bullets,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.copper,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          intro,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        ...bullets.map(
          (bullet) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•  ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
                ),
                Expanded(
                  child: Text(
                    bullet,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
