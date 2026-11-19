import 'package:flutter/material.dart';
import 'package:hearth_prayer/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isAnonymous = false;
  String? _pendingDuaText;
  String? _pendingDuaLanguage;
  bool _onboardingDone = false;
  String _currentTab = 'home';
  bool _showTabBar = false;
  ThemeMode _themeMode = ThemeMode.dark;
  double _fontSizeMultiplier = 1.0; // 1.0 = 16sp base
  bool _showProcessing = false;
  String _processingText = '';
  bool _dailyReminderEnabled = true;
  bool _weeklyReflectionEnabled = true;
  bool _streakNudgesEnabled = true;
  Map<String, dynamic> _flowMode = {
    'speed': 1.0,
    'theme': 'dark',
    'isPlaying': false,
  };

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAnonymous => _isAnonymous;
  String? get pendingDuaText => _pendingDuaText;
  String? get pendingDuaLanguage => _pendingDuaLanguage;
  bool get onboardingDone => _onboardingDone;
  String get currentTab => _currentTab;
  bool get showTabBar => _showTabBar;
  ThemeMode get themeMode => _themeMode;
  double get fontSizeMultiplier => _fontSizeMultiplier;
  bool get showProcessing => _showProcessing;
  String get processingText => _processingText;
  bool get dailyReminderEnabled => _dailyReminderEnabled;
  bool get weeklyReflectionEnabled => _weeklyReflectionEnabled;
  bool get streakNudgesEnabled => _streakNudgesEnabled;
  Map<String, dynamic> get flowMode => _flowMode;

  AppState() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 2]; // 2 = system/auto
    _fontSizeMultiplier = prefs.getDouble('fontSizeMultiplier') ?? 1.0;
    _dailyReminderEnabled = prefs.getBool('dailyReminderEnabled') ?? true;
    _weeklyReflectionEnabled = prefs.getBool('weeklyReflectionEnabled') ?? true;
    _streakNudgesEnabled = prefs.getBool('streakNudgesEnabled') ?? true;
    _onboardingDone = prefs.getBool('onboardingDone') ?? false;
    debugPrint('[Settings] Loaded from storage: '
        'dailyReminderEnabled=${_dailyReminderEnabled}, '
        'weeklyReflectionEnabled=${_weeklyReflectionEnabled}, '
        'streakNudgesEnabled=${_streakNudgesEnabled}');
    notifyListeners();
  }

  void setUser(User? user) {
    _currentUser = user;
    _isAuthenticated = user != null;
    if (user != null) {
      _showTabBar = true;
    }
    notifyListeners();
  }

  void setAnonymous(bool value) {
    _isAnonymous = value;
    notifyListeners();
  }

  void setPendingDua(String text, String language) {
    _pendingDuaText = text;
    _pendingDuaLanguage = language;
    notifyListeners();
  }

  void clearPendingDua() {
    _pendingDuaText = null;
    _pendingDuaLanguage = null;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    _isAnonymous = false;
    _pendingDuaText = null;
    _pendingDuaLanguage = null;
    _currentTab = 'home';
    _showTabBar = false;
    notifyListeners();
  }

  void setCurrentTab(String tab) {
    _currentTab = tab;
    notifyListeners();
  }

  void setShowTabBar(bool show) {
    _showTabBar = show;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setFontSizeMultiplier(double multiplier) async {
    _fontSizeMultiplier = multiplier;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSizeMultiplier', multiplier);
    notifyListeners();
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    _dailyReminderEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyReminderEnabled', enabled);
    debugPrint('Daily Reminder toggled: ${enabled}');
    notifyListeners();
  }

  Future<void> setWeeklyReflectionEnabled(bool enabled) async {
    _weeklyReflectionEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weeklyReflectionEnabled', enabled);
    debugPrint('Weekly Reflection toggled: ${enabled}');
    notifyListeners();
  }

  Future<void> setStreakNudgesEnabled(bool enabled) async {
    _streakNudgesEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('streakNudgesEnabled', enabled);
    debugPrint('Duʿā Streak Nudges toggled: ${enabled}');
    notifyListeners();
  }

  void showProcessingOverlay(String text) {
    _showProcessing = true;
    _processingText = text;
    notifyListeners();
  }

  void hideProcessingOverlay() {
    _showProcessing = false;
    _processingText = '';
    notifyListeners();
  }

  void setFlowMode(Map<String, dynamic> mode) {
    _flowMode = mode;
    notifyListeners();
  }

  void updateFlowSpeed(double speed) {
    _flowMode['speed'] = speed;
    notifyListeners();
  }

  void updateFlowTheme(String theme) {
    _flowMode['theme'] = theme;
    notifyListeners();
  }

  void toggleFlowPlayPause() {
    _flowMode['isPlaying'] = !_flowMode['isPlaying'];
    notifyListeners();
  }

  void completeSignIn() {
    _isAuthenticated = true;
    _showTabBar = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingDone = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', true);
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    _onboardingDone = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', false);
    notifyListeners();
  }
}
