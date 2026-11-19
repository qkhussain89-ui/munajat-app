import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:hearth_prayer/components/primary_button.dart';
import 'package:hearth_prayer/components/secondary_button.dart';
import 'package:hearth_prayer/services/revenucat_service.dart';
import 'package:hearth_prayer/theme.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = false;
  bool _fetchingOfferings = true;
  bool _isPro = false;
  Offering? _offering;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _fetchingOfferings = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        RevenueCatService().isProUser(),
        RevenueCatService().getOfferings(),
      ]);
      if (mounted) {
        setState(() {
          _isPro = results[0] as bool;
          final offerings = results[1] as Offerings?;
          _offering = offerings?.current;
          _fetchingOfferings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unable to load subscription options.';
          _fetchingOfferings = false;
        });
      }
    }
  }

  Future<void> _purchase(Package package) async {
    setState(() => _isLoading = true);
    try {
      final result = await RevenueCatService().purchasePackage(package);

      if (result == null) {
        // User cancelled — do nothing, no error toast
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final success = result;

      if (success && mounted) {
        setState(() => _isPro = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscribed successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
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

  Future<void> _restore() async {
    setState(() => _isLoading = true);
    try {
      final restored = await RevenueCatService().restorePurchases();
      if (mounted) {
        setState(() {
          if (restored) _isPro = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(restored ? 'Purchases restored!' : 'No purchases found to restore.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;

    // Derive prices from offerings
    final monthlyPrice = _offering?.monthly?.storeProduct.priceString ?? '—';
    final trialLabel = _offering?.monthly?.storeProduct.introductoryPrice != null
        ? '3-day free trial'
        : '3-day free trial';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: context.brandTokens.border.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => context.brandTokens.copperGradient.createShader(bounds),
          child: const Text(
            'Premium Subscription',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
      body: _fetchingOfferings
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, style: GoogleFonts.poppins(fontSize: 14, color: textSecondary)),
                        const SizedBox(height: 16),
                        PrimaryButton(label: 'Retry', onPressed: _loadData),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(DesignTokens.copperStart).withValues(alpha: 0.1),
                                Color(DesignTokens.copperEnd).withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trialLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(DesignTokens.copperStart),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$monthlyPrice/month',
                                style: GoogleFonts.poppins(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w300,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildBullet('Auto-renews monthly', textSecondary),
                                  const SizedBox(height: 8),
                                  _buildBullet('Cancel anytime', textSecondary),
                                  const SizedBox(height: 8),
                                  _buildBullet('Payments handled securely by Apple', textSecondary),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (!_isPro)
                          Column(
                            children: [
                              if (_offering?.monthly != null)
                                PrimaryButton(
                                  label: 'Start Free Trial',
                                  isLoading: _isLoading,
                                  onPressed: () => _purchase(_offering!.monthly!),
                                ),
                              if (_offering?.annual != null) ...[
                                const SizedBox(height: 12),
                                PrimaryButton(
                                  label: 'Subscribe Annual (${_offering!.annual!.storeProduct.priceString})',
                                  isLoading: _isLoading,
                                  onPressed: () => _purchase(_offering!.annual!),
                                ),
                              ],
                              const SizedBox(height: 12),
                              SecondaryButton(
                                label: 'Restore Purchases',
                                onPressed: _restore,
                              ),
                            ],
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: AppColors.success, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Active Subscription',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.success,
                                        ),
                                      ),
                                      Text(
                                        'You have access to all premium features',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 32),
                        Text(
                          'What\'s Included',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFeature('AI-powered duʿā generation', textPrimary),
                              const SizedBox(height: 12),
                              _buildFeature('Unlimited duʿā storage', textPrimary),
                              const SizedBox(height: 12),
                              _buildFeature('Custom reminders & notifications', textPrimary),
                              const SizedBox(height: 12),
                              _buildFeature('Text-to-speech & audio playback', textPrimary),
                              const SizedBox(height: 12),
                              _buildFeature('Flow Mode for distraction-free reading', textPrimary),
                              const SizedBox(height: 12),
                              _buildFeature('Community duʿā sharing', textPrimary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildBullet(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 8, right: 8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: color,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeature(String feature, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check, size: 20, color: Color(DesignTokens.copperStart)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            feature,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: color,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
