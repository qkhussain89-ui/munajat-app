import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                              'Privacy Policy',
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
                    'OUR COMMITMENT',
                    'Munajat: Dua Studio is built around a deeply personal act \u2014 du\u2019\u0101. We take your privacy seriously. This policy explains exactly what we collect, why, and how it is protected.',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Effective date: 1 March 2026',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildBulletSection(
                    theme,
                    'WHAT WE COLLECT',
                    [
                      'Account information: Your email address, used for authentication via Supabase.',
                      'Du\u2019\u0101 input text: Your typed or spoken thoughts, sent to our AI service to generate your du\u2019\u0101. This is processed in real time and not stored after generation.',
                      'Saved du\u2019\u0101s: Prayers you choose to save, stored securely in your account.',
                      'Journal entries: Stored securely in your account.',
                      'Location data: With your permission, approximate location is used only to calculate prayer times. Location is not stored.',
                      'Subscription status: Managed by Apple and RevenueCat. We do not process or store payment details.',
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildBulletSection(
                    theme,
                    'HOW WE USE YOUR DATA',
                    [
                      'To authenticate your account and provide app access.',
                      'To generate your personalised du\u2019\u0101s.',
                      'To display accurate prayer times for your location.',
                      'To manage your subscription.',
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildBulletSection(
                    theme,
                    'THIRD-PARTY SERVICES',
                    [
                      'Supabase \u2014 Authentication and secure cloud storage.',
                      'OpenAI \u2014 Du\u2019\u0101 generation. Your input is sent to OpenAI\u2019s API.',
                      'RevenueCat \u2014 Subscription management.',
                      'AlAdhan API \u2014 Prayer time calculations using approximate location.',
                      'Apple App Store \u2014 Payment processing.',
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your data may be processed in countries outside the UK/EEA by these services. Each operates under appropriate data protection frameworks.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'DATA RETENTION',
                    'Saved du\u2019\u0101s and journal entries are retained while your account is active. Du\u2019\u0101 input text is not retained after generation. You may delete your account and all data at any time.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'DATA SECURITY',
                    'We use encrypted connections (HTTPS/TLS) and secure cloud infrastructure. Your data is never sold or shared without your explicit consent.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'YOUR RIGHTS',
                    'You have the right to access, correct, export, or delete your personal data. To exercise any of these rights, contact: munajatduastudio@gmail.com',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'CHILDREN\u2019S PRIVACY',
                    'We do not knowingly collect data from children under 13. If you believe this has occurred, contact us and we will delete it immediately.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'CHANGES TO THIS POLICY',
                    'We will notify you of material changes via the app or by email.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    theme,
                    'CONTACT',
                    'munajatduastudio@gmail.com',
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

  Widget _buildBulletSection(ThemeData theme, String title, List<String> items) {
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
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\u2022  ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
