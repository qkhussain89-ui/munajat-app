import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hearth_prayer/theme.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:hearth_prayer/components/copper_button.dart';
import 'package:hearth_prayer/services/revenucat_service.dart';

class ChangePlanScreen extends StatefulWidget {
  const ChangePlanScreen({super.key});

  @override
  State<ChangePlanScreen> createState() => _ChangePlanScreenState();
}

class _ChangePlanScreenState extends State<ChangePlanScreen> {
  bool _loading = true;
  String? _loadingPlan; // 'monthly' or 'yearly' or null
  bool _isPro = false;
  bool _isTrialing = false;
  CustomerInfo? _customerInfo;
  Offering? _offering;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        RevenueCatService().isProUser(),
        RevenueCatService().isInTrial(),
        RevenueCatService().getCustomerInfo(),
        RevenueCatService().getOfferings(),
      ]);
      if (mounted) {
        setState(() {
          _isPro = results[0] as bool;
          _isTrialing = results[1] as bool;
          _customerInfo = results[2] as CustomerInfo?;
          final offerings = results[3] as Offerings?;
          _offering = offerings?.current;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unable to load plan options.';
          _loading = false;
        });
      }
    }
  }

  String get _currentPlanLabel {
    if (_isTrialing) return 'Free Trial';
    if (_isPro) {
      final subs = _customerInfo?.activeSubscriptions ?? <String>[];
      if (subs.contains(RevenueCatService.yearlyProductId)) return 'Yearly';
      if (subs.contains(RevenueCatService.monthlyProductId)) return 'Monthly';
      return 'Pro';
    }
    return 'No active plan';
  }

  String get _statusLine {
    if (_isTrialing) return 'Trial active';
    if (_isPro) return 'Active';
    return 'Inactive';
  }

  String get _nextPaymentLine {
    final entitlement = _customerInfo?.entitlements.all[RevenueCatService.entitlementId];
    if (entitlement?.expirationDate != null) {
      return entitlement!.expirationDate!;
    }
    return '—';
  }

  Future<void> _purchasePackage(Package package, String planType) async {
    setState(() => _loadingPlan = planType);
    try {
      final result = await RevenueCatService().purchasePackage(package);

      if (result == null) {
        // User cancelled — do nothing, no error toast
        if (mounted) setState(() => _loadingPlan = null);
        return;
      }

      final success = result;

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plan updated successfully!', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
            backgroundColor: AppColors.copper,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
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
      if (mounted) setState(() => _loadingPlan = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bt = context.brandTokens;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  border: Border(
                    bottom: BorderSide(color: bt.border.withValues(alpha: 0.35), width: 1),
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
                          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: theme.colorScheme.secondary),
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
                          'Change Plan',
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
                    CopperButton(text: 'Retry', onPressed: _loadData),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          _row(theme, 'Plan', _currentPlanLabel),
                          const SizedBox(height: 12),
                          _row(theme, 'Status', _statusLine),
                          const SizedBox(height: 12),
                          _row(theme, 'Next payment', _nextPaymentLine),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Available Plans', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    if (_offering != null) ...[
                      if (_offering!.monthly != null)
                        _planCard(
                          context,
                          title: 'Monthly',
                          price: _offering!.monthly!.storeProduct.priceString,
                          note: 'Billed monthly. Cancel anytime.',
                          isLoading: _loadingPlan == 'monthly',
                          onSelect: _loadingPlan != null ? null : () => _purchasePackage(_offering!.monthly!, 'monthly'),
                        ),
                      if (_offering!.monthly != null && _offering!.annual != null)
                        const SizedBox(height: 12),
                      if (_offering!.annual != null)
                        _planCard(
                          context,
                          title: 'Yearly',
                          price: _offering!.annual!.storeProduct.priceString,
                          note: 'Save compared to monthly.',
                          badge: 'Best value',
                          isLoading: _loadingPlan == 'yearly',
                          onSelect: _loadingPlan != null ? null : () => _purchasePackage(_offering!.annual!, 'yearly'),
                        ),
                      if (_offering!.monthly == null && _offering!.annual == null)
                        for (final pkg in _offering!.availablePackages)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _planCard(
                              context,
                              title: pkg.storeProduct.title,
                              price: pkg.storeProduct.priceString,
                              note: pkg.storeProduct.description,
                              isLoading: _loadingPlan == pkg.identifier,
                              onSelect: _loadingPlan != null ? null : () => _purchasePackage(pkg, pkg.identifier),
                            ),
                          ),
                    ] else
                      Text(
                        'No plans available at this time.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Apple App Store subscription disclosure
                    Padding(
                      padding: const EdgeInsets.only(left: 0, right: 0, bottom: 8),
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 11.0,
                            color: Colors.grey.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: '3-day free trial, then ${_offering?.monthly?.storeProduct.priceString ?? ''}/month or ${_offering?.annual?.storeProduct.priceString ?? ''}/year. Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period. Manage or cancel your subscription in your Apple ID Account Settings. By subscribing, you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms of Use',
                              style: TextStyle(
                                fontSize: 11.0,
                                color: Colors.grey.withValues(alpha: 0.7),
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => launchUrl(Uri.parse('https://qkhussain89-ui.github.io/munajat-support/terms.html')),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                fontSize: 11.0,
                                color: Colors.grey.withValues(alpha: 0.7),
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => launchUrl(Uri.parse('https://qkhussain89-ui.github.io/munajat-support/privacy.html')),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
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

  Widget _row(ThemeData theme, String l, String v) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
          Text(v, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      );

  Widget _planCard(BuildContext context, {required String title, required String price, required String note, String? badge, required bool isLoading, VoidCallback? onSelect}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('$price / ${title.toLowerCase()}', style: theme.textTheme.bodyMedium),
                ]),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(badge, style: theme.textTheme.labelSmall),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(note, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CopperButton(
              text: isLoading ? 'Processing…' : 'Select $title',
              onPressed: isLoading ? null : onSelect,
            ),
          ),
        ],
      ),
    );
  }
}
