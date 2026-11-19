import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class MissionMunajatScreen extends StatelessWidget {
  const MissionMunajatScreen({super.key});

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
                              'Mission Mun\u0101j\u0101t',
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // A) Top icon area
                      Icon(Icons.volunteer_activism, size: 56, color: theme.colorScheme.primary),
                      const SizedBox(height: 20),

                      // B) Title — copper gradient
                      ShaderMask(
                        shaderCallback: (bounds) => bt.copperGradient.createShader(bounds),
                        child: Text(
                          'Du\u02BF\u0101 That Gives Back',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // C) Intro paragraph
                      Text(
                        'Every du\u02BF\u0101 you make through Mun\u0101j\u0101t carries the potential to help others. Our mission is to donate 10% of revenue to charitable causes across the UK and globally \u2014 once we reach 10,000 active subscribers.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.7,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 32),

                      // D) "This Month's Cause" card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.08),
                              theme.colorScheme.primary.withValues(alpha: 0.02),
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            // 1. Header row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🕌', style: TextStyle(fontSize: 24)),
                                const SizedBox(width: 8),
                                Text(
                                  'Charity of the Month',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFD4A574),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // 2. Sub-badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB87333).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'RAMADAN 2026',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFB87333),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 3. Charity logo/image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                'https://images.launchgood.com/communitypage/islamic_centre_of_didcot/banner.jpg',
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1410),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('🕌', style: TextStyle(fontSize: 48)),
                                        SizedBox(height: 8),
                                        Text('Islamic Centre of Didcot', style: TextStyle(color: Color(0xFFD4A574), fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 4. Charity name and tagline
                            const Text(
                              'South Oxfordshire Muslim Association',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE8E0D6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Building Didcot\'s First Mosque',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFFD4A574),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Registered Charity No. 1200193',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B6560),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB87333).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFB87333).withOpacity(0.2)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('\u2B50', style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This is the first charitable project Mun\u0101j\u0101t will officially support once we reach 10,000 active subscribers. Help us get there \u2014 share the app and be part of something lasting.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: const Color(0xFFD4A574),
                                        height: 1.5,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 5. Description
                            const Text(
                              'Didcot sits at the centre of a vast area in South Oxfordshire with no mosque or Muslim community centre. For nearly two decades, the local Muslim community has been praying in rented halls — with no permanent home.\n\n'
                              'SOMA\'s mission is to build the first masjid in South Oxfordshire — a sacred space for worship, education, and community. A place where families can pray together, where children can learn their deen, and where the community can finally call home.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.6,
                                color: Color(0xFF9A948C),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),

                            // 6. Fundraising progress
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141210),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFB87333).withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    '🎯 Masjid Building Fund',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFE8E0D6),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Progress bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: const LinearProgressIndicator(
                                      value: 0.13,
                                      backgroundColor: Color(0xFF2A2420),
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB87333)),
                                      minHeight: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '£130,000 raised',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFD4A574)),
                                      ),
                                      Text(
                                        '£1,000,000 goal',
                                        style: TextStyle(fontSize: 13, color: Color(0xFF6B6560)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '13% funded — every pound brings us closer',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF6B6560), fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 7. Hadith quote
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB87333).withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    '"Whoever builds a mosque for the sake of Allah, Allah will build for him a house like it in Paradise."',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFFD4A574),
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '— The Prophet ﷺ (Sahih al-Bukhari & Muslim)',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF6B6560)),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 8. Action buttons
                            // "Visit SOMA Website" button
                            GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse('https://somadidcot.org/');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFB87333).withValues(alpha: 0.4)),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('🌐', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Visit SOMA Website',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFD4A574)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // "Donate to the Masjid Fund" button
                            GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse('https://www.soma-fundraising-platform.org/');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFB87333), Color(0xFFD4A574)],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('💝', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Donate to the Masjid Fund',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0A0A0A)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // LaunchGood button
                            GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse('https://www.launchgood.com/communitypage/islamic_centre_of_didcot');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFB87333).withValues(alpha: 0.4)),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('🤲', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Support on LaunchGood',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFD4A574)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 9. SOMA services summary
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141210),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'What SOMA Does for the Community',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFE8E0D6)),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildServiceRow('🕋', 'Weekly Jumu\'ah prayers at Fleet Meadow Hall'),
                                  _buildServiceRow('🌙', 'Nightly Tarāwīḥ and community iftār in Ramaḍān'),
                                  _buildServiceRow('🎉', 'Eid prayers for the whole community'),
                                  _buildServiceRow('📚', 'Education & support for new Muslims'),
                                  _buildServiceRow('🤝', 'Interfaith dialogue & civic engagement'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // E) "How It Works" info rows
                      _buildInfoRow(theme, Icons.people_outline, 'We Grow Together', 'As our subscriber community grows, so does the impact of our donations.'),
                      _buildInfoRow(theme, Icons.verified_outlined, 'Transparent & Trusted', 'Every charity partnership will be fully disclosed here with direct links for you to verify.'),
                      _buildInfoRow(theme, Icons.auto_awesome_outlined, 'Your Du\u02BF\u0101s, Your \u1E62adaqah', 'Every subscription sustains this mission. Every share carries the potential for \u1E63adaqah j\u0101riyah.'),
                      const SizedBox(height: 16),

                      // Partnership contact section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141210),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFB87333).withOpacity(0.15)),
                        ),
                        child: Column(
                          children: [
                            const Text('\uD83E\uDD1D', style: TextStyle(fontSize: 24)),
                            const SizedBox(height: 8),
                            const Text(
                              'Partner With Us',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE8E0D6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Are you a charity or community organisation? We\'d love to hear from you. Get in touch to explore how Mun\u0101j\u0101t can support your cause.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9A948C),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse('mailto:munajatduastudio@gmail.com?subject=Charity%20Partnership%20Enquiry');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFB87333).withOpacity(0.4)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('\u2709\uFE0F', style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'munajatduastudio@gmail.com',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFD4A574),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Mun\u0101j\u0101t: Du\u02BF\u0101 Studio is not a registered charity and does not collect or process donations. '
                          'The founder has personally committed to donating 10% of app revenue to charitable causes. '
                          'External links on this page lead to independent charitable organisations that are not affiliated with, '
                          'owned by, or operated by Mun\u0101j\u0101t. Any donations made through those links are made directly to the respective charity.',
                          style: TextStyle(
                            fontSize: 10,
                            color: const Color(0xFF4A4540),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // F) Closing message
                      Text(
                        'May Allah place barakah in this effort and make it a source of lasting good.\n\u0100m\u012Bn.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          height: 1.7,
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

  Widget _buildInfoRow(ThemeData theme, IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

  Widget _buildServiceRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9A948C), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
