import 'package:flutter/foundation.dart';
import 'package:hearth_prayer/models/journal_entry.dart';
import 'package:hearth_prayer/supabase/supabase_config.dart';
import 'package:hearth_prayer/services/user_service.dart';

class JournalService {
  static List<JournalEntry> _entries = [];

  static List<JournalEntry> get entries {
    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(_entries);
  }

  static Future<void> initialize() async {
    await _loadEntries();
  }

  static Future<void> _loadEntries() async {
    try {
      final userId = UserService.currentUser?.id;
      if (userId == null) {
        _entries = [];
        return;
      }

      final entriesData = await SupabaseService.select(
        'journal_entries',
        filters: {'user_id': userId},
        orderBy: 'created_at',
        ascending: false,
      );

      _entries = entriesData.map((json) => JournalEntry.fromJson({
        'id': json['id'],
        'moods': json['moods'] ?? [],
        'blessings': json['blessings'] ?? [],
        'weights': json['weights'] ?? [],
        'challenges': json['challenges'] ?? [],
        'dua': json['dua'] ?? '',
        'reminder': json['reminder'] ?? '',
        'createdAt': json['created_at'],
        'updatedAt': json['updated_at'],
      })).toList();
    } catch (e) {
      debugPrint('Error loading journal entries: $e');
      _entries = [];
    }
  }

  static Future<void> addEntry({
    required List<String> moods,
    required List<String> blessings,
    required List<String> weights,
    required List<String> challenges,
    required String dua,
    required String reminder,
  }) async {
    try {
      final userId = UserService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final entryData = {
        'user_id': userId,
        'moods': moods,
        'blessings': blessings.where((b) => b.isNotEmpty).toList(),
        'weights': weights.where((w) => w.isNotEmpty).toList(),
        'challenges': challenges.where((c) => c.isNotEmpty).toList(),
        'dua': dua,
        'reminder': reminder,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final result = await SupabaseService.insert('journal_entries', entryData);

      if (result.isNotEmpty) {
        final newEntry = JournalEntry.fromJson({
          'id': result[0]['id'],
          'moods': result[0]['moods'] ?? [],
          'blessings': result[0]['blessings'] ?? [],
          'weights': result[0]['weights'] ?? [],
          'challenges': result[0]['challenges'] ?? [],
          'dua': result[0]['dua'] ?? '',
          'reminder': result[0]['reminder'] ?? '',
          'createdAt': result[0]['created_at'],
          'updatedAt': result[0]['updated_at'],
        });
        _entries.add(newEntry);
      }
    } catch (e) {
      debugPrint('Error adding journal entry: $e');
      rethrow;
    }
  }

  static Future<void> updateEntry(JournalEntry entry) async {
    try {
      final now = DateTime.now();
      await SupabaseService.update(
        'journal_entries',
        {
          'moods': entry.moods,
          'blessings': entry.blessings,
          'weights': entry.weights,
          'challenges': entry.challenges,
          'dua': entry.dua,
          'reminder': entry.reminder,
          'updated_at': now.toIso8601String(),
        },
        filters: {'id': entry.id},
      );

      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = entry.copyWith(updatedAt: now);
      }
    } catch (e) {
      debugPrint('Error updating journal entry: $e');
      rethrow;
    }
  }

  static Future<void> deleteEntry(String id) async {
    try {
      await SupabaseService.delete('journal_entries', filters: {'id': id});
      _entries.removeWhere((e) => e.id == id);
    } catch (e) {
      debugPrint('Error deleting journal entry: $e');
      rethrow;
    }
  }

  static JournalEntry? getEntry(String id) {
    try {
      return _entries.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}

