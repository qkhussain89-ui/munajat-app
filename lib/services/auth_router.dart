import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hearth_prayer/services/revenucat_service.dart';
import 'package:hearth_prayer/state/app_state.dart';
import 'package:hearth_prayer/supabase/supabase_config.dart';
import 'package:hearth_prayer/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralised post-authentication routing.
/// Call this after ANY successful sign-in or sign-up
/// (email, Google OAuth, Apple OAuth).
/// It checks profile completion and subscription status
/// then navigates to the correct screen.
class AuthRouter {
  /// Determines the correct screen after authentication and navigates there.
  /// [context] - BuildContext for navigation and Provider access
  /// [isNewSignUp] - true if user just created their account via email sign-up
  ///                 (they will always need profile setup).
  ///                 false for sign-in and OAuth (check DB).
  static Future<void> routeAfterAuth(
    BuildContext context, {
    bool isNewSignUp = false,
  }) async {
    try {
      // -- Step 1: Check if user is authenticated with Supabase --
      final session = Supabase.instance.client.auth.currentSession;
      final authUser = session?.user;

      if (authUser == null) {
        // NOT logged in - go to welcome screen, NOT trial screen
        if (kDebugMode) debugPrint('AuthRouter: No active session - routing to welcome');
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/signin');
        }
        return;
      }

      if (kDebugMode) debugPrint('AuthRouter: Authenticated as ${authUser.email} (${authUser.id})');

      // -- Step 2: Identify user with RevenueCat (already logged in) --
      await RevenueCatService().identifyUser(authUser.id);

      // -- Step 2a: Check if this is an anonymous user (no email = anonymous) --
      if (authUser.email == null || authUser.email!.isEmpty) {
        // Anonymous user returning - send to trial paywall
        // (not profile setup, not home)
        if (kDebugMode) debugPrint('AuthRouter: Anonymous user detected - routing to freeTrial');
        if (context.mounted) {
          final appState = Provider.of<AppState>(context, listen: false);
          appState.setAnonymous(true);
          appState.completeSignIn(); // So route guard allows access
          Navigator.of(context).pushReplacementNamed('/freeTrial');
        }
        return;
      }

      // -- Step 2b: If this is a fresh email sign-up, go straight to trial --
      if (isNewSignUp) {
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/freeTrial');
        }
        return;
      }

      // -- Step 3: Mark profile as complete if not already --
      // (ProfileSetupScreen has been removed - profile is
      // considered complete once account exists)
      try {
        final response = await SupabaseConfig.client
            .from('users')
            .select('profile_completed')
            .eq('id', authUser.id)
            .maybeSingle();

        if (response != null && response['profile_completed'] != true) {
          await UserService.markProfileComplete();
        }
      } catch (e) {
        debugPrint('AuthRouter: Error checking/setting profile_completed: $e');
      }

      // -- Step 4: Check RevenueCat subscription status --
      final isPro = await RevenueCatService().isProUser();
      final inTrial = await RevenueCatService().isInTrial();

      if (kDebugMode) debugPrint('AuthRouter: isPro=$isPro, inTrial=$inTrial');

      if (!isPro && !inTrial) {
        // Also check SharedPreferences / DB as fallback (RevenueCat may not be
        // configured yet, or user is on web where RevenueCat is unavailable)
        final prefs = await SharedPreferences.getInstance();
        final subscriptionStatus =
            prefs.getString('subscription_status') ?? 'none';

        if (subscriptionStatus == 'none') {
          final dbStatus =
              await _checkDbSubscriptionStatus(authUser.id);
          if (dbStatus != null && dbStatus != 'none') {
            await prefs.setString('subscription_status', dbStatus);
          } else {
            // Genuinely no subscription - show trial screen
            if (kDebugMode) debugPrint(
                'AuthRouter: No subscription found - routing to freeTrial');
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/freeTrial');
            }
            return;
          }
        }
      }

      // -- Step 5: All checks passed - route to home --
      if (kDebugMode) debugPrint('AuthRouter: All checks passed - routing to home');
      if (context.mounted) {
        final appState = Provider.of<AppState>(context, listen: false);
        appState.completeSignIn();
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('AuthRouter: Error during routing: $e');
      // Fallback: go to welcome/sign-in screen to be safe (never trial)
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/signin');
      }
    }
  }

  /// Checks the subscription_status field in the Supabase users table.
  /// Returns the status string or null if not found.
  static Future<String?> _checkDbSubscriptionStatus(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from('users')
          .select('subscription_status')
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        final status = response['subscription_status'] as String?;
        if (status != null && status.isNotEmpty && status != 'none') {
          return status;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('AuthRouter: Error checking DB subscription status: $e');
    }
    return null;
  }
}
