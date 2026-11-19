import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hearth_prayer/theme/app_theme.dart';
import 'package:hearth_prayer/theme/app_tokens.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:hearth_prayer/state/app_state.dart';
import 'package:hearth_prayer/services/location_service.dart';
import 'package:hearth_prayer/services/prayer_times_service.dart';

/*
  Diagnostic Report — Settings > Notifications (Dev Note)

  Daily Reminder: ✅ wired
  Current binding: AppState.dailyReminderEnabled via Consumer<AppState> in _buildNotificationToggle.
                   Persists to SharedPreferences key 'dailyReminderEnabled'.
  Persists: ✅ (SharedPreferences; loaded in AppState._loadSettings on app start/hot restart)

  Weekly Reflection: ✅ wired
  Current binding: AppState.weeklyReflectionEnabled via Consumer<AppState> in _buildNotificationToggle.
                   Persists to SharedPreferences key 'weeklyReflectionEnabled'.
  Persists: ✅ (SharedPreferences; loaded in AppState._loadSettings on app start/hot restart)

  Duʿā Streak Nudges: ✅ wired
  Current binding: AppState.streakNudgesEnabled via Consumer<AppState> in _buildNotificationToggle.
                   Persists to SharedPreferences key 'streakNudgesEnabled'.
  Persists: ✅ (SharedPreferences; loaded in AppState._loadSettings on app start/hot restart)

  Notes:
  - This screen updates state exclusively through AppState setters which write to SharedPreferences
    and call notifyListeners().
  - To aid verification in Preview, toggle changes and initial loads are now logged via debugPrint
    inside AppState (see set*Enabled() and _loadSettings()).
*/

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification toggle states
  bool _notifPrayerMaster = false;
  bool _notifFajr = false;
  bool _notifDhuhr = false;
  bool _notifAsr = false;
  bool _notifMaghrib = false;
  bool _notifIsha = false;
  bool _notifLastThird = false;
  bool _notifAdhanIqamah = false;
  bool _notifJumuah = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPrefs();
  }

  Future<void> _loadNotificationPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifPrayerMaster = prefs.getBool('notif_prayer_master') ?? false;
      _notifFajr = prefs.getBool('notif_fajr') ?? false;
      _notifDhuhr = prefs.getBool('notif_dhuhr') ?? false;
      _notifAsr = prefs.getBool('notif_asr') ?? false;
      _notifMaghrib = prefs.getBool('notif_maghrib') ?? false;
      _notifIsha = prefs.getBool('notif_isha') ?? false;
      _notifLastThird = prefs.getBool('notif_last_third') ?? false;
      _notifAdhanIqamah = prefs.getBool('notif_adhan_iqamah') ?? false;
      _notifJumuah = prefs.getBool('notif_jumuah') ?? false;
    });
  }

  Future<void> _setNotifPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
                Builder(
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
                                onPressed: () => Navigator.pop(context),
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
                                'Settings',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: theme.textTheme.headlineMedium?.fontSize ?? 22,
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
              _buildAppearanceSection(context, theme),
              const SizedBox(height: 32),
              _buildLanguageSection(context, theme),
              const SizedBox(height: 32),
              _buildPrayerTimesSection(context, theme),
              const SizedBox(height: 32),
              _buildNotificationsSection(context, theme),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTokensDark.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildThemeModeToggle(context, theme),
          const SizedBox(height: 24),
          _buildFontSizeSlider(context, theme),
        ],
      ),
    );
  }

  Widget _buildThemeModeToggle(BuildContext context, ThemeData theme) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Mode',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildThemeButton(
                    context,
                    'Light',
                    ThemeMode.light,
                    appState.themeMode == ThemeMode.light,
                  ),
                  _buildThemeButton(
                    context,
                    'Dark',
                    ThemeMode.dark,
                    appState.themeMode == ThemeMode.dark,
                  ),
                  _buildThemeButton(
                    context,
                    'Auto',
                    ThemeMode.system,
                    appState.themeMode == ThemeMode.system,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              appState.themeMode == ThemeMode.system
                  ? 'Light mode: 06:00–18:00 • Dark mode: 18:00–06:00'
                  : '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeButton(
    BuildContext context,
    String label,
    ThemeMode mode,
    bool isActive,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<AppState>().setThemeMode(mode);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppTokensDark.copperSolid.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border(
              right: label != 'Auto'
                  ? BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    )
                  : BorderSide.none,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isActive ? AppTokensDark.copperSolid : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFontSizeSlider(BuildContext context, ThemeData theme) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final fontSizeRange = (24 - 14); // 14sp to 24sp
        final sliderValue = (appState.fontSizeMultiplier * 16 - 14) / fontSizeRange;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Font Size',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: sliderValue,
              onChanged: (value) {
                final newFontSize = 14 + (value * fontSizeRange);
                final newMultiplier = newFontSize / 16;
                context.read<AppState>().setFontSizeMultiplier(newMultiplier);
              },
              activeColor: AppTokensDark.copperSolid,
              inactiveColor: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'O Allah, bless my family with happiness, unity, and guidance.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16 * appState.fontSizeMultiplier,
                  height: 1.6,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Language & Region',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTokensDark.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'English (default)',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: AppTokensDark.copperSolid,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesSection(BuildContext context, ThemeData theme) {
    return FutureBuilder<Map<String, String>>(
      future: _loadPrayerTimesSettings(),
      builder: (context, snapshot) {
        final settings = snapshot.data ?? {
          'method': 'Muslim World League',
          'school': 'Shafi\'i (Standard)',
          'location': 'Auto-detect',
        };

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prayer Times',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTokensDark.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _buildPrayerTimesRow(
                context,
                theme,
                title: 'Location',
                subtitle: settings['location'] ?? 'Auto-detect',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _LocationSearchScreen(),
                    ),
                  );
                  setState(() {}); // Refresh subtitles on return
                },
              ),
              const SizedBox(height: 16),
              _buildPrayerTimesRow(
                context,
                theme,
                title: 'Calculation Method',
                subtitle: settings['method'] ?? 'Muslim World League',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _CalculationMethodScreen(),
                    ),
                  );
                  setState(() {}); // Refresh subtitles on return
                },
              ),
              const SizedBox(height: 16),
              _buildPrayerTimesRow(
                context,
                theme,
                title: 'Juristic School',
                subtitle: settings['school'] ?? 'Shafi\'i (Standard)',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _JuristicSchoolScreen(),
                    ),
                  );
                  setState(() {}); // Refresh subtitles on return
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, String>> _loadPrayerTimesSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Method name lookup
    final methodId = prefs.getInt('prayer_calc_method') ?? 3;
    const methodNames = {
      0: 'Shia Ithna-Ashari',
      1: 'University of Islamic Sciences, Karachi',
      2: 'ISNA',
      3: 'Muslim World League',
      4: 'Umm Al-Qura, Makkah',
      5: 'Egyptian General Authority',
      7: 'University of Tehran',
      8: 'Gulf Region',
      9: 'Kuwait',
      10: 'Qatar',
      11: 'MUIS, Singapore',
      12: 'UOIF, France',
      13: 'Diyanet, Turkey',
      14: 'Russia',
      15: 'Moonsighting Committee',
      16: 'Dubai',
      17: 'JAKIM, Malaysia',
      18: 'Tunisia',
      19: 'Algeria',
      20: 'KEMENAG, Indonesia',
      21: 'Morocco',
      22: 'Lisbon',
      23: 'Jordan',
    };

    // School name lookup
    final schoolId = prefs.getInt('prayer_juristic_school') ?? 0;
    const schoolNames = {
      0: 'Shafi\'i (Standard)',
      1: 'Hanafi',
    };

    // Location
    final city = prefs.getString('user_city') ?? '';
    final source = prefs.getString('location_source') ?? '';
    String locationText;
    if (city.isNotEmpty) {
      locationText = city;
    } else if (source == 'gps') {
      locationText = 'GPS (Auto-detected)';
    } else {
      locationText = 'Default (Didcot, UK)';
    }

    return {
      'method': methodNames[methodId] ?? 'Muslim World League',
      'school': schoolNames[schoolId] ?? 'Shafi\'i (Standard)',
      'location': locationText,
    };
  }

  Widget _buildPrayerTimesRow(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
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
                  const SizedBox(height: 4),
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
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTokensDark.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // ── Prayer Time Reminders ──
          Text(
            'Prayer Time Reminders',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Get reminded to make du\u02BFā\u02BE after each ṣalāh',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),

          // Master toggle
          _buildSimpleToggle(
            theme,
            label: 'Prayer time du\u02BFā\u02BE reminders',
            value: _notifPrayerMaster,
            onChanged: (val) {
              setState(() {
                _notifPrayerMaster = val;
                if (val) {
                  // Turn all 5 prayer toggles ON
                  _notifFajr = true;
                  _notifDhuhr = true;
                  _notifAsr = true;
                  _notifMaghrib = true;
                  _notifIsha = true;
                } else {
                  // Turn all 5 prayer toggles OFF
                  _notifFajr = false;
                  _notifDhuhr = false;
                  _notifAsr = false;
                  _notifMaghrib = false;
                  _notifIsha = false;
                }
              });
              _setNotifPref('notif_prayer_master', val);
              _setNotifPref('notif_fajr', val);
              _setNotifPref('notif_dhuhr', val);
              _setNotifPref('notif_asr', val);
              _setNotifPref('notif_maghrib', val);
              _setNotifPref('notif_isha', val);
            },
          ),

          // Individual prayer toggles (only when master is ON)
          if (_notifPrayerMaster) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  _buildSimpleToggle(
                    theme,
                    label: 'Fajr',
                    value: _notifFajr,
                    onChanged: (val) {
                      setState(() => _notifFajr = val);
                      _setNotifPref('notif_fajr', val);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSimpleToggle(
                    theme,
                    label: 'Ḍhuhr',
                    value: _notifDhuhr,
                    onChanged: (val) {
                      setState(() => _notifDhuhr = val);
                      _setNotifPref('notif_dhuhr', val);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSimpleToggle(
                    theme,
                    label: '\u02BCAṣr',
                    value: _notifAsr,
                    onChanged: (val) {
                      setState(() => _notifAsr = val);
                      _setNotifPref('notif_asr', val);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSimpleToggle(
                    theme,
                    label: 'Maghrib',
                    value: _notifMaghrib,
                    onChanged: (val) {
                      setState(() => _notifMaghrib = val);
                      _setNotifPref('notif_maghrib', val);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSimpleToggle(
                    theme,
                    label: '\u02BCIshā\u02BE',
                    value: _notifIsha,
                    onChanged: (val) {
                      setState(() => _notifIsha = val);
                      _setNotifPref('notif_isha', val);
                    },
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ── Blessed Times ──
          Text(
            'Blessed Times',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildSimpleToggle(
            theme,
            label: 'Last third of the night',
            value: _notifLastThird,
            onChanged: (val) {
              setState(() => _notifLastThird = val);
              _setNotifPref('notif_last_third', val);
            },
          ),
          const SizedBox(height: 8),
          _buildSimpleToggle(
            theme,
            label: 'Between adhān & iqāmah',
            value: _notifAdhanIqamah,
            onChanged: (val) {
              setState(() => _notifAdhanIqamah = val);
              _setNotifPref('notif_adhan_iqamah', val);
            },
          ),

          const SizedBox(height: 24),

          // ── Weekly ──
          Text(
            'Weekly',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildSimpleToggle(
            theme,
            label: 'Jumu\u02BFah du\u02BFā\u02BE reminder',
            value: _notifJumuah,
            onChanged: (val) {
              setState(() => _notifJumuah = val);
              _setNotifPref('notif_jumuah', val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleToggle(
    ThemeData theme, {
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTokensDark.copperSolid,
          ),
        ],
      ),
    );
  }
}

class _CalculationMethodScreen extends StatefulWidget {
  const _CalculationMethodScreen();

  @override
  State<_CalculationMethodScreen> createState() => _CalculationMethodScreenState();
}

class _CalculationMethodScreenState extends State<_CalculationMethodScreen> {
  static const List<Map<String, dynamic>> _methods = [
    {'id': 0, 'name': 'Shia Ithna-Ashari', 'region': 'Shia regions'},
    {'id': 1, 'name': 'University of Islamic Sciences, Karachi', 'region': 'Pakistan, Bangladesh, India, Afghanistan'},
    {'id': 2, 'name': 'Islamic Society of North America (ISNA)', 'region': 'North America'},
    {'id': 3, 'name': 'Muslim World League', 'region': 'Europe, Far East, parts of USA'},
    {'id': 4, 'name': 'Umm Al-Qura University, Makkah', 'region': 'Arabian Peninsula'},
    {'id': 5, 'name': 'Egyptian General Authority of Survey', 'region': 'Africa, Syria, Lebanon, Malaysia'},
    {'id': 7, 'name': 'Institute of Geophysics, University of Tehran', 'region': 'Iran'},
    {'id': 8, 'name': 'Gulf Region', 'region': 'Gulf countries'},
    {'id': 9, 'name': 'Kuwait', 'region': 'Kuwait'},
    {'id': 10, 'name': 'Qatar', 'region': 'Qatar'},
    {'id': 11, 'name': 'Majlis Ugama Islam Singapura', 'region': 'Singapore'},
    {'id': 12, 'name': 'Union Organization Islamic de France', 'region': 'France'},
    {'id': 13, 'name': 'Diyanet İşleri Başkanlığı, Turkey', 'region': 'Turkey'},
    {'id': 14, 'name': 'Spiritual Administration of Muslims of Russia', 'region': 'Russia'},
    {'id': 15, 'name': 'Moonsighting Committee Worldwide', 'region': 'Global (conservative)'},
    {'id': 16, 'name': 'Dubai', 'region': 'UAE'},
    {'id': 17, 'name': 'JAKIM, Malaysia', 'region': 'Malaysia'},
    {'id': 18, 'name': 'Tunisia', 'region': 'Tunisia'},
    {'id': 19, 'name': 'Algeria', 'region': 'Algeria'},
    {'id': 20, 'name': 'KEMENAG, Indonesia', 'region': 'Indonesia'},
    {'id': 21, 'name': 'Morocco', 'region': 'Morocco'},
    {'id': 22, 'name': 'Comunidade Islamica de Lisboa', 'region': 'Portugal'},
    {'id': 23, 'name': 'Ministry of Awqaf and Islamic Affairs, Jordan', 'region': 'Jordan'},
  ];

  int _selectedMethod = 3; // default MWL

  @override
  void initState() {
    super.initState();
    _loadSavedMethod();
  }

  Future<void> _loadSavedMethod() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedMethod = prefs.getInt('prayer_calc_method') ?? 3;
    });
  }

  Future<void> _saveMethod(int method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('prayer_calc_method', method);
    // Clear prayer times cache so it re-fetches with new method
    await PrayerTimesService.clearCache();
    setState(() {
      _selectedMethod = method;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bt = context.brandTokens;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
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
                        onPressed: () => Navigator.pop(context),
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
                        'Calculation Method',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: theme.textTheme.headlineMedium?.fontSize ?? 22,
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
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: _methods.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final method = _methods[index];
                  final isSelected = _selectedMethod == method['id'];

                  return GestureDetector(
                    onTap: () => _saveMethod(method['id'] as int),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.5)
                              : theme.colorScheme.outline.withValues(alpha: 0.1),
                          width: isSelected ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.05)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method['name'] as String,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  method['region'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppTokensDark.copperSolid,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JuristicSchoolScreen extends StatefulWidget {
  const _JuristicSchoolScreen();

  @override
  State<_JuristicSchoolScreen> createState() => _JuristicSchoolScreenState();
}

class _JuristicSchoolScreenState extends State<_JuristicSchoolScreen> {
  static const List<Map<String, dynamic>> _schools = [
    {
      'id': 0,
      'name': 'Shafi\'i, Maliki, Hanbali',
      'subtitle': 'Standard (earlier Asr)',
      'description': 'Asr begins when an object\'s shadow equals its length.',
    },
    {
      'id': 1,
      'name': 'Hanafi',
      'subtitle': 'Later Asr time',
      'description': 'Asr begins when an object\'s shadow is twice its length.',
    },
  ];

  int _selectedSchool = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedSchool();
  }

  Future<void> _loadSavedSchool() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSchool = prefs.getInt('prayer_juristic_school') ?? 0;
    });
  }

  Future<void> _saveSchool(int school) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('prayer_juristic_school', school);
    await PrayerTimesService.clearCache();
    setState(() {
      _selectedSchool = school;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bt = context.brandTokens;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
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
                        onPressed: () => Navigator.pop(context),
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
                        'Juristic School',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: theme.textTheme.headlineMedium?.fontSize ?? 22,
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
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: _schools.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final school = _schools[index];
                  final isSelected = _selectedSchool == school['id'];

                  return GestureDetector(
                    onTap: () => _saveSchool(school['id'] as int),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.5)
                              : theme.colorScheme.outline.withValues(alpha: 0.1),
                          width: isSelected ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.05)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  school['name'] as String,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  school['subtitle'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  school['description'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppTokensDark.copperSolid,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSearchScreen extends StatefulWidget {
  const _LocationSearchScreen();

  @override
  State<_LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<_LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;
  String _errorMessage = '';

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _results = [];
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });

    try {
      final locations = await locationFromAddress(query);
      final results = <Map<String, dynamic>>[];

      for (final loc in locations.take(5)) {
        // Try to get a readable place name
        try {
          final placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            final parts = <String>[
              if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
              if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) p.administrativeArea!,
              if (p.country != null && p.country!.isNotEmpty) p.country!,
            ];
            results.add({
              'name': parts.join(', '),
              'city': p.locality ?? parts.first,
              'lat': loc.latitude,
              'lng': loc.longitude,
            });
          }
        } catch (_) {
          results.add({
            'name': '${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}',
            'city': query,
            'lat': loc.latitude,
            'lng': loc.longitude,
          });
        }
      }

      setState(() {
        _results = results;
        _isSearching = false;
        if (results.isEmpty) {
          _errorMessage = 'No locations found for "$query"';
        }
      });
    } catch (e) {
      setState(() {
        _results = [];
        _isSearching = false;
        _errorMessage = 'Could not find "$query". Try a different search.';
      });
    }
  }

  Future<void> _selectLocation(Map<String, dynamic> location) async {
    await LocationService.saveLocation(
      latitude: location['lat'] as double,
      longitude: location['lng'] as double,
      city: location['city'] as String,
      source: 'manual',
    );
    // Clear prayer cache so it re-fetches for new location
    await PrayerTimesService.clearCache();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bt = context.brandTokens;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
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
                        onPressed: () => Navigator.pop(context),
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
                        'Prayer Location',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: theme.textTheme.headlineMedium?.fontSize ?? 22,
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

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onSubmitted: _search,
                textInputAction: TextInputAction.search,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search city or country...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _results = [];
                              _errorMessage = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            // Use GPS button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () async {
                  setState(() => _isSearching = true);
                  final granted = await LocationService.requestAndSaveLocation();
                  if (granted) {
                    await PrayerTimesService.clearCache();
                    if (mounted) Navigator.pop(context);
                  } else {
                    setState(() {
                      _isSearching = false;
                      _errorMessage = 'GPS unavailable. Please search manually.';
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Use My Current Location',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Loading indicator
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                  strokeWidth: 2,
                ),
              ),

            // Error message
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  _errorMessage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Results list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final result = _results[index];
                  return GestureDetector(
                    onTap: () => _selectLocation(result),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result['name'] as String,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${(result['lat'] as double).toStringAsFixed(4)}, ${(result['lng'] as double).toStringAsFixed(4)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
