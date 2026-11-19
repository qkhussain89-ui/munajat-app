import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hearth_prayer/models/islamic_event.dart';

class IslamicEventService {
  static const String _eventsKey = 'islamic_events';
  static List<IslamicEvent> _events = [];

  static List<IslamicEvent> get events => List.unmodifiable(_events);

  static Future<void> initialize() async {
    await _loadEvents();
    if (_events.isEmpty) {
      await _createSampleEvents();
    }
  }

  static Future<void> _loadEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_eventsKey);

      if (eventsJson != null) {
        final eventsList = jsonDecode(eventsJson) as List;
        _events = eventsList.map((json) => IslamicEvent.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading events: $e');
      _events = [];
    }
  }

  static Future<void> _saveEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = jsonEncode(_events.map((event) => event.toJson()).toList());
      await prefs.setString(_eventsKey, eventsJson);
    } catch (e) {
      print('Error saving events: $e');
    }
  }

  static Future<void> _createSampleEvents() async {
    final now = DateTime.now();

    _events = [
      IslamicEvent(
        id: 'event_1',
        name: 'Tahajjud Night',
        date: 'Last Third of Night',
        countdownText: 'Every Night',
        hadith: 'The closest the Lord comes to His servant is in the last third of the night. If you can be among those who remember Allah at that time, do so.',
        reference: 'Tirmidhi',
        createdAt: now,
      ),
      IslamicEvent(
        id: 'event_2',
        name: 'Night of Power',
        date: 'Ramadan 27th',
        countdownText: 'In 67 days',
        hadith: 'The Night of Power is better than a thousand months. The angels and the Spirit descend during it by their Lord\'s permission.',
        reference: 'Quran 97:3-4',
        createdAt: now,
      ),
      IslamicEvent(
        id: 'event_3',
        name: 'Jumu\'ah Prayer',
        date: 'Every Friday',
        countdownText: '3 days until Friday',
        hadith: 'Friday is the best day on which the sun has risen. On it, Adam was created. On it, he was made to enter paradise, and on it, he was expelled from it.',
        reference: 'Muslim',
        createdAt: now,
      ),
    ];

    await _saveEvents();
  }
}
