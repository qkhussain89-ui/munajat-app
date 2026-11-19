import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  static const String _apiKey = 'appl_pBwoClTaLfEvvNLvvfXmknVcKxp';

  // Product identifiers matching RevenueCat dashboard
  static const String monthlyProductId = 'munajat_dua_monthly';
  static const String yearlyProductId = 'munajat_dua_yearly';

  // Entitlement identifier matching RevenueCat dashboard
  static const String entitlementId = 'Munajat Dua Studio Pro';

  bool _isInitialised = false;

  /// Reactive notifiers for subscription state — updated by listener + on init.
  final ValueNotifier<bool> isProNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isTrialNotifier = ValueNotifier<bool>(false);

  /// Call this once at app startup (e.g., in main.dart)
  Future<void> initialise() async {
    if (_isInitialised) return;

    // RevenueCat does not support web — skip init on web to avoid PlatformException
    if (kIsWeb) {
      debugPrint('RevenueCat: Skipping init on web (not supported)');
      _isInitialised = true;
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration = PurchasesConfiguration(_apiKey);
      await Purchases.configure(configuration);

      _isInitialised = true;

      // Set initial subscription state and register listener for changes
      await _updateSubscriptionState();
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _updateSubscriptionState();
      });
    } catch (e) {
      debugPrint('RevenueCat initialise error: $e');
      // Mark as initialised to prevent retry loops, but features will gracefully degrade
      _isInitialised = true;
    }
  }

  /// Public API to refresh subscription state (notifiers + Supabase sync).
  /// Call this from outside the service, e.g. on app resume.
  Future<void> refreshSubscriptionStatus() => _updateSubscriptionState();

  /// Refreshes the reactive isProNotifier / isTrialNotifier from RevenueCat
  /// and syncs the subscription_status to the Supabase users table.
  Future<void> _updateSubscriptionState() async {
    try {
      final pro = await isProUser();
      final trial = await isInTrial();
      isProNotifier.value = pro;
      isTrialNotifier.value = trial;
      debugPrint('RevenueCat state updated: isPro=${isProNotifier.value}, isTrial=${isTrialNotifier.value}');

      // Determine the Supabase subscription_status string
      final String status;
      if (pro && trial) {
        status = 'trial';
      } else if (pro && !trial) {
        status = 'active';
      } else {
        status = 'expired';
      }

      // Sync to Supabase users table
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          await Supabase.instance.client
              .from('users')
              .update({'subscription_status': status})
              .eq('id', userId);
          debugPrint('Synced subscription_status to Supabase: $status for user $userId');
        }
      } catch (e) {
        debugPrint('Failed to sync subscription_status to Supabase: $e');
      }
    } catch (e) {
      debugPrint('RevenueCat _updateSubscriptionState error: $e');
    }
  }

  /// Check if user has active Pro entitlement
  Future<bool> isProUser() async {
    if (kIsWeb) return false;
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint('RevenueCat isProUser error: $e');
      return false;
    }
  }

  /// Check if user is in a free trial
  Future<bool> isInTrial() async {
    if (kIsWeb) return false;
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[entitlementId];
      if (entitlement == null || !entitlement.isActive) return false;
      return entitlement.periodType == PeriodType.trial;
    } catch (e) {
      debugPrint('RevenueCat isInTrial error: $e');
      return false;
    }
  }

  /// Get available offerings (packages with prices)
  Future<Offerings?> getOfferings() async {
    if (kIsWeb) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('RevenueCat getOfferings error: $e');
      return null;
    }
  }

  /// Purchase a specific package.
  ///
  /// Returns `true` when the transaction completes (Apple/Google confirms
  /// payment). The entitlement may take a moment to propagate — callers
  /// should verify entitlement separately if needed.
  ///
  /// Returns `false` only when the purchase genuinely failed or the user
  /// cancelled.  A `null` return means the user explicitly cancelled
  /// (no error toast should be shown).
  Future<bool?> purchasePackage(Package package) async {
    if (kIsWeb) return false;
    try {
      final result = await Purchases.purchasePackage(package);

      // If Purchases.purchasePackage() returns without throwing,
      // the transaction was successful — Apple/Google confirmed payment.
      // The entitlement may not be immediately active (sandbox sync delay),
      // so we trust the transaction success rather than the entitlement flag.
      await _updateSubscriptionState();

      return true;
    } on PlatformException catch (e) {
      // RevenueCat wraps store errors in PlatformException.
      // Error code 1 = purchaseCancelledError (user tapped Cancel).
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('RevenueCat: user cancelled purchase');
        return null; // Distinguish cancellation from failure
      }
      if (errorCode == PurchasesErrorCode.productAlreadyPurchasedError) {
        debugPrint('RevenueCat: product already purchased — treating as success');
        try {
          await _updateSubscriptionState();
        } catch (updateError) {
          debugPrint('RevenueCat: subscription state update after already-purchased failed: $updateError');
        }
        return true;
      }
      debugPrint('RevenueCat purchase error: $e');
      return false;
    } catch (e) {
      debugPrint('RevenueCat purchase error: $e');
      return false;
    }
  }

  /// Restore previous purchases
  Future<bool> restorePurchases() async {
    if (kIsWeb) return false;
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint('RevenueCat restore error: $e');
      return false;
    }
  }

  /// Get customer info for display
  Future<CustomerInfo?> getCustomerInfo() async {
    if (kIsWeb) return null;
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('RevenueCat getCustomerInfo error: $e');
      return null;
    }
  }

  /// Identify user (call after authentication)
  Future<void> identifyUser(String userId) async {
    if (kIsWeb) return;
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('RevenueCat identify error: $e');
    }
  }

  /// Log out (call on sign out)
  Future<void> logOut() async {
    if (kIsWeb) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('RevenueCat logOut error: $e');
    }
  }
}
