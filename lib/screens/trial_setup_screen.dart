import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hearth_prayer/theme.dart';
import 'package:hearth_prayer/theme/brand_theme.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:hearth_prayer/components/copper_button.dart';
import 'package:hearth_prayer/state/app_state.dart';
import 'package:hearth_prayer/services/revenucat_service.dart';
import 'package:hearth_prayer/services/user_service.dart';
import 'package:hearth_prayer/services/dua_service.dart';
import 'package:hearth_prayer/models/signup_data.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class TrialSetupScreen extends StatefulWidget {
  final SignupData? signupData;
  final bool isConvertingAnonymous;
  const TrialSetupScreen({
    super.key,
    this.signupData,
    this.isConvertingAnonymous = false,
  });

  @override
  State<TrialSetupScreen> createState() => _TrialSetupScreenState();
}

class _TrialSetupScreenState extends State<TrialSetupScreen> {
  bool _isLoading = false;
  String _priceString = '';
  Offering? _offering;
  Package? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _loadPrice();
  }

  Future<void> _loadPrice() async {
    try {
      final offerings = await RevenueCatService().getOfferings();
      final offering = offerings?.current;
      if (offering != null && mounted) {
        final monthlyPkg = offering.monthly;
        setState(() {
          _offering = offering;
          _selectedPackage = monthlyPkg ?? offering.availablePackages.first;
          _priceString = monthlyPkg != null
              ? '${monthlyPkg.storeProduct.priceString}/month'
              : '';
        });
      }
    } catch (_) {
      // Price will remain empty; cards will show loading state
    }
  }

  void _goBackToSignIn() {
    if (widget.isConvertingAnonymous) {
      // Go back to signup screen (which goes back to preview)
      Navigator.pop(context);
    } else {
      // Original behaviour: pop to /signin or navigate there
      bool foundSignIn = false;
      Navigator.of(context).popUntil((route) {
        if (route.settings.name == '/signin') {
          foundSignIn = true;
          return true;
        }
        return false;
      });
      if (!foundSignIn && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/signin', (route) => false);
      }
    }
  }

  Future<void> _handleSkip() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      if (widget.isConvertingAnonymous && widget.signupData != null) {
        // Convert anonymous user to real account
        final sd = widget.signupData!;
        final converted = await UserService.convertAnonymousToEmail(
          email: sd.email,
          password: sd.password,
          firstName: sd.firstName,
          lastName: sd.lastName,
        );

        if (converted && mounted) {
          // Mark profile as complete
          await UserService.markProfileComplete();

          // Save pending du'a if exists
          if (sd.pendingDuaText != null && sd.pendingDuaText!.isNotEmpty) {
            await DuaService.createDua(
              title: 'My first du\u02BBa',
              englishText: sd.pendingDuaText!,
              body: sd.pendingDuaText!,
              tags: [],
              outputLanguage: sd.pendingDuaLanguage ?? 'english',
            );
          }

          // Update app state
          final appState = context.read<AppState>();
          appState.setAnonymous(false);
          appState.clearPendingDua();
          appState.completeSignIn();

          // Navigate to home
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else if (widget.signupData != null) {
        // Normal signup flow — create account without purchase
        final sd = widget.signupData!;
        final created = await UserService.signUp(
          context, sd.firstName, sd.lastName, sd.email, sd.password,
        );

        if (created && mounted) {
          await UserService.markProfileComplete();

          final appState = context.read<AppState>();
          appState.completeSignIn();
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      debugPrint('Skip error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPricingCardNew({
    required String title,
    required String promoPrice,
    required String period,
    required String originalPrice,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required BrandTokens brandTokens,
    String? topBadge,
    String? bottomBadge,
    String? savingsText,
    String? savingsPercent,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.05)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.15),
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Stack(
            children: [
              // Selection checkmark in top-right
              if (isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top badge (Best Value for yearly)
                  if (topBadge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        topBadge,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  // Title (Monthly/Yearly)
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Crossed out original price
                  Text(
                    originalPrice,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      decoration: TextDecoration.lineThrough,
                      decorationColor: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Promotional price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        promoPrice,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        period,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  // Savings text (for yearly)
                  if (savingsText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      savingsText,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Bottom badge (Ramadan Offer / Save %)
                  if (bottomBadge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bottomBadge,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  if (savingsPercent != null && bottomBadge == null)
                    Text(
                      savingsPercent,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _continueTrial() async {
    setState(() => _isLoading = true);

    try {
      // Use the user-selected package, or fall back to fetching offerings
      Package? package = _selectedPackage;
      if (package == null) {
        final offerings = await RevenueCatService().getOfferings();
        final offering = offerings?.current;
        if (offering == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to load subscription options. Please try again.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
        package = offering.monthly ?? offering.availablePackages.first;
      }

      // Initiate real purchase through RevenueCat
      final result = await RevenueCatService().purchasePackage(package);

      if (result == null) {
        // User cancelled — do nothing, no error toast
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final success = result;

      if (success && mounted) {
        if (widget.signupData != null) {
          // Determine signup method: anonymous conversion vs normal
          if (widget.isConvertingAnonymous) {
            // ANONYMOUS CONVERSION: Convert anonymous → real account
            final sd = widget.signupData!;
            final converted = await UserService.convertAnonymousToEmail(
              email: sd.email,
              password: sd.password,
              firstName: sd.firstName,
              lastName: sd.lastName,
            );

            if (!converted) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account creation failed. Please contact support.')),
                );
              }
              return;
            }
          } else {
            // NORMAL SIGNUP: Create Supabase account after purchase succeeds
            final signUpSuccess = await UserService.signUp(
              context,
              widget.signupData!.firstName,
              widget.signupData!.lastName,
              widget.signupData!.email,
              widget.signupData!.password,
            );

            if (!signUpSuccess) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account creation failed. Please contact support.')),
                );
              }
              return;
            }
          }

          // Mark profile as complete
          await UserService.markProfileComplete();

          // Link RevenueCat anonymous ID to the new Supabase user ID
          final currentUser = UserService.currentUser;
          if (currentUser != null) {
            await RevenueCatService().identifyUser(currentUser.id);
          }

          // Save pending du'a if exists
          if (widget.signupData!.pendingDuaText != null &&
              widget.signupData!.pendingDuaText!.isNotEmpty) {
            await DuaService.createDua(
              title: 'My first du\u02BBa',
              englishText: widget.signupData!.pendingDuaText!,
              body: widget.signupData!.pendingDuaText!,
              tags: [],
              outputLanguage: widget.signupData!.pendingDuaLanguage ?? 'english',
            );
          }
        }

        // Update app state
        if (mounted) {
          final appState = context.read<AppState>();
          if (widget.isConvertingAnonymous) {
            appState.setAnonymous(false);
            appState.clearPendingDua();
          }
          appState.completeSignIn();
        }

        // Verify entitlement (with retry for RevenueCat sync delay)
        bool hasEntitlement = false;
        for (int i = 0; i < 3; i++) {
          try {
            final customerInfo = await Purchases.getCustomerInfo();
            hasEntitlement = customerInfo.entitlements.active.containsKey('Munajat Dua Studio Pro');
            if (hasEntitlement) break;
            await Future.delayed(const Duration(seconds: 1));
          } catch (e) {
            debugPrint('Entitlement check attempt ${i + 1} failed: $e');
            if (i < 2) await Future.delayed(const Duration(seconds: 1));
          }
        }

        if (!hasEntitlement) {
          debugPrint('Warning: Purchase succeeded but entitlement not active yet');
          // Navigate anyway - entitlement will sync eventually
        }

        // Navigate to home
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase was not completed. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brandTokens = context.brandTokens;

    return WillPopScope(
      onWillPop: () async {
        _goBackToSignIn();
        return false;
      },
      child: Scaffold(
        backgroundColor: colorScheme.background,
        body: SafeArea(
          child: Stack(
          children: [
            // Main scrollable content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 44),

                  // Full branding stack (75% of welcome screen)
                  Column(
                    children: [
                      // Bismillah text
                      Text(
                        'بِسْمِ ٱللَّهِ',
                        style: GoogleFonts.amiri(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                          height: 1.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // "welcome to" label
                      Text(
                        'welcome to',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Top decorative line
                      Container(
                        width: 70,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Munājāt wordmark
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFFB87333), Color(0xFFFFD9A0)],
                        ).createShader(bounds),
                        child: Text(
                          'Munājāt',
                          style: GoogleFonts.poppins(
                            fontSize: 52,
                            fontWeight: FontWeight.w100,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bottom decorative line
                      Container(
                        width: 70,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tagline
                      Text(
                        'Your personal Duʿā companion',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Title with Gradient
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return copperGradient(theme.brightness).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        );
                      },
                      child: Text(
                        'Start Your 3-Day Free Trial',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Body Text
                  Center(
                    child: Text(
                      'Experience Munājāt free for 3 days — your subscription begins only after your trial ends.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: colorScheme.secondary.withOpacity(0.65),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Features Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: brandTokens.border,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FeatureRow('Turn your thoughts into beautiful du\u02BBās — just type or speak what\u2019s in your heart', colorScheme, brandTokens),
                        const SizedBox(height: 16),
                        _FeatureRow('Every du\u02BBā rooted in Quran & Sunnah, woven with the 99 Names of Allah', colorScheme, brandTokens),
                        const SizedBox(height: 16),
                        _FeatureRow('Save, organize, and revisit your personal supplications in 8 languages', colorScheme, brandTokens),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Pricing Cards
                  if (_offering != null) ...[
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_offering!.monthly != null)
                            _buildPricingCardNew(
                              title: 'Monthly',
                              promoPrice: _offering!.monthly!.storeProduct.priceString,
                              period: '/month',
                              originalPrice: '£4.99/month',
                              isSelected: _selectedPackage == _offering!.monthly,
                              onTap: () => setState(() => _selectedPackage = _offering!.monthly),
                              colorScheme: colorScheme,
                              brandTokens: brandTokens,
                              bottomBadge: 'Ramadan Offer',
                            ),
                          if (_offering!.monthly != null && _offering!.annual != null)
                            const SizedBox(width: 12),
                          if (_offering!.annual != null)
                            _buildPricingCardNew(
                              title: 'Yearly',
                              promoPrice: _offering!.annual!.storeProduct.priceString,
                              period: '/year',
                              originalPrice: '£29.99/year',
                              isSelected: _selectedPackage == _offering!.annual,
                              onTap: () => setState(() => _selectedPackage = _offering!.annual),
                              colorScheme: colorScheme,
                              brandTokens: brandTokens,
                              topBadge: 'Best Value',
                              savingsText: 'Just £1.67/month',
                              savingsPercent: 'Save 44%',
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Continue Button
                  CopperButton(
                    text: 'Continue',
                    onPressed: _isLoading ? null : _continueTrial,
                    variant: CopperButtonVariant.primary,
                    size: CopperButtonSize.md,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 12),

                  // Continue without subscribing (skip) button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _handleSkip,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: BorderSide(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Continue without subscribing',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Reassurance text
                  Center(
                    child: Text(
                      'You can subscribe anytime from Settings',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Renewal & Cancellation Notice
                  Center(
                    child: Text(
                      _offering != null
                          ? '3-day free trial, then ${_offering!.monthly?.storeProduct.priceString ?? "£2.99"}/month or ${_offering!.annual?.storeProduct.priceString ?? "£19.99"}/year. Cancel anytime in Settings \u2014 no questions asked.'
                          : '3-day free trial, then £2.99/month or £19.99/year. Cancel anytime in Settings \u2014 no questions asked.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                        color: colorScheme.secondary.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Terms & Privacy
                  Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'By continuing, you agree to our ',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                              color: colorScheme.secondary.withOpacity(0.6),
                              height: 1.4,
                            ),
                          ),
                          TextSpan(
                            text: 'Terms of Service',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                              color: colorScheme.primary,
                              decoration: TextDecoration.underline,
                              height: 1.4,
                            ),
                          ),
                          TextSpan(
                            text: ' and ',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                              color: colorScheme.secondary.withOpacity(0.6),
                              height: 1.4,
                            ),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                              color: colorScheme.primary,
                              decoration: TextDecoration.underline,
                              height: 1.4,
                            ),
                          ),
                          TextSpan(
                            text: '.',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                              color: colorScheme.secondary.withOpacity(0.6),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Top-left Back control (inside SafeArea)
            Positioned(
              top: 12,
              left: 16,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _goBackToSignIn,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chevron_left,
                      size: 24,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Back',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  final ColorScheme colorScheme;
  final BrandTokens brandTokens;

  const _FeatureRow(this.text, this.colorScheme, this.brandTokens);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            size: 12,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
