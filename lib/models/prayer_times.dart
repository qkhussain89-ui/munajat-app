import 'dart:convert';

class PrayerTimes {
  final String date; // dd-MM-yyyy
  final Map<String, String> timings; // {'Fajr':'05:30', ...}
  final DateTime fetchedAt;

  const PrayerTimes({
    required this.date,
    required this.timings,
    required this.fetchedAt,
  });

  PrayerTimes copyWith({
    String? date,
    Map<String, String>? timings,
    DateTime? fetchedAt,
  }) {
    return PrayerTimes(
      date: date ?? this.date,
      timings: timings ?? this.timings,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'timings': timings,
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      date: json['date'] as String,
      timings: Map<String, String>.from(json['timings'] as Map),
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }

  String toCacheString() => jsonEncode(toJson());

  factory PrayerTimes.fromCacheString(String s) {
    return PrayerTimes.fromJson(jsonDecode(s) as Map<String, dynamic>);
  }

  /// AlAdhan response shape:
  /// { data: { timings: {...}, date: { gregorian: { date: "dd-MM-yyyy" } } } }
  factory PrayerTimes.fromAlAdhanJson(Map<String, dynamic> data) {
    final gregorian = (data['date'] as Map?)?['gregorian'] as Map?;
    final dateStr = (gregorian?['date'] as String?) ?? '';

    final timingsRaw = (data['timings'] as Map?) ?? const <String, dynamic>{};

    String cleanTime(dynamic v) {
      // AlAdhan sometimes returns: "05:30 (+05)" or "05:30 (PKT)"
      final s = (v as String? ?? '').trim();
      if (s.isEmpty) return '';
      // Keep only HH:mm
      final hhmm = s.split(' ').first.trim();
      return hhmm;
    }

    final timings = <String, String>{
      'Fajr': cleanTime(timingsRaw['Fajr']),
      'Dhuhr': cleanTime(timingsRaw['Dhuhr']),
      'Asr': cleanTime(timingsRaw['Asr']),
      'Maghrib': cleanTime(timingsRaw['Maghrib']),
      'Isha': cleanTime(timingsRaw['Isha']),
    };

    return PrayerTimes(
      date: dateStr,
      timings: timings,
      fetchedAt: DateTime.now(),
    );
  }
}
