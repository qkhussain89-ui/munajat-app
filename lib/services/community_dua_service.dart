import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hearth_prayer/models/community_dua.dart';

class CommunityDuaService {
  static const String _communityDuasKey = 'community_duas';
  static List<CommunityDua> _communityDuas = [];

  static List<CommunityDua> get communityDuas => List.unmodifiable(_communityDuas);

  static Future<void> initialize() async {
    await _loadCommunityDuas();
    if (_communityDuas.isEmpty) {
      await _createSampleCommunityDuas();
    }
  }

  static Future<void> _loadCommunityDuas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final duasJson = prefs.getString(_communityDuasKey);

      if (duasJson != null) {
        final duasList = jsonDecode(duasJson) as List;
        _communityDuas = duasList.map((json) => CommunityDua.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading community duas: $e');
      _communityDuas = [];
    }
  }

  static Future<void> _saveCommunityDuas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final duasJson = jsonEncode(_communityDuas.map((dua) => dua.toJson()).toList());
      await prefs.setString(_communityDuasKey, duasJson);
    } catch (e) {
      print('Error saving community duas: $e');
    }
  }

  static Future<void> _createSampleCommunityDuas() async {
    final now = DateTime.now();

    _communityDuas = [
      CommunityDua(
        id: 'cdua_1',
        name: 'Fatima Al-Rashid',
        title: 'Dua for Wisdom and Guidance',
        hearts: 2847,
        avatarUrl: 'assets/avatars/fatima.jpg',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      CommunityDua(
        id: 'cdua_2',
        name: 'Ahmed Hassan',
        title: 'Morning Gratitude Supplications',
        hearts: 1925,
        avatarUrl: 'assets/avatars/ahmed.jpg',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      CommunityDua(
        id: 'cdua_3',
        name: 'Zainab Malik',
        title: 'Seeking Mercy and Compassion',
        hearts: 3421,
        avatarUrl: 'assets/avatars/zainab.jpg',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    await _saveCommunityDuas();
  }

  static Future<void> addHeart(String duaId) async {
    final index = _communityDuas.indexWhere((dua) => dua.id == duaId);
    if (index != -1) {
      _communityDuas[index] = _communityDuas[index].copyWith(
        hearts: _communityDuas[index].hearts + 1,
      );
      await _saveCommunityDuas();
    }
  }
}
