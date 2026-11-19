import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:hearth_prayer/services/prayer_times_service.dart';
import 'package:hearth_prayer/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  bool _loading = true;
  bool _hasError = false;

  final prayers = const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  String _timeTextFor(String prayer, dynamic pt) {
    if (_loading) return '...';
    if (_hasError) return '--:--';
    final v = pt?.timings[prayer];
    if (v == null || v.trim().isEmpty) return '--:--';

    // Convert HH:mm to 12-hour format
    final parts = v.split(':');
    if (parts.length < 2) return v;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  String _countdownFor(String prayer, dynamic pt, dynamic next) {
    if (_loading || _hasError || pt == null) return '';

    final v = pt.timings[prayer];
    if (v == null || v.trim().isEmpty) return '';

    final parts = v.split(':');
    if (parts.length < 2) return '';
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    final now = DateTime.now();
    var prayerTime = DateTime(now.year, now.month, now.day, hour, minute);

    // If prayer is in the past, show "Passed"
    if (now.isAfter(prayerTime)) return 'Passed';

    // Show countdown
    final diff = prayerTime.difference(now).inMinutes;
    final h = diff ~/ 60;
    final m = diff % 60;

    if (h > 0 && m > 0) return 'in ${h}h ${m}m';
    if (h > 0) return 'in ${h}h';
    return 'in ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final bt = context.brandTokens;

    final pt = PrayerTimesService.todaysPrayerTimes;
    final next = PrayerTimesService.getNextPrayerInfo();

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 22,
                          color: t.colorScheme.secondary,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                        padding: EdgeInsets.zero,
                        tooltip: 'Back',
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ShaderMask(
                          shaderCallback: (bounds) => bt.copperGradient.createShader(bounds),
                          child: const Text(
                            'Prayer Times',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              height: 1.3,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              // Date display
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Center(
                  child: Builder(
                    builder: (context) {
                      final now = DateTime.now();
                      final gregorianDate = DateFormat('EEEE, d MMMM yyyy').format(now);
                      final hijriDate = HijriCalendar.fromDate(now);
                      final hijriFormatted = '${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear}';

                      return Text(
                        '$gregorianDate • $hijriFormatted',
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.secondary.withOpacity(0.8),
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: prayers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final prayer = prayers[index];
                    final isCurrentNext = next != null && next.name == prayer;
                    final timeStr = _timeTextFor(prayer, pt);
                    final countdown = _countdownFor(prayer, pt, next);

                    return Container(
                      decoration: BoxDecoration(
                        color: isCurrentNext
                            ? cs.primary.withValues(alpha: 0.08)
                            : cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrentNext ? cs.primary.withValues(alpha: 0.3) : bt.border,
                          width: isCurrentNext ? 1.5 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Row(
                        children: [
                          // Prayer icon
                          _PrayerSunIcon(
                            prayer: prayer,
                            isNext: isCurrentNext,
                            primaryColor: cs.primary,
                            mutedColor: cs.onSurface.withValues(alpha: 0.35),
                          ),
                          const SizedBox(width: 16),
                          // Prayer name and countdown
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prayer,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 17,
                                    fontWeight: isCurrentNext ? FontWeight.w600 : FontWeight.w500,
                                    color: isCurrentNext ? cs.primary : cs.onSurface,
                                  ),
                                ),
                                if (countdown.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      countdown,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: isCurrentNext
                                            ? cs.primary.withValues(alpha: 0.7)
                                            : cs.onSurface.withValues(alpha: 0.45),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Time display
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                timeStr,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 17,
                                  fontWeight: isCurrentNext ? FontWeight.w600 : FontWeight.w500,
                                  color: isCurrentNext ? cs.primary : cs.onSurface.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerSunIcon extends StatelessWidget {
  final String prayer;
  final bool isNext;
  final Color primaryColor;
  final Color mutedColor;

  const _PrayerSunIcon({
    required this.prayer,
    required this.isNext,
    required this.primaryColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: _SunPositionPainter(
          prayer: prayer,
          activeColor: isNext ? primaryColor : mutedColor,
          horizonColor: isNext ? primaryColor.withValues(alpha: 0.3) : mutedColor.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _SunPositionPainter extends CustomPainter {
  final String prayer;
  final Color activeColor;
  final Color horizonColor;

  _SunPositionPainter({
    required this.prayer,
    required this.activeColor,
    required this.horizonColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizonY = h * 0.65;

    // Draw horizon line
    final horizonPaint = Paint()
      ..color = horizonColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.1, horizonY), Offset(w * 0.9, horizonY), horizonPaint);

    final bodyPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    final bodyStroke = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    switch (prayer) {
      case 'Fajr':
        // Sun peeking above horizon — small arc visible above line
        final center = Offset(w * 0.5, horizonY);
        final radius = w * 0.18;
        // Draw only the top half of the circle (above horizon)
        final rect = Rect.fromCircle(center: center, radius: radius);
        canvas.drawArc(rect, 3.1416, 3.1416, false, bodyPaint); // top semicircle
        // Small rays above
        for (var i = 0; i < 3; i++) {
          final angle = -0.8 + (i * 0.8); // spread rays
          final startY = horizonY - radius - 4;
          final endY = startY - 5;
          final xOffset = i == 1 ? 0.0 : (i == 0 ? -6.0 : 6.0);
          canvas.drawLine(
            Offset(w * 0.5 + xOffset, startY),
            Offset(w * 0.5 + xOffset, endY),
            bodyStroke..strokeWidth = 1.2,
          );
        }
        break;

      case 'Dhuhr':
        // Full sun high above horizon
        final center = Offset(w * 0.5, horizonY - w * 0.28);
        final radius = w * 0.14;
        canvas.drawCircle(center, radius, bodyPaint);
        // Four small rays
        final rayLength = 5.0;
        final gap = 3.0;
        // Top
        canvas.drawLine(Offset(center.dx, center.dy - radius - gap), Offset(center.dx, center.dy - radius - gap - rayLength), bodyStroke..strokeWidth = 1.2);
        // Bottom
        canvas.drawLine(Offset(center.dx, center.dy + radius + gap), Offset(center.dx, center.dy + radius + gap + rayLength), bodyStroke..strokeWidth = 1.2);
        // Left
        canvas.drawLine(Offset(center.dx - radius - gap, center.dy), Offset(center.dx - radius - gap - rayLength, center.dy), bodyStroke..strokeWidth = 1.2);
        // Right
        canvas.drawLine(Offset(center.dx + radius + gap, center.dy), Offset(center.dx + radius + gap + rayLength, center.dy), bodyStroke..strokeWidth = 1.2);
        break;

      case 'Asr':
        // Sun lower, between peak and horizon
        final center = Offset(w * 0.5, horizonY - w * 0.15);
        final radius = w * 0.14;
        canvas.drawCircle(center, radius, bodyPaint);
        // Two small rays (less than Dhuhr — afternoon feel)
        canvas.drawLine(Offset(center.dx - radius - 3, center.dy - 3), Offset(center.dx - radius - 8, center.dy - 6), bodyStroke..strokeWidth = 1.2);
        canvas.drawLine(Offset(center.dx + radius + 3, center.dy - 3), Offset(center.dx + radius + 8, center.dy - 6), bodyStroke..strokeWidth = 1.2);
        break;

      case 'Maghrib':
        // Sun half-sunk below horizon
        final center = Offset(w * 0.5, horizonY);
        final radius = w * 0.18;
        // Draw only top half (above horizon)
        final rect = Rect.fromCircle(center: center, radius: radius);
        canvas.drawArc(rect, 3.1416, 3.1416, false, bodyPaint);
        // No rays — sunset is calm
        break;

      case 'Isha':
        // Crescent moon above horizon
        final center = Offset(w * 0.5, horizonY - w * 0.22);
        final moonRadius = w * 0.13;
        // Draw full circle
        canvas.drawCircle(center, moonRadius, bodyPaint);
        // Cut out a smaller circle to create crescent
        final cutout = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        // Check if we're in dark mode
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        if (brightness == Brightness.dark) {
          cutout.color = const Color(0xFF0A0A0A); // dark background
        }
        canvas.drawCircle(Offset(center.dx + moonRadius * 0.45, center.dy - moonRadius * 0.2), moonRadius * 0.85, cutout);
        // Small dot for a star
        canvas.drawCircle(Offset(w * 0.28, horizonY - w * 0.32), 1.5, bodyPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _SunPositionPainter oldDelegate) {
    return oldDelegate.prayer != prayer || oldDelegate.activeColor != activeColor;
  }
}
