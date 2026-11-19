import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hearth_prayer/theme.dart';
import 'package:hearth_prayer/components/copper_button.dart';
import 'package:hearth_prayer/state/app_state.dart';
import 'package:hearth_prayer/services/user_service.dart';
import 'package:hearth_prayer/screens/settings_screen.dart';
import 'package:hearth_prayer/screens/me/subscription_screen.dart';
import 'package:hearth_prayer/services/revenucat_service.dart';
import 'package:hearth_prayer/screens/me/privacy_policy_screen.dart';
import 'package:hearth_prayer/screens/me/terms_of_service_screen.dart';
import 'package:hearth_prayer/screens/me/me_sheets.dart';
import 'package:hearth_prayer/screens/mission_message_gate.dart';
import 'package:hearth_prayer/screens/me/etiquettes_of_dua_canonical_screen.dart';
import 'package:hearth_prayer/screens/me/about_our_ai_screen.dart';
import 'package:hearth_prayer/screens/me/roadmap_screen.dart';
import 'package:hearth_prayer/screens/inaugural_dua_screen.dart';

class ProfileRefinedScreen extends StatelessWidget {
  const ProfileRefinedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    // Derive initials from existing on-screen data (prefer name, then email, else 'Q').
    String deriveInitials() {
      final name = user?.name?.trim();
      if (name != null && name.isNotEmpty) {
        final parts = name.split(RegExp(r"\s+")).where((p) => p.isNotEmpty).toList();
        if (parts.isNotEmpty) {
          final first = parts.first.isNotEmpty ? parts.first[0] : '';
          final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
          final combined = (first + second).trim();
          return combined.isNotEmpty ? combined.toUpperCase() : 'Q';
        }
      }
      final email = user?.email?.trim();
      if (email != null && email.isNotEmpty) {
        final first = email[0];
        return first.toUpperCase();
      }
      // Fallback to current dummy initial example
      return 'Q';
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circular initials avatar (replaces profile picture & removes edit icon)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gradientStart, AppColors.gradientEnd],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.copper,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        deriveInitials(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                           // Enlarge initial to occupy ~60–70% of the 80px circle
                           // while keeping the existing weight and visual balance.
                           fontSize: 48,
                           fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? '',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Stat cards removed and vertical spacing tightened
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<String>(
                      future: _getSubscriptionSubtitle(),
                      builder: (context, snapshot) {
                        final subtitle = snapshot.data ?? 'Loading…';
                        return _buildMenuItem(
                          context,
                          Icons.card_giftcard,
                          'Subscription',
                          subtitle,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      Icons.settings_outlined,
                      'Settings',
                      'Appearance & Notifications',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // About Munājāt section (placed after Support, before Actions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Munājāt',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context,
                      Icons.flag_outlined,
                      'Mission',
                      'Why Munājāt exists',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MissionMessageGate()),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.auto_stories,
                      'Founding Du\u02bb\u0101',
                      'The first supplication of Mun\u0101j\u0101t',
                      () {
                        final currentUser = UserService.currentUser;
                        if (currentUser != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => InauguralDuaScreen(
                                user: currentUser,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    _buildMenuItem(
                      context,
                      Icons.menu_book_outlined,
                      'Etiquettes of Duʿāʾ',
                      'How to make duʿāʾ with adab',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EtiquettesOfDuaCanonicalScreen()),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.auto_awesome_outlined,
                      'About Our AI',
                      'How AI assists your duʿās',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutOurAiScreen()),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.rocket_launch_outlined,
                      'Roadmap',
                      'What\'s coming next',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RoadmapScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context,
                      Icons.help_outline,
                      'Help & Support',
                      'FAQs & Contact',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.lock_outline,
                      'Privacy Policy',
                      'Our commitment to you',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.description_outlined,
                      'Terms of Service',
                      'Legal terms',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context,
                      Icons.share_outlined,
                      'Share App',
                      'Tell a friend',
                      () => showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (_) => const ShareAppSheet(),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.star_outline,
                      'Rate Us',
                      'Leave a review',
                      () => showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (_) => const RateUsSheet(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 24),
                 child: CopperButton(
                   text: 'Logout',
                   variant: CopperButtonVariant.outline,
                   onPressed: () => showModalBottomSheet(
                     context: context,
                     shape: const RoundedRectangleBorder(
                       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                     ),
                     builder: (_) => LogoutConfirmSheet(
                       onConfirm: () async {
                         await UserService.signOut();
                         if (context.mounted) {
                           Provider.of<AppState>(context, listen: false).logout();
                           Navigator.pushNamedAndRemoveUntil(
                             context,
                              '/signin',
                             (route) => false,
                           );
                         }
                       },
                     ),
                   ),
                 ),
               ),
               const SizedBox(height: 16),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 24),
                 child: TextButton(
                   onPressed: () => showModalBottomSheet(
                     context: context,
                     shape: const RoundedRectangleBorder(
                       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                     ),
                     builder: (_) => const DeleteAccountSheet(),
                   ),
                   child: Text(
                     'Delete Account',
                     style: theme.textTheme.bodyMedium?.copyWith(
                       color: Colors.red,
                     ),
                   ),
                 ),
               ),              const SizedBox(height: 32),
              Text(
                'v 2.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _getSubscriptionSubtitle() async {
    try {
      final isPro = await RevenueCatService().isProUser();
      if (!isPro) return 'No active plan';
      final isTrial = await RevenueCatService().isInTrial();
      if (isTrial) return 'Free Trial';
      return 'Active';
    } catch (_) {
      return 'Tap to view';
    }
  }

  Widget _buildStatColumn(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.copper,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.copper,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }


}
