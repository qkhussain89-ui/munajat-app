import 'package:flutter/material.dart';

enum MomentType { fridayLastHour, tahajjud, afterPrayer, raining, generic }

class HomeMomentController {
  final DateTime now;
  final MomentType? forcedState;

  HomeMomentController({DateTime? now, this.forcedState}) : now = now ?? DateTime.now();

  MomentType get current {
    if (forcedState != null) return forcedState!;

    final hour = now.hour;
    final minute = now.minute;
    final weekday = now.weekday;

    // Priority 1: Friday 16:00–Maghrib (18:00): fridayLastHour
    if (weekday == 5 && hour >= 16 && hour < 18) {
      return MomentType.fridayLastHour;
    }

    // Priority 2: 02:00–04:00: tahajjud (last third of night)
    if (hour >= 2 && hour < 4) {
      return MomentType.tahajjud;
    }

    // Priority 3: 10 min after mock prayer times (simplified): afterPrayer
    // Mock prayer times: Fajr 05:30, Dhuhr 12:00, Asr 15:30, Maghrib 18:00, Isha 20:00
    const prayerTimes = [
      (5, 30),
      (12, 0),
      (15, 30),
      (18, 0),
      (20, 0),
    ];

    for (final (prayerHour, prayerMin) in prayerTimes) {
      final prayerDateTime = DateTime(now.year, now.month, now.day, prayerHour, prayerMin);
      final diff = now.difference(prayerDateTime).inMinutes;
      if (diff >= 0 && diff <= 10) {
        return MomentType.afterPrayer;
      }
    }

    // Priority 4: Mock raining state (false by default)
    const isMockRaining = false;
    if (isMockRaining) {
      return MomentType.raining;
    }

    // Priority 5: Fallback generic moment
    return MomentType.generic;
  }

  String headline(MomentType t) => switch (t) {
    MomentType.fridayLastHour => 'A hidden hour on Friday is near — prepare your heart.',
    MomentType.tahajjud => 'The last third of night is here — your Lord invites you to ask.',
    MomentType.afterPrayer => 'You just prayed — before you move, make duʿā.',
    MomentType.raining => 'Mercy descends with rain — raise your hands.',
    MomentType.generic => 'Between Maghrib and ʿIshāʾ, mercy descends — raise your hands.',
  };

  String subheadline(MomentType t) => switch (t) {
    MomentType.fridayLastHour => 'Between Asr and Maghrib, the doors of duʿāʾ are wide open.',
    MomentType.tahajjud => 'The most blessed time to call upon Allah.',
    MomentType.afterPrayer => 'Your prayers carry the most weight in this moment.',
    MomentType.raining => 'Allah accepts duʿāʾ during and after rainfall.',
    MomentType.generic => 'A peaceful time for reflection and supplication.',
  };

  String cta(MomentType t) => 'Make duʿā now';

  String subtitle(MomentType t) => subheadline(t);

  IconData icon(MomentType t) => switch (t) {
    MomentType.fridayLastHour => Icons.calendar_today,
    MomentType.tahajjud => Icons.nights_stay,
    MomentType.afterPrayer => Icons.favorite,
    MomentType.raining => Icons.cloud_download,
    MomentType.generic => Icons.star,
  };
}
