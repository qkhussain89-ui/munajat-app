import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:hearth_prayer/theme/brand_theme.dart';
import 'package:hearth_prayer/state/app_state.dart';
import 'package:hearth_prayer/services/auth_router.dart';

import 'package:hearth_prayer/screens/splash_screen.dart';
import 'package:hearth_prayer/screens/intro_landing_screen.dart' as intro;
import 'package:hearth_prayer/screens/welcome_screen.dart';
import 'package:hearth_prayer/screens/sign_up_screen.dart';
import 'package:hearth_prayer/screens/forgot_password_screen.dart';
import 'package:hearth_prayer/screens/trial_setup_screen.dart';
import 'package:hearth_prayer/screens/home_screen.dart';
import 'package:hearth_prayer/screens/create_refined_screen.dart';
import 'package:hearth_prayer/screens/my_duas_refined_screen.dart';
import 'package:hearth_prayer/state/my_duas_controller.dart';
import 'package:hearth_prayer/screens/profile_refined_screen.dart';
import 'package:hearth_prayer/screens/preview_screen.dart';
import 'package:hearth_prayer/screens/viewer_refined_screen.dart';
import 'package:hearth_prayer/screens/edit_dua_screen.dart';
import 'package:hearth_prayer/screens/dua_reflection_screen.dart';
import 'package:hearth_prayer/screens/journal_screen.dart';
import 'package:hearth_prayer/screens/journal_history_screen.dart';
import 'package:hearth_prayer/screens/how_it_works_screen.dart';
import 'package:hearth_prayer/screens/prayer_times_screen.dart';

import 'package:hearth_prayer/components/bottom_nav_refined.dart';

import 'package:hearth_prayer/services/dua_service.dart';
import 'package:hearth_prayer/services/folder_service.dart';
import 'package:hearth_prayer/services/islamic_event_service.dart';
import 'package:hearth_prayer/services/journal_service.dart';
import 'package:hearth_prayer/services/user_service.dart';
import 'package:hearth_prayer/services/prayer_times_service.dart'; // ✅ ADDED
import 'package:hearth_prayer/models/dua.dart';
import 'package:hearth_prayer/supabase/supabase_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/revenucat_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  // ✅ ADDED: Warm prayer-times cache at startup (safe, lightweight, offline-friendly)
  await PrayerTimesService.initialize();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Initialise RevenueCat
  await RevenueCatService().initialise();

  // Global error handlers to expose root-cause stack traces in logs
  FlutterError.onError = (FlutterErrorDetails details) {
    // Preserve default behavior
    FlutterError.presentError(details);
    // Also print a concise version to the console
    debugPrint('FlutterError: \n${details.exceptionAsString()}');
    if (details.stack != null) {
      debugPrint(details.stack.toString());
    }
  };
  ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Uncaught platform error: ' + error.toString());
    debugPrint(stack.toString());
    // Return true to signal that we handled the error
    return true;
  };
  await FolderService.initialize();
  await UserService.initialize();
  await JournalService.initialize();
  // Defer heavy service initialization to run in background (non-blocking)
  DuaService.initialize();
  IslamicEventService.initialize();
  runApp(const MunajatApp());
}

class MunajatApp extends StatelessWidget {
  const MunajatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          ThemeData theme;
          if (appState.themeMode == ThemeMode.light) {
            theme = BrandTheme.light();
          } else if (appState.themeMode == ThemeMode.system) {
            final brightness = MediaQuery.of(context).platformBrightness;
            theme = brightness == Brightness.dark ? BrandTheme.dark() : BrandTheme.light();
          } else {
            theme = BrandTheme.dark();
          }

          final isDark = theme.brightness == Brightness.dark;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            ),
            child: MaterialApp(
              title: 'Munājāt',
              debugShowCheckedModeBanner: false,
              theme: theme,
              themeMode: appState.themeMode,
              initialRoute: '/splash',
              onGenerateRoute: (settings) {
                // Centralized route guard: redirect unauthenticated users away from protected routes
                bool requiresAuth(String? name) {
                  const protected = <String>{
                    '/home',
                    '/viewer',
                    '/edit_dua',
                    '/journalHistory',
                    '/duaReflection',
                    '/prayerTimes',
                  };
                  return protected.contains(name);
                }

                if (requiresAuth(settings.name) && !appState.isAuthenticated) {
                  return MaterialPageRoute(
                    builder: (_) => const WelcomeScreen(),
                    settings: const RouteSettings(name: '/signin'),
                  );
                }
                // Splash/Auth/App flow
                if (settings.name == '/splash') {
                  return MaterialPageRoute(builder: (_) => const SplashScreenWrapper(), settings: settings);
                }
                if (settings.name == '/intro') {
                  return MaterialPageRoute(builder: (_) => const IntroLandingWrapper(), settings: settings);
                }
                if (settings.name == '/signin') {
                  return MaterialPageRoute(builder: (_) => const WelcomeScreen(), settings: settings);
                }
                if (settings.name == '/signup') {
                  return MaterialPageRoute(builder: (_) => const SignUpScreen(), settings: settings);
                }

                if (settings.name == '/forgot-password') {
                  return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen(), settings: settings);
                }
                if (settings.name == '/trial-setup' || settings.name == '/freeTrial') {
                  return MaterialPageRoute(builder: (_) => const TrialSetupScreen(), settings: settings);
                }
                if (settings.name == '/home') {
                  return MaterialPageRoute(builder: (_) => const AppContainer(), settings: settings);
                }
                if (settings.name == '/preview') {
                  final args = settings.arguments as Map<String, String>? ?? {'english': '', 'arabic': '', 'transliteration': ''};
                  return MaterialPageRoute(
                    builder: (_) => PreviewScreen(duaData: args),
                    settings: settings,
                  );
                }
                if (settings.name == '/viewer') {
                  final args = settings.arguments;
                  if (args is Dua) {
                    return MaterialPageRoute(
                      builder: (_) => ViewerRefinedScreen(dua: args),
                      settings: settings,
                    );
                  }
                  return MaterialPageRoute(builder: (_) => const AppContainer(), settings: settings);
                }
                if (settings.name == '/edit_dua') {
                  final args = settings.arguments;
                  if (args is Dua) {
                    return MaterialPageRoute(
                      builder: (_) => EditDuaScreen(dua: args),
                      settings: settings,
                    );
                  }
                  return MaterialPageRoute(builder: (_) => const AppContainer(), settings: settings);
                }
                if (settings.name == '/duaReflection') {
                  return MaterialPageRoute(builder: (_) => const DuaReflectionScreen(), settings: settings);
                }
                if (settings.name == '/journalHistory') {
                  return MaterialPageRoute(builder: (_) => const JournalHistoryScreen(), settings: settings);
                }
                if (settings.name == '/how-it-works') {
                  return MaterialPageRoute(builder: (_) => const HowItWorksScreen(), settings: settings);
                }
                if (settings.name == '/createDua') {
                  final args = settings.arguments as Map<String, dynamic>? ?? {};
                  return MaterialPageRoute(
                    builder: (_) => CreateRefinedScreen(
                      draftText: args['draftText'] as String?,
                      initialMode: args['initialMode'] as String?,
                      autoStartRecording: args['autoStartRecording'] as bool? ?? false,
                      showBackButton: args['showBackButton'] as bool? ?? true,
                    ),
                    settings: settings,
                  );
                }
                if (settings.name == '/prayerTimes') {
                  return MaterialPageRoute(builder: (_) => const PrayerTimesScreen(), settings: settings);
                }
                return MaterialPageRoute(builder: (_) => const AppContainer(), settings: settings);
              },
            ),
          );
        },
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _navigationFired = false;

  void _handleSplashComplete() {
    if (!mounted || _navigationFired) return;
    _navigationFired = true;
    _decideNextRoute();
  }

  Future<void> _decideNextRoute() async {
    try {
      // Hydrate placeholder session from UserService into AppState before routing
      final user = UserService.currentUser;
      if (user != null) {
        context.read<AppState>().setUser(user);
      } else {
        // Ensure logged-out state is reflected deterministically
        context.read<AppState>().logout();
      }

      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('onboarding_seen') ?? false;

      if (!mounted) return;
      if (!seen) {
        Navigator.of(context).pushReplacementNamed('/intro');
        return;
      }

      if (context.read<AppState>().isAuthenticated) {
        // Returning logged-in user — still check profile + subscription
        if (mounted) await AuthRouter.routeAfterAuth(context);
      } else {
        Navigator.of(context).pushReplacementNamed('/signin');
      }
    } catch (e) {
      debugPrint('Error during startup routing: $e');
      if (!mounted) return;
      // Fallback to onboarding to keep user in a safe state
      Navigator.of(context).pushReplacementNamed('/intro');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(onComplete: _handleSplashComplete);
  }
}

class IntroLandingWrapper extends StatefulWidget {
  const IntroLandingWrapper({super.key});

  @override
  State<IntroLandingWrapper> createState() => _IntroLandingWrapperState();
}

class _IntroLandingWrapperState extends State<IntroLandingWrapper> {
  bool _navigationFired = false;
  bool _isLoading = false;

  Future<void> _handleIntroComplete() async {
    if (!mounted || _navigationFired) return;
    _navigationFired = true;
    
    // Show loading immediately
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_seen', true);
      // Sign in anonymously before navigating to Create Du'a
      final success = await UserService.signInAnonymously(context);
      if (success && mounted) {
        context.read<AppState>().setAnonymous(true);
        context.read<AppState>().completeSignIn();
        Navigator.of(context).pushReplacementNamed(
          '/createDua',
          arguments: {'showBackButton': false},
        );
      } else if (mounted) {
        // Fallback: if anonymous sign-in fails, go to regular sign-in
        setState(() => _isLoading = false);
        _navigationFired = false;
        Navigator.of(context).pushReplacementNamed('/signin');
      }
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _navigationFired = false;
        Navigator.of(context).pushReplacementNamed('/signin');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return intro.IntroLandingScreen(
      onComplete: _handleIntroComplete,
      isLoading: _isLoading,
    );
  }
}

class AppContainer extends StatefulWidget {
  const AppContainer({super.key});

  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late MainTab _currentTab;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentTab = MainTab.inspire;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppState>().setShowTabBar(true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh subscription state when returning from background
      // (e.g. user subscribed/cancelled via Apple Settings)
      RevenueCatService().refreshSubscriptionStatus();
      debugPrint('AppContainer: Refreshing subscription state on resume');
    }
  }

  Widget _buildScreen(MainTab tab) {
    switch (tab) {
      case MainTab.inspire:
        return const HomeScreen();
      case MainTab.myDuas:
        return const MyDuasRefinedScreen();
      case MainTab.create:
        return const CreateRefinedScreen(showBackButton: false);
      case MainTab.journal:
        return const JournalScreen();
      case MainTab.me:
        return const ProfileRefinedScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: _buildScreen(_currentTab),
      bottomNavigationBar: BottomNavRefined(
        active: _currentTab,
        onChanged: (tab) {
          setState(() => _currentTab = tab);
          context.read<AppState>().setCurrentTab(_getTabName(tab));
        },
      ),
    );
  }

  String _getTabName(MainTab tab) {
    switch (tab) {
      case MainTab.inspire:
        return 'home';
      case MainTab.myDuas:
        return 'my_duas';
      case MainTab.create:
        return 'create';
      case MainTab.journal:
        return 'journal';
      case MainTab.me:
        return 'me';
    }
  }
}