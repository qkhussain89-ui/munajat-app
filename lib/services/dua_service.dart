import 'package:flutter/foundation.dart';
import 'package:hearth_prayer/models/dua.dart';
import 'package:hearth_prayer/supabase/supabase_config.dart';
import 'package:hearth_prayer/services/user_service.dart';

class DuaService {
  static List<Dua> _duas = [];
  
  static List<Dua> get duas => List.unmodifiable(_duas);
  
  static Future<void> initialize() async {
    await _loadDuas();
  }
  
  static Future<void> _loadDuas() async {
    try {
      final userId = UserService.currentUser?.id;
      if (userId == null) {
        _duas = [];
        return;
      }

      final duasData = await SupabaseService.select(
        'duas',
        filters: {'user_id': userId},
        orderBy: 'created_at',
        ascending: false,
      );
      
      _duas = duasData.map((json) => Dua.fromJson({
        'id': json['id'],
        'userId': json['user_id'],
        'folderId': json['folder_id'] ?? '',
        'title': json['title'],
        'preview': json['preview'],
        'body': json['body'],
        'englishText': json['generated_text'],
        'tags': json['tags'] ?? [],
        'favorite': json['favorite'] ?? false,
        'isBookmarked': json['is_bookmarked'] ?? false,
        'isAnswered': json['is_answered'] ?? false,
        'createdAt': json['created_at'],
        'updatedAt': json['updated_at'],
        'outputLanguage': json['output_language'] ?? 'english',
        'isInaugural': json['is_inaugural'] ?? false,
      })).toList();
    } catch (e) {
      debugPrint('Error loading duas: $e');
      _duas = [];
    }
  }
  
  static Future<void> createDua({
    required String title,
    required String englishText,
    required String body,
    required List<String> tags,
    String? folderId,
    String outputLanguage = 'english',
    bool isInaugural = false,
  }) async {
    try {
      final userId = UserService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final duaData = {
        'user_id': userId,
        'folder_id': folderId,
        'title': title,
        'preview': englishText.length > 100 ? englishText.substring(0, 100) + '...' : englishText,
        'body': body,
        'generated_text': englishText,
        'tags': tags,
        'favorite': false,
        'is_bookmarked': false,
        'is_answered': false,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'output_language': outputLanguage,
        'is_inaugural': isInaugural,
      };
      
      final result = await SupabaseService.insert('duas', duaData);
      
      if (result.isNotEmpty) {
        final newDua = Dua.fromJson({
          'id': result[0]['id'],
          'userId': result[0]['user_id'],
          'folderId': result[0]['folder_id'] ?? '',
          'title': result[0]['title'],
          'preview': result[0]['preview'],
          'body': result[0]['body'],
          'englishText': result[0]['generated_text'],
          'tags': result[0]['tags'] ?? [],
          'favorite': result[0]['favorite'] ?? false,
          'isBookmarked': result[0]['is_bookmarked'] ?? false,
          'isAnswered': result[0]['is_answered'] ?? false,
          'createdAt': result[0]['created_at'],
          'updatedAt': result[0]['updated_at'],
          'outputLanguage': result[0]['output_language'] ?? 'english',
          'isInaugural': result[0]['is_inaugural'] ?? false,
        });
        _duas.insert(0, newDua);
      }
    } catch (e) {
      debugPrint('Error creating dua: $e');
      rethrow;
    }
  }
  
  static Future<void> updateDua(Dua updatedDua) async {
    try {
      final now = DateTime.now();
      await SupabaseService.update(
        'duas',
        {
          'title': updatedDua.title,
          'preview': updatedDua.preview,
          'body': updatedDua.body,
          'generated_text': updatedDua.englishText,
          'tags': updatedDua.tags,
          'favorite': updatedDua.favorite,
          'is_bookmarked': updatedDua.isBookmarked,
          'is_answered': updatedDua.isAnswered,
          'folder_id': updatedDua.folderId.isEmpty ? null : updatedDua.folderId,
          'updated_at': now.toIso8601String(),
          'output_language': updatedDua.outputLanguage,
        },
        filters: {'id': updatedDua.id},
      );
      
      final index = _duas.indexWhere((dua) => dua.id == updatedDua.id);
      if (index != -1) {
        _duas[index] = updatedDua.copyWith(updatedAt: now);
      }
    } catch (e) {
      debugPrint('Error updating dua: $e');
      rethrow;
    }
  }
  
  static Future<void> deleteDua(String duaId) async {
    try {
      await SupabaseService.delete('duas', filters: {'id': duaId});
      _duas.removeWhere((dua) => dua.id == duaId);
    } catch (e) {
      debugPrint('Error deleting dua: $e');
      rethrow;
    }
  }

  static Future<void> clearFolderForDuas(String folderId) async {
    try {
      // Update all duas with this folder_id to have null folder_id
      final affectedDuas = _duas.where((d) => d.folderId == folderId).toList();
      
      for (final dua in affectedDuas) {
        await updateDua(dua.copyWith(folderId: ''));
      }
    } catch (e) {
      debugPrint('Error clearing folder for duas: $e');
      rethrow;
    }
  }
  
  static List<Dua> getDuasByFolder(String folderId) {
    return _duas.where((dua) => dua.folderId == folderId).toList();
  }
  
  static List<Dua> getBookmarkedDuas() {
    return _duas.where((dua) => dua.isBookmarked).toList();
  }
  
  static List<Dua> searchDuas(String query) {
    final lowerQuery = query.toLowerCase();
    return _duas.where((dua) =>
        dua.title.toLowerCase().contains(lowerQuery) ||
        dua.englishText.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}
