import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hearth_prayer/models/stats.dart';

class StatsService {
  static const String _statsKey = 'app_stats';
  static Stats? _stats;
  
  static Stats? get stats => _stats;
  
  static Future<void> initialize() async {
    await _loadStats();
    if (_stats == null) {
      await _createDefaultStats();
    }
  }
  
  static Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);
      
      if (statsJson != null) {
        final statsData = jsonDecode(statsJson);
        _stats = Stats.fromJson(statsData);
      }
    } catch (e) {
      print('Error loading stats: $e');
      _stats = null;
    }
  }
  
  static Future<void> _saveStats() async {
    try {
      if (_stats != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_statsKey, jsonEncode(_stats!.toJson()));
      }
    } catch (e) {
      print('Error saving stats: $e');
    }
  }
  
  static Future<void> _createDefaultStats() async {
    _stats = Stats(
      duasMade: 127,
      subscribers: 2843,
      downloads: 15621,
      charityImpact: 2456.78,
      updatedAt: DateTime.now(),
    );
    
    await _saveStats();
  }
  
  static Future<void> incrementDuasMade() async {
    if (_stats != null) {
      _stats = _stats!.copyWith(
        duasMade: _stats!.duasMade + 1,
        updatedAt: DateTime.now(),
      );
      await _saveStats();
    }
  }
  
  static Future<void> updateStats({
    int? duasMade,
    int? subscribers,
    int? downloads,
    double? charityImpact,
  }) async {
    if (_stats != null) {
      _stats = _stats!.copyWith(
        duasMade: duasMade ?? _stats!.duasMade,
        subscribers: subscribers ?? _stats!.subscribers,
        downloads: downloads ?? _stats!.downloads,
        charityImpact: charityImpact ?? _stats!.charityImpact,
        updatedAt: DateTime.now(),
      );
      await _saveStats();
    }
  }
}