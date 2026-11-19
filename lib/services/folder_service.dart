import 'package:flutter/foundation.dart';
import 'package:hearth_prayer/models/folder.dart';
import 'package:hearth_prayer/supabase/supabase_config.dart';
import 'package:hearth_prayer/services/user_service.dart';

class FolderService {
  static List<Folder> _folders = [];

  static List<Folder> get folders => List.unmodifiable(_folders);

  static Future<void> initialize() async {
    await _loadFolders();
  }

  static Future<void> _loadFolders() async {
    try {
      final userId = UserService.currentUser?.id;
      if (userId == null) {
        _folders = [];
        return;
      }

      final foldersData = await SupabaseService.select(
        'folders',
        filters: {'user_id': userId},
        orderBy: 'position',
        ascending: true,
      );
      
      _folders = foldersData.map((json) => Folder.fromJson({
        'id': json['id'],
        'userId': json['user_id'],
        'name': json['name'],
        'emoji': json['emoji'],
        'count': json['count'] ?? 0,
        'position': json['position'] ?? 0,
        'createdAt': json['created_at'],
      })).toList();
    } catch (e) {
      debugPrint('Error loading folders: $e');
      _folders = [];
    }
  }

  static Future<void> createFolder({required String name, String? emoji, String? userId}) async {
    try {
      final currentUserId = userId ?? UserService.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final maxPosition = _folders.isEmpty ? 0 : _folders.map((f) => f.position).reduce((a, b) => a > b ? a : b);
      final now = DateTime.now();
      
      final folderData = {
        'user_id': currentUserId,
        'name': name,
        'emoji': emoji,
        'count': 0,
        'position': maxPosition + 1,
        'created_at': now.toIso8601String(),
      };

      final result = await SupabaseService.insert('folders', folderData);
      
      if (result.isNotEmpty) {
        final newFolder = Folder.fromJson({
          'id': result[0]['id'],
          'userId': result[0]['user_id'],
          'name': result[0]['name'],
          'emoji': result[0]['emoji'],
          'count': result[0]['count'] ?? 0,
          'position': result[0]['position'] ?? 0,
          'createdAt': result[0]['created_at'],
        });
        _folders.add(newFolder);
      }
    } catch (e) {
      debugPrint('Error creating folder: $e');
      rethrow;
    }
  }

  static Future<void> deleteFolder(String folderId) async {
    try {
      await SupabaseService.delete('folders', filters: {'id': folderId});
      _folders.removeWhere((f) => f.id == folderId);
    } catch (e) {
      debugPrint('Error deleting folder: $e');
      rethrow;
    }
  }

  static Future<void> updateFolder({
    required String id,
    required String name,
    String? emoji,
  }) async {
    try {
      final normalizedEmoji = (emoji != null && emoji.trim().isEmpty) ? null : emoji;
      
      await SupabaseService.update(
        'folders',
        {
          'name': name,
          'emoji': normalizedEmoji,
        },
        filters: {'id': id},
      );

      final idx = _folders.indexWhere((f) => f.id == id);
      if (idx != -1) {
        _folders[idx] = _folders[idx].copyWith(
          name: name,
          emoji: normalizedEmoji,
        );
      }
    } catch (e) {
      debugPrint('Error updating folder: $e');
      rethrow;
    }
  }

  static Future<void> updateFolderCount(String folderId, int count) async {
    try {
      await SupabaseService.update(
        'folders',
        {'count': count},
        filters: {'id': folderId},
      );

      final i = _folders.indexWhere((f) => f.id == folderId);
      if (i != -1) {
        _folders[i] = _folders[i].copyWith(count: count);
      }
    } catch (e) {
      debugPrint('Error updating folder count: $e');
      rethrow;
    }
  }

  static Folder? getFolderById(String folderId) {
    try {
      return _folders.firstWhere((f) => f.id == folderId);
    } catch (_) {
      return null;
    }
  }

  static Future<void> reorderFolders(List<String> orderedIds) async {
    try {
      for (var i = 0; i < orderedIds.length; i++) {
        await SupabaseService.update(
          'folders',
          {'position': i},
          filters: {'id': orderedIds[i]},
        );

        final idx = _folders.indexWhere((f) => f.id == orderedIds[i]);
        if (idx != -1) {
          _folders[idx] = _folders[idx].copyWith(position: i);
        }
      }
      _folders.sort((a, b) => a.position.compareTo(b.position));
    } catch (e) {
      debugPrint('Error reordering folders: $e');
      rethrow;
    }
  }

  static List<Folder> getOrderedFolders() {
    final sorted = List<Folder>.from(_folders);
    sorted.sort((a, b) {
      final posCmp = a.position.compareTo(b.position);
      if (posCmp != 0) return posCmp;
      return a.createdAt.compareTo(b.createdAt);
    });
    return sorted;
  }
}
