import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:hearth_prayer/models/prayer_times.dart';

class NextPrayerInfo {
  final String name;
  final DateTime at;
  final int minutesUntil;
  final double progress; // 0..1 between "window start" -> next prayer time

  const NextPrayerInfo({
    required this.name,
    required this.at,
    required this.minutesUntil,
    required this.progress,
  });
}

class PrayerTimesService {
  static const String _cacheKey = 'prayer_times_cache_v1';
  static PrayerTimes? _cached;
  static bool _initialized = false;

  static PrayerTimes? get todaysPrayerTimes {
    final pt = _cached;
    if (pt == null) return null;

    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    if (pt.date != today) return null;

    return pt;
  }

  static DateTime? get lastFetchedAt => _cached?.fetchedAt;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _loadFromCache();
  }
  
  /// Force clear cached prayer times so next ensureToday() will re-fetch.
  static Future<void> clearCache() async {
    _cached = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    } catch (e) {
      debugPrint('PrayerTimesService clearCache failed: $e');
    }
  }

  static Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_cacheKey);
      if (s == null) return;
      _cached = PrayerTimes.fromCacheString(s);
    } catch (e) {
      debugPrint('PrayerTimesService cache load failed: $e');
      _cached = null;
    }
  }

  static Future<void> _saveToCache(PrayerTimes times) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, times.toCacheString());
    } catch (e) {
      debugPrint('PrayerTimesService cache save failed: $e');
    }
  }

  static bool _isStaleForToday(PrayerTimes times) {
    final now = DateTime.now();
    final today = DateFormat('dd-MM-yyyy').format(now);
    if (times.date != today) return true;

    // treat stale if fetched > 24h ago
    final age = now.difference(times.fetchedAt);
    return age.inHours >= 24;
  }

  /// Ensures we have prayer times for today. Uses cache if fresh.
  static Future<PrayerTimes?> ensureToday({
    required double latitude,
    required double longitude,
    int method = 3, // MWL default
    int school = 0, // 0=Shafi, 1=Hanafi (for Asr)
  }) async {
    await initialize();

    final existing = _cached;
    if (existing != null && !_isStaleForToday(existing)) {
      return existing;
    }

    try {
      final fetched = await fetchPrayerTimes(
        latitude: latitude,
        longitude: longitude,
        method: method,
        school: school,
      );
      return fetched;
    } catch (e) {
      // If fetch fails, fall back to any cached data (even stale) for offline support
      debugPrint('PrayerTimesService ensureToday fetch failed: $e');
      return _cached;
    }
  }

  static Future<PrayerTimes> fetchPrayerTimes({
    required double latitude,
    required double longitude,
    int method = 3,
    int school = 0,
  }) async {
    final now = DateTime.now();
    final date = DateFormat('dd-MM-yyyy').format(now);

    final url = Uri.parse(
      'https://api.aladhan.com/v1/timings/$date'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&method=$method'
      '&school=$school',
    );

    final resp = await http.get(url).timeout(const Duration(seconds: 12));

    if (resp.statusCode != 200) {
      throw Exception('AlAdhan HTTP ${resp.statusCode}');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('AlAdhan: missing data');
    }

    final times = PrayerTimes.fromAlAdhanJson(data);
    _cached = times;
    await _saveToCache(times);
    return times;
  }

  static DateTime? _timeToDateTimeToday(String hhmm) {
    if (hhmm.trim().isEmpty) return null;
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }

  static NextPrayerInfo? getNextPrayerInfo() {
    final pt = todaysPrayerTimes;
    if (pt == null) return null;

    final now = DateTime.now();

    final order = const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final times = <String, DateTime>{};

    for (final name in order) {
      final dt = _timeToDateTimeToday(pt.timings[name] ?? '');
      if (dt != null) times[name] = dt;
    }

    // If we can't parse enough, bail gracefully.
    if (times.length < 3) return null;

    // Find next prayer today
    for (final name in order) {
      final t = times[name];
      if (t != null && now.isBefore(t)) {
        final mins = t.difference(now).inMinutes;
        final start = _windowStartForProgress(now: now, times: times);
        final progress = _progressBetween(start: start, end: t, now: now);
        return NextPrayerInfo(name: name, at: t, minutesUntil: mins < 0 ? 0 : mins, progress: progress);
      }
    }

    // After Isha → next is tomorrow Fajr
    final fajr = times['Fajr'];
    if (fajr != null) {
      final tomorrowFajr = fajr.add(const Duration(days: 1));
      final mins = tomorrowFajr.difference(now).inMinutes;

      // progress window start: Isha time if available, else midnight
      final isha = times['Isha'];
      final start = (isha != null && now.isAfter(isha))
          ? isha
          : DateTime(now.year, now.month, now.day);

      final progress = _progressBetween(start: start, end: tomorrowFajr, now: now);
      return NextPrayerInfo(name: 'Fajr', at: tomorrowFajr, minutesUntil: mins < 0 ? 0 : mins, progress: progress);
    }

    return null;
  }

  static DateTime _windowStartForProgress({
    required DateTime now,
    required Map<String, DateTime> times,
  }) {
    // If now is before Fajr, we start at midnight for a reasonable ring.
    final fajr = times['Fajr'];
    if (fajr != null && now.isBefore(fajr)) {
      return DateTime(now.year, now.month, now.day);
    }

    // Otherwise start at the most recent prayer time.
    final order = const ['Isha', 'Maghrib', 'Asr', 'Dhuhr', 'Fajr'];
    for (final n in order) {
      final t = times[n];
      if (t != null && (now.isAfter(t) || now.isAtSameMomentAs(t))) {
        return t;
      }
    }

    return DateTime(now.year, now.month, now.day);
  }

  static double _progressBetween({
    required DateTime start,
    required DateTime end,
    required DateTime now,
  }) {
    final total = end.difference(start).inSeconds;
    if (total <= 0) return 0.0;
    final elapsed = now.difference(start).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}
