import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:hearth_prayer/theme/brand_theme.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:hearth_prayer/services/user_service.dart';
import 'package:hearth_prayer/services/journal_service.dart';
import 'package:hearth_prayer/services/dua_service.dart';
import 'package:hearth_prayer/services/prayer_times_service.dart';
import 'package:hearth_prayer/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hearth_prayer/screens/me/mission_munajat_screen.dart';
import 'package:provider/provider.dart';
import 'package:hearth_prayer/state/app_state.dart';

const poppins = 'Poppins';
final h26w300 = TextStyle(fontFamily: poppins, fontSize: 26, fontWeight: FontWeight.w300, height: 1.3, letterSpacing: 0.01);
final h20w400 = TextStyle(fontFamily: poppins, fontSize: 20, fontWeight: FontWeight.w400, height: 1.3);
final body16w400 = TextStyle(fontFamily: poppins, fontSize: 16, fontWeight: FontWeight.w400);
final body14w400 = TextStyle(fontFamily: poppins, fontSize: 14, fontWeight: FontWeight.w400);
final meta13w300 = TextStyle(fontFamily: poppins, fontSize: 13, fontWeight: FontWeight.w300);
final meta12w400 = TextStyle(fontFamily: poppins, fontSize: 12, fontWeight: FontWeight.w400);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum SummaryFilter { today, week, all }

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String _userName = '';
  // Weekday selection (1=Mon..7=Sun)
  late int _selectedDay;
  // Summary filter state
  SummaryFilter _selectedSummaryFilter = SummaryFilter.today;

  // Screen entry animation
  late final AnimationController _entryController;
  late final Animation<double> _entryPhase1; // header + next prayer
  late final Animation<double> _entryPhase2; // weekday strip
  late final Animation<double> _entryPhase3; // hero card
  late final Animation<double> _entryPhase4; // filter bar
  late final Animation<double> _entryPhase5; // metric cards

  @override
  void initState() {
    super.initState();
    _userName = UserService.currentUser?.name ?? '';
    _selectedDay = DateTime.now().weekday; // default to today

    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
    _entryPhase1 = CurvedAnimation(parent: _entryController, curve: const Interval(0.00, 0.50, curve: Curves.easeOutCubic));
    _entryPhase2 = CurvedAnimation(parent: _entryController, curve: const Interval(0.10, 0.60, curve: Curves.easeOutCubic));
    _entryPhase3 = CurvedAnimation(parent: _entryController, curve: const Interval(0.20, 0.70, curve: Curves.easeOutCubic));
    _entryPhase4 = CurvedAnimation(parent: _entryController, curve: const Interval(0.30, 0.85, curve: Curves.easeOutCubic));
    _entryPhase5 = CurvedAnimation(parent: _entryController, curve: const Interval(0.40, 1.00, curve: Curves.easeOutCubic));
    // Kick off entry animation on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = Provider.of<AppState>(context, listen: false);
    final updatedName = appState.currentUser?.name ?? '';
    if (updatedName != _userName) {
      setState(() {
        _userName = updatedName;
      });
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brandTokens = context.brandTokens;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 24,
          right: 24,
          bottom: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Zone 1: Header + Hijri Date
            _EntryFadeSlide(
              animation: _entryPhase1,
              child: _HeaderWithDate(userName: _userName, brandTokens: brandTokens, colorScheme: colorScheme),
            ),
            const SizedBox(height: 24),

            // Zone 1c: Weekday Strip
            _EntryFadeSlide(
              animation: _entryPhase2,
              child: _WeekdayStrip(
                colorScheme: colorScheme,
                brandTokens: brandTokens,
                selectedDay: _selectedDay,
                onSelected: (day) => setState(() => _selectedDay = day),
              ),
            ),
            const SizedBox(height: 20),

            // Zone 1b: Next Prayer Card (replaces simple text row)
            _EntryFadeSlide(
              animation: _entryPhase1,
              child: _NextPrayerCard(colorScheme: colorScheme, brandTokens: brandTokens),
            ),
            const SizedBox(height: 24),

            // Zone 2: Hero Input Card
            _EntryFadeSlide(
              animation: _entryPhase3,
              child: _HeroInputCard(brandTokens: brandTokens, colorScheme: colorScheme),
            ),
            const SizedBox(height: 32),

            // Zone 3: Today/Week/All Filter Bar
            _EntryFadeSlide(
              animation: _entryPhase4,
              child: _SummaryFilterBar(
                colorScheme: colorScheme,
                brandTokens: brandTokens,
                selected: _selectedSummaryFilter,
                onChanged: (f) => setState(() => _selectedSummaryFilter = f),
              ),
            ),
            const SizedBox(height: 20),

            // Zone 4: Metric Cards (Duʿās + Journal)
            _EntryFadeSlide(
              animation: _entryPhase5,
              child: _MetricsRow(
                colorScheme: colorScheme,
                brandTokens: brandTokens,
                filter: _selectedSummaryFilter,
              ),
            ),
            const SizedBox(height: 24),

            // Zone 5: Mission Munajat Card
            _EntryFadeSlide(
              animation: _entryPhase5,
              child: _MissionMunajatCard(colorScheme: colorScheme, brandTokens: brandTokens),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderWithDate extends StatelessWidget {
  final String userName;
  final BrandTokens brandTokens;
  final ColorScheme colorScheme;

  const _HeaderWithDate({
    required this.userName,
    required this.brandTokens,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => brandTokens.copperGradient.createShader(bounds),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'As-Salāmu ʿAlaykum',
              style: h26w300.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            if (userName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  userName,
                  style: h26w300.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroInputCard extends StatelessWidget {
  final BrandTokens brandTokens;
  final ColorScheme colorScheme;

  const _HeroInputCard({
    required this.brandTokens,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: brandTokens.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFFD9A0), Color(0xFFD4A574), Color(0xFFB87333)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: Text(
              'Say what you can\'t say out loud...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                color: Colors.white,
                letterSpacing: 0.3,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/createDua', arguments: {
                      'initialMode': 'type',
                      'autoStartRecording': false,
                      'showBackButton': true,
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.primary, width: 1.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      children: [
                        Icon(
                          Icons.keyboard,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'TYPE',
                          style: meta12w400.copyWith(color: colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/createDua', arguments: {
                      'initialMode': 'speak',
                      'autoStartRecording': true,
                      'showBackButton': true,
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.primary, width: 1.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      children: [
                        Icon(
                          Icons.mic_none,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'SPEAK',
                          style: meta12w400.copyWith(color: colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecondaryActionsRail extends StatelessWidget {
  final ColorScheme colorScheme;
  final BrandTokens brandTokens;

  const _SecondaryActionsRail({
    required this.colorScheme,
    required this.brandTokens,
  });

  @override
  Widget build(BuildContext context) {
    final chips = [
      'Sunnah Acts',
      'Guidance',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips
            .map((label) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorScheme.primary, width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        label,
                        style: body14w400.copyWith(color: colorScheme.primary),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _GratitudeJournalCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final BrandTokens brandTokens;

  const _GratitudeJournalCard({
    required this.colorScheme,
    required this.brandTokens,
  });

  String _getGratitudeText() {
    return 'Your Last Reflection: Tap to view previous entries.';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/journalHistory');
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: brandTokens.border, width: 1),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => brandTokens.copperGradient.createShader(bounds),
              child: Text(
                'Gratitude Journal',
                style: h20w400.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getGratitudeText(),
              style: body14w400.copyWith(
                color: colorScheme.onSurface,
                height: 1.6,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'View your journal →',
                style: meta13w300.copyWith(color: colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable entry transition wrapper
class _EntryFadeSlide extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  const _EntryFadeSlide({required this.child, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * 12),
            child: child,
          ),
        );
      },
    );
  }
}

class _NextPrayerCard extends StatefulWidget {
  final ColorScheme colorScheme;
  final BrandTokens brandTokens;
  const _NextPrayerCard({required this.colorScheme, required this.brandTokens});

  @override
  State<_NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<_NextPrayerCard> with SingleTickerProviderStateMixin {
  late AnimationController _ringController;
  double _targetProgress = 0.0; // 0..1
  DateTime _lastTick = DateTime.now();

  bool _loading = true;
  bool _hasError = false;
  bool _locationAsked = true; // default true = hide the prompt until we check

  String _getPrayerTimeMessage() {
    if (_loading) return 'Loading prayer times...';
    if (_hasError) return 'Unable to load prayer times';

    final info = PrayerTimesService.getNextPrayerInfo();
    if (info == null) return 'Loading prayer times...';

    final mins = info.minutesUntil;
    if (mins <= 0) return '${info.name} now';

    final hours = mins ~/ 60;
    final remainingMins = mins % 60;

    String timeLeft;
    if (hours > 0 && remainingMins > 0) {
      timeLeft = '${info.name} in ${hours}h ${remainingMins}m';
    } else if (hours > 0) {
      timeLeft = '${info.name} in ${hours}h';
    } else {
      timeLeft = '${info.name} in ${remainingMins}m';
    }

    return timeLeft;
  }

  String _getFormattedPrayerTime() {
    final info = PrayerTimesService.getNextPrayerInfo();
    if (info == null) return '';

    final hour = info.at.hour;
    final minute = info.at.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');

    return '$displayHour:$displayMinute $period';
  }

  double _computeProgress(DateTime now) {
    if (_loading || _hasError) return _ringController.value;

    final info = PrayerTimesService.getNextPrayerInfo();
    if (info == null) return _ringController.value;

    return info.progress.clamp(0.0, 1.0);
  }

  Future<void> _loadTimes() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final loc = await LocationService.getLocation();
      final prefs = await SharedPreferences.getInstance();
      final method = prefs.getInt('prayer_calc_method') ?? 3;
      final school = prefs.getInt('prayer_juristic_school') ?? 0;
      final res = await PrayerTimesService.ensureToday(
        latitude: loc.lat,
        longitude: loc.lng,
        method: method,
        school: school,
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _hasError = (res == null);
      });

      _tick(); // update ring immediately after load
    } catch (e) {
      if (!mounted) return;
      debugPrint('NextPrayerCard load failed: $e');
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _requestLocationIfNeeded() async {
    final alreadyAsked = await LocationService.hasAskedPermission();
    if (alreadyAsked) return;

    // Small delay so the home screen renders first before the popup appears
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final granted = await LocationService.requestAndSaveLocation();
    if (granted && mounted) {
      // Reload prayer times with the new GPS coordinates
      await _loadTimes();
    }
  }

  void _tick() {
    final now = DateTime.now();
    final next = _computeProgress(now);
    setState(() {
      _targetProgress = next;
    });

    if (!_ringController.isAnimating) {
      _ringController.animateTo(
        _targetProgress,
        duration: Duration(milliseconds: (_lastTick == DateTime(0) ? 600 : 300)),
        curve: Curves.easeOutCubic,
      );
    } else {
      _ringController.animateTo(
        _targetProgress,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
    _lastTick = now;
  }

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(vsync: this, lowerBound: 0.0, upperBound: 1.0, value: 0.0);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await _loadTimes();

      if (!mounted) return;
      _ringController.animateTo(
        _computeProgress(DateTime.now()),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );

      final alreadyAsked = await LocationService.hasAskedPermission();
      if (mounted) {
        setState(() => _locationAsked = alreadyAsked);
      }
    });

    // Schedule minute-based ticks
    _scheduleMinuteTicker();
  }

  void _scheduleMinuteTicker() {
    // Align to next minute boundary to avoid drift
    final now = DateTime.now();
    final msToNextMinute = (60 - now.second) * 1000 - now.millisecond;
    Future.delayed(Duration(milliseconds: msToNextMinute.clamp(0, 60000))).then((_) {
      if (!mounted) return;
      _tick();
      // Then every minute
      _minuteLoop();
    });
  }

  void _minuteLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(minutes: 1));
      if (!mounted) break;
      _tick();

      // If we are still loading/failed, try again occasionally (lightweight)
      if (_hasError) {
        await _loadTimes();
      }
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme;
    final brandTokens = widget.brandTokens;
    return Semantics(
      label: 'Next Prayer. View full prayer times.',
      button: true,
      onTap: () => _navigateToPrayerTimes(context),
      child: _TapScale(
        onTap: () => _navigateToPrayerTimes(context),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _navigateToPrayerTimes(context),
            child: Container(
              constraints: const BoxConstraints(minHeight: 136),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: brandTokens.border, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: AnimatedBuilder(
                          animation: _ringController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _RingPainter(
                                progress: _ringController.value,
                                color: colorScheme.primary,
                                track: colorScheme.onSurface.withValues(alpha: 0.12),
                                strokeWidth: 5,
                              ),
                              child: Center(
                                child: Icon(Icons.schedule, color: colorScheme.primary, size: 26),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Next Prayer', style: meta12w400.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7))),
                            const SizedBox(height: 6),
                            Text(
                              _getPrayerTimeMessage(),
                              style: h20w400.copyWith(color: colorScheme.onSurface),
                            ),
                            const SizedBox(height: 4),
                            if (!_loading && !_hasError && PrayerTimesService.getNextPrayerInfo() != null)
                              Text(
                                _getFormattedPrayerTime(),
                                style: meta13w300.copyWith(color: colorScheme.primary),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap to view full prayer times →',
                              style: meta13w300.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!_locationAsked)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: GestureDetector(
                        onTap: () async {
                          final granted = await LocationService.requestAndSaveLocation();
                          if (mounted) {
                            setState(() => _locationAsked = true);
                            if (granted) await _loadTimes();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Tap for accurate prayer times',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.primary,
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
        ),
      ),
    );
  }
}

extension on _NextPrayerCardState {
  void _navigateToPrayerTimes(BuildContext context) {
    try {
      Navigator.of(context).pushNamed('/prayerTimes');
    } catch (e) {
      debugPrint('NextPrayerCard navigation failed: $e');
    }
  }
}

class _RingPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  final Color track;
  final double strokeWidth;
  _RingPainter({required this.progress, required this.color, required this.track, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - strokeWidth / 2;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final startAngle = -90 * 3.1415926535 / 180;
    final sweepAngle = 2 * 3.1415926535 * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.track != track || oldDelegate.strokeWidth != strokeWidth;
  }
}

class _WeekdayStrip extends StatefulWidget {
  final ColorScheme colorScheme;
  final BrandTokens brandTokens;
  final int selectedDay; // 1..7 (Mon..Sun)
  final ValueChanged<int> onSelected;
  const _WeekdayStrip({required this.colorScheme, required this.brandTokens, required this.selectedDay, required this.onSelected});

  @override
  State<_WeekdayStrip> createState() => _WeekdayStripState();
}

class _WeekdayStripState extends State<_WeekdayStrip> {
  final List<String> _labels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  bool _initialShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _initialShown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    return AnimatedOpacity(
      opacity: _initialShown ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedSlide(
        offset: _initialShown ? Offset.zero : const Offset(0, 0.08),
        duration: const Duration(milliseconds: 200),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (index) {
                    final dayIndex = index + 1; // 1..7
                    final selected = widget.selectedDay == dayIndex;
                    return Padding(
                      padding: EdgeInsets.only(right: index == 6 ? 0 : 12),
                      child: _TapScale(
                        onTap: () => widget.onSelected(dayIndex),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOut,
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: selected ? cs.primary : cs.surface.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: selected ? cs.primary : cs.onSurface.withValues(alpha: 0.15), width: 1),
                          ),
                          alignment: Alignment.center,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 150),
                            style: body14w400.copyWith(color: selected ? Colors.white : cs.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
                            child: Text(_labels[index]),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryFilterBar extends StatelessWidget {
  final ColorScheme colorScheme;
  final BrandTokens brandTokens;
  final SummaryFilter selected;
  final ValueChanged<SummaryFilter> onChanged;
  const _SummaryFilterBar({required this.colorScheme, required this.brandTokens, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget buildPill(String label, SummaryFilter value) {
      final isSelected = selected == value;
      return _TapScale(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isSelected ? colorScheme.primary : brandTokens.border, width: 1),
          ),
          child: Text(
            label,
            style: body14w400.copyWith(color: isSelected ? Colors.white : colorScheme.onSurface),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildPill('Today', SummaryFilter.today),
        const SizedBox(width: 12),
        buildPill('Week', SummaryFilter.week),
        const SizedBox(width: 12),
        buildPill('All', SummaryFilter.all),
      ],
    );
  }
}

class _MetricsRow extends StatefulWidget {
  final ColorScheme colorScheme;
  final BrandTokens brandTokens;
  final SummaryFilter filter;
  const _MetricsRow({required this.colorScheme, required this.brandTokens, required this.filter});

  @override
  State<_MetricsRow> createState() => _MetricsRowState();
}

class _MetricsRowState extends State<_MetricsRow> {
  int _duaCount = 0;
  int _journalCount = 0;

  @override
  void didUpdateWidget(covariant _MetricsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      setState(() {
        // trigger animation via TweenAnimationBuilder by changing values
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final bt = widget.brandTokens;

    int dua = _computeDuaCount(widget.filter);
    int journal = _computeJournalCount(widget.filter);

    String contextLabel;
    switch (widget.filter) {
      case SummaryFilter.today: contextLabel = 'Today'; break;
      case SummaryFilter.week:  contextLabel = 'This Week'; break;
      case SummaryFilter.all:   contextLabel = 'All Time'; break;
    }

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            colorScheme: cs,
            brandTokens: bt,
            icon: Icons.menu_book,
            value: dua,
            label: "Duʿās Created",
            sublabel: contextLabel,
            staggerDelay: 0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            colorScheme: cs,
            brandTokens: bt,
            icon: Icons.edit_note,
            value: journal,
            label: 'Journal Entries',
            sublabel: contextLabel,
            staggerDelay: 80,
          ),
        ),
      ],
    );
  }

  int _computeDuaCount(SummaryFilter f) {
    final list = DuaService.duas;
    final now = DateTime.now();
    switch (f) {
      case SummaryFilter.today:
        return list.where((d) => _isSameDate(d.createdAt, now)).length;
      case SummaryFilter.week:
        final start = _startOfWeek(now);
        final end = start.add(const Duration(days: 7));
        return list.where((d) => d.createdAt.isAfter(start.subtract(const Duration(milliseconds: 1))) && d.createdAt.isBefore(end)).length;
      case SummaryFilter.all:
        return list.length;
    }
  }

  int _computeJournalCount(SummaryFilter f) {
    final list = JournalService.entries;
    final now = DateTime.now();
    switch (f) {
      case SummaryFilter.today:
        return list.where((e) => _isSameDate(e.createdAt, now)).length;
      case SummaryFilter.week:
        final start = _startOfWeek(now);
        final end = start.add(const Duration(days: 7));
        return list.where((e) => e.createdAt.isAfter(start.subtract(const Duration(milliseconds: 1))) && e.createdAt.isBefore(end)).length;
      case SummaryFilter.all:
        return list.length;
    }
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _startOfWeek(DateTime d) {
    final weekday = d.weekday; // 1..7
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: weekday - 1));
  }
}

class _MetricCard extends StatefulWidget {
  final ColorScheme colorScheme;
  final BrandTokens brandTokens;
  final IconData icon;
  final int value;
  final String label;
  final String sublabel;
  final int staggerDelay; // ms
  const _MetricCard({required this.colorScheme, required this.brandTokens, required this.icon, required this.value, required this.label, required this.sublabel, required this.staggerDelay});

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  int _oldValue = 0;

  @override
  void didUpdateWidget(covariant _MetricCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final bt = widget.brandTokens;
    return _TapScale(
      onTap: () {},
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 220 + widget.staggerDelay),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          return Opacity(
            opacity: t,
            child: Transform.translate(offset: Offset(0, (1 - t) * 12), child: child),
          );
        },
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: bt.border, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(widget.icon, color: cs.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: _oldValue, end: widget.value),
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOut,
                      builder: (context, v, _) {
                        return Text('$v', style: h26w300.copyWith(color: cs.onSurface, fontSize: 20));
                      },
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.label} · ${widget.sublabel}',
                      style: meta12w400.copyWith(color: cs.onSurface.withValues(alpha: 0.7), fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionMunajatCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final BrandTokens brandTokens;
  const _MissionMunajatCard({required this.colorScheme, required this.brandTokens});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MissionMunajatScreen()),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.12),
              colorScheme.primary.withValues(alpha: 0.04),
            ],
          ),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.15),
              ),
              child: Icon(
                Icons.volunteer_activism,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mission Mun\u0101j\u0101t',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '10% of revenue to charity \u2014 help us reach our goal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontFamily: 'Poppins',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.primary.withValues(alpha: 0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _TapScale({required this.child, this.onTap});

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _PassiveInspirationCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final BrandTokens brandTokens;

  const _PassiveInspirationCard({
    required this.colorScheme,
    required this.brandTokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandTokens.border, width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => brandTokens.copperGradient.createShader(bounds),
            child: Text(
              'Verse of the Day',
              style: h20w400.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Verily, in the remembrance of Allah do hearts find rest.',
            style: body14w400.copyWith(
              color: colorScheme.onSurface,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quran 13:28',
            style: meta13w300.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}