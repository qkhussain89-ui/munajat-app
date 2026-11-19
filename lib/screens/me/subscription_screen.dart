import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:hearth_prayer/theme.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:hearth_prayer/components/copper_button.dart';
import 'package:hearth_prayer/screens/me/change_plan_screen.dart';
import 'package:hearth_prayer/screens/me/cancellation_success_screen.dart';
import 'package:hearth_prayer/services/revenucat_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _loading = true;
  bool _isPro = false;
  bool _isTrialing = false;
  CustomerInfo? _customerInfo;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        RevenueCatService().isProUser(),
        RevenueCatService().isInTrial(),
        RevenueCatService().getCustomerInfo(),
      ]);
      if (mounted) {
        setState(() {
          _isPro = results[0] as bool;
          _isTrialing = results[1] as bool;
          _customerInfo = results[2] as CustomerInfo?;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unable to load subscription info.';
          _loading = false;
        });
      }
    }
  }

  String get _planLabel {
    if (_isTrialing) return 'Free Trial';
    if (_isPro) {
      final subs = _customerInfo?.activeSubscriptions ?? <String>[];
      if (subs.contains(RevenueCatService.yearlyProductId)) return 'Yearly';
      if (subs.contains(RevenueCatService.monthlyProductId)) return 'Monthly';
      return 'Pro';
    }
    return 'No active subscription';
  }

  String get _statusLine {
    if (_isTrialing) return 'Trial active';
    if (_isPro) return 'Active';
    return 'Inactive';
  }

  String get _reassuranceText {
    final entitlement = _customerInfo?.entitlements.all[RevenueCatService.entitlementId];
    if (_isTrialing && entitlement?.expirationDate != null) {
      return 'Your free trial ends on ${entitlement!.expirationDate}. You\'ll be charged automatically unless you cancel before then.';
    }
    if (_isPro && !_isTrialing) {
      if (entitlement?.expirationDate != null) {
        return 'Your subscription renews on ${entitlement!.expirationDate}.';
      }
      return 'Your subscription renews automatically each period unless you cancel.';
    }
    return 'You don\'t have an active subscription.';
  }

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
                              'Subscription',
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
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 64),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
                    const SizedBox(height: 16),
                    CopperButton(text: 'Retry', onPressed: _loadSubscriptionData),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Plan Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Plan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          _buildPlanRow(theme, 'Plan', _planLabel),
                          const SizedBox(height: 12),
                          _buildPlanRow(theme, 'Status', _statusLine),
                          const SizedBox(height: 16),
                          Text(
                            _reassuranceText,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: CopperButton(
                              text: 'Manage subscription',
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                                  builder: (_) => _ManageSubscriptionSheet(
                                    isPro: _isPro,
                                    isTrialing: _isTrialing,
                                    customerInfo: _customerInfo,
                                    onRefresh: _loadSubscriptionData,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Section 1: What Munajat Pro unlocks
                    Text(
                      'What Munajat Pro unlocks',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildProFeatureRow(
                            theme,
                            icon: Icons.auto_awesome,
                            title: 'Unlimited du\u02BBā creation',
                            subtitle: 'Generate as many personalised du\u02BBās as you need, any time.',
                          ),
                          const SizedBox(height: 16),
                          _buildProFeatureRow(
                            theme,
                            icon: Icons.language,
                            title: '8 language support',
                            subtitle: 'Receive your du\u02BBās in Arabic, Urdu, Turkish, Bahasa, and more.',
                          ),
                          const SizedBox(height: 16),
                          _buildProFeatureRow(
                            theme,
                            icon: Icons.menu_book_rounded,
                            title: 'Du\u02BBā library & journal',
                            subtitle: 'Save, revisit, and reflect on every du\u02BBā you create.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Section 2: You're in safe hands
                    Text(
                      'You\u2019re in safe hands',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTrustLine(theme, 'Your du\u02BBās are private — never shared or sold.'),
                    const SizedBox(height: 10),
                    _buildTrustLine(theme, 'Cancel anytime. No questions asked.'),
                    const SizedBox(height: 10),
                    _buildTrustLine(theme, 'Rooted in authentic Quran and Sunnah — reviewed for theological accuracy.'),
                    const SizedBox(height: 32),
                    // FAQ Teaser
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Questions about billing?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HelpSupportScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Open Help & Support →',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.copper,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProFeatureRow(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
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
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrustLine(ThemeData theme, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✓  ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

// Manage Subscription Bottom Sheet
class _ManageSubscriptionSheet extends StatelessWidget {
  final bool isPro;
  final bool isTrialing;
  final CustomerInfo? customerInfo;
  final VoidCallback onRefresh;

  const _ManageSubscriptionSheet({
    required this.isPro,
    required this.isTrialing,
    required this.customerInfo,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entitlement = customerInfo?.entitlements.all[RevenueCatService.entitlementId];

    String planDisplay = 'No active plan';
    if (isTrialing) {
      planDisplay = 'Free Trial';
    } else if (isPro) {
      final subs = customerInfo?.activeSubscriptions ?? <String>[];
      if (subs.contains(RevenueCatService.yearlyProductId)) {
        planDisplay = 'Yearly';
      } else if (subs.contains(RevenueCatService.monthlyProductId)) {
        planDisplay = 'Monthly';
      } else {
        planDisplay = 'Pro';
      }
    }

    String statusDisplay = 'Inactive';
    if (isTrialing) {
      statusDisplay = 'Trial active';
    } else if (isPro) {
      statusDisplay = 'Active';
    }

    String nextPayment = '—';
    if (entitlement?.expirationDate != null) {
      nextPayment = entitlement!.expirationDate!;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manage Subscription',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Current Status Section
              Text(
                'Current Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusRow(theme, 'Plan', planDisplay),
              const SizedBox(height: 12),
              _buildStatusRow(theme, 'Status', statusDisplay),
              const SizedBox(height: 12),
              _buildStatusRow(theme, 'Next payment', nextPayment),
              const SizedBox(height: 24),

              // Actions Section
              Text(
                'Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CopperButton(
                  text: 'Change plan',
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePlanScreen()));
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCancelInfo(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Cancel subscription',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final restored = await RevenueCatService().restorePurchases();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(restored ? 'Purchases restored successfully!' : 'No purchases found to restore.'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      onRefresh();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Restore purchases',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Billing History Section
              Text(
                'Billing history',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Billing is managed through your Apple ID. Go to Settings > Apple ID > Subscriptions to view history.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static void _showCancelInfo(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cancel subscription',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'To cancel, go to Settings > Apple ID > Subscriptions on your iPhone.\n\nYour access will continue until the end of the current billing period.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CopperButton(
                  text: 'Got it',
                  onPressed: () {
                    Navigator.pop(modalContext);
                    launchUrl(
                      Uri.parse('https://apps.apple.com/account/subscriptions'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Placeholder for Help & Support Screen
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
                              'Help & Support',
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
                  Text(
                    'We\'re here to help you use Munājāt with ease and peace of mind.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  _buildFAQSection(
                    theme,
                    'Getting Started',
                    [
                      _FAQEntry('What is Munajat: Dua Studio?', 'Munajat is an AI-powered app that transforms your personal thoughts and needs into heartfelt, theologically grounded du\u2019\u0101s (supplications). Every du\u2019\u0101 is rooted in the Quran, Sunnah, and the 99 Names of Allah.'),
                      _FAQEntry('How do I create my first du\u2019\u0101?', 'Tap the Create button on the home screen. Type or speak what\u2019s on your heart \u2014 your worry, hope, gratitude, or need \u2014 and Munajat will generate a personalised du\u2019\u0101 for you.'),
                      _FAQEntry('Can I use voice input?', 'Yes. On the du\u2019\u0101 creation screen, tap the microphone icon to speak your thoughts instead of typing.'),
                      _FAQEntry('Do I need an account to use the app?', 'Yes. An account is required to save your du\u2019\u0101s and journal entries securely.'),
                    ],
                  ),
                  _buildFAQSection(
                    theme,
                    'Du\u2019\u0101 Generation',
                    [
                      _FAQEntry('How does Munajat generate du\u2019\u0101s?', 'Your input is processed by an AI system guided by strict Islamic principles. Every du\u2019\u0101 follows authentic Quran and Sunnah methodology and incorporates relevant Names of Allah. The output is a spiritual aid \u2014 not a fatwa.'),
                      _FAQEntry('Are the hadiths and sources authentic?', 'Yes. We only reference Sahih (authentic) and Hasan (good) hadiths from recognised scholars. No weak or fabricated narrations are used.'),
                      _FAQEntry('What languages can I receive my du\u2019\u0101 in?', 'Currently supported: English, Arabic, Urdu, Turkish, Bahasa Indonesia, Bahasa Malaysia, French, and German. Select your preferred language in Settings.'),
                      _FAQEntry('Can I regenerate a du\u2019\u0101 if I\u2019m not happy with it?', 'Yes. After a du\u2019\u0101 is generated, you can regenerate it or adjust your input to get a different response.'),
                      _FAQEntry('Is the AI replacing a scholar?', 'No. Munajat is a spiritual tool to help you express yourself in du\u2019\u0101. For religious rulings or scholarly guidance, please consult a qualified Islamic scholar.'),
                    ],
                  ),
                  _buildFAQSection(
                    theme,
                    'Saving & Managing Du\u2019\u0101s',
                    [
                      _FAQEntry('How do I save a du\u2019\u0101?', 'After a du\u2019\u0101 is generated, tap the Save button. It will be stored in your Du\u2019\u0101 Library.'),
                      _FAQEntry('How do I share a du\u2019\u0101?', 'Tap the Share button on any saved du\u2019\u0101 to share it via messages, WhatsApp, or any other app on your phone.'),
                      _FAQEntry('What is the journal for?', 'The journal is a private space for spiritual reflection. You can write your thoughts, gratitude, or personal notes alongside your du\u2019\u0101 practice.'),
                      _FAQEntry('Can I organise my saved du\u2019\u0101s?', 'Your saved du\u2019\u0101s are stored in your Du\u2019\u0101 Library. You can browse and revisit them any time.'),
                    ],
                  ),
                  _buildFAQSection(
                    theme,
                    'Prayer Times',
                    [
                      _FAQEntry('How are prayer times calculated?', 'Prayer times are calculated using the AlAdhan API, which supports 23 calculation methods. Your approximate location (with permission) is used to determine accurate times for your area.'),
                      _FAQEntry('Why are my prayer times slightly off?', 'This can happen if your location permissions are not enabled or if the wrong calculation method is selected. Go to Settings \u2192 Prayer Times to adjust your calculation method.'),
                      _FAQEntry('Can I use prayer times without sharing my location?', 'Location access is needed for accurate times. If you prefer not to share location, you can manually enter your city in Settings.'),
                    ],
                  ),
                  _buildFAQSection(
                    theme,
                    'Subscription & Billing',
                    [
                      _FAQEntry('What does Munajat Pro include?', 'Unlimited du\u2019\u0101 creation, 8 language support, a full du\u2019\u0101 library, journal access, and prayer times. The free tier has a limited number of du\u2019\u0101 generations per month.'),
                      _FAQEntry('How much does Munajat Pro cost?', '\u00A32.99/month or \u00A319.99/year. Both plans include a 3-day free trial.'),
                      _FAQEntry('What happens when my free trial ends?', 'If you do not cancel before the trial ends, your subscription will automatically begin and payment will be charged to your Apple ID.'),
                      _FAQEntry('How do I cancel my subscription?', 'Go to Settings on your iPhone \u2192 tap your name \u2192 Subscriptions \u2192 Munajat: Dua Studio \u2192 Cancel Subscription.'),
                      _FAQEntry('Can I restore my purchases on a new device?', 'Yes. Go to the Subscription screen in the app and tap "Restore purchases".'),
                      _FAQEntry('Can I get a refund?', 'Refunds are handled by Apple. Visit reportaproblem.apple.com or contact Apple Support directly to request a refund.'),
                    ],
                  ),
                  _buildFAQSection(
                    theme,
                    'Privacy & Account',
                    [
                      _FAQEntry('Is my du\u2019\u0101 data private?', 'Yes. Your du\u2019\u0101 inputs are processed in real time and not stored after generation. Saved du\u2019\u0101s and journal entries are stored securely in your private account. Your data is never sold or shared.'),
                      _FAQEntry('How do I delete my account?', 'Email us at munajatduastudio@gmail.com and we will delete your account and all associated data within 48 hours.'),
                      _FAQEntry('What data does the app collect?', 'We collect your email (for authentication), du\u2019\u0101 input text (processed in real time, not stored), saved du\u2019\u0101s, journal entries, and approximate location (for prayer times only). See our Privacy Policy for full details.'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Need more help?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CopperButton(
                      text: 'Contact support',
                      onPressed: () async {
                        final uri = Uri.parse('mailto:munajatduastudio@gmail.com?subject=Munājāt Support Request');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open email app')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(ThemeData theme, String title, List<_FAQEntry> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 4),
          childrenPadding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
          iconColor: const Color(0xFFD4A574),
          collapsedIconColor: const Color(0xFFD4A574),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFFD4A574),
            ),
          ),
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 12),
                  iconColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  collapsedIconColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  backgroundColor: theme.colorScheme.surface,
                  collapsedBackgroundColor: theme.colorScheme.surface,
                  title: Text(
                    item.question,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        item.answer,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FAQEntry {
  final String question;
  final String answer;
  const _FAQEntry(this.question, this.answer);
}
