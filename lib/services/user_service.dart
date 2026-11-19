import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hearth_prayer/models/user.dart';
import 'package:hearth_prayer/auth/supabase_auth_manager.dart';
import 'package:hearth_prayer/supabase/supabase_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final SupabaseAuthManager _authManager = SupabaseAuthManager();
  static User? _currentUser;
  
  static User? get currentUser => _currentUser;
  
  static Future<void> initialize() async {
    await _loadCurrentUser();
  }
  
  static Future<void> _loadCurrentUser() async {
    try {
      final authUser = SupabaseConfig.auth.currentUser;
      if (authUser != null) {
        _currentUser = await _authManager.getCurrentUser();
      } else {
        _currentUser = null;
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      _currentUser = null;
    }
  }
  
  static Future<bool> signIn(BuildContext context, String email, String password) async {
    try {
      final user = await _authManager.signInWithEmail(
        context,
        email,
        password,
      );
      
      if (user != null) {
        _currentUser = user;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error signing in: $e');
      return false;
    }
  }
  
  static Future<bool> signUp(BuildContext context, String firstName, String lastName, String email, String password) async {
    try {
      final user = await _authManager.createAccountWithEmail(
        context,
        email,
        password,
        firstName: firstName,
        lastName: lastName,
      );
      
      if (user != null) {
        // Update name fields if provided
        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          await updateUser(user.copyWith(
            firstName: firstName,
            lastName: lastName,
            name: '$firstName $lastName',  // Keep deprecated name field in sync
          ));
        }
        // _currentUser is already set by updateUser() above — do NOT overwrite with stale `user`
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error signing up: $e');
      return false;
    }
  }
  
  static Future<bool> signInAnonymously(BuildContext context) async {
    try {
      final user = await _authManager.signInAnonymously(context);
      if (user != null) {
        final authUser = SupabaseConfig.auth.currentUser;
        if (authUser != null) {
          _currentUser = await _authManager.getCurrentUser();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('UserService signInAnonymously error: $e');
      return false;
    }
  }

  static Future<bool> convertAnonymousToEmail({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final success = await (_authManager as SupabaseAuthManager).convertAnonymousToEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      if (success) {
        _currentUser = await _authManager.getCurrentUser();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('UserService convertAnonymous error: $e');
      return false;
    }
  }

  static Future<void> signOut() async {
    try {
      await _authManager.signOut();
      _currentUser = null;
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  static Future<void> updateUser(User user) async {
    try {
      await SupabaseService.update(
        'users',
        {
          'name': user.name,
          'first_name': user.firstName,
          'last_name': user.lastName,
          'subscription_status': user.subscriptionStatus,
          'preferences': user.preferences,
          'duas_created': user.duasCreated,
          'days_since_joined': user.daysSinceJoined,
          'has_seen_inaugural_dua': user.hasSeenInauguralDua,
          'theme_preference': user.themePreference,
          'updated_at': DateTime.now().toIso8601String(),
        },
        filters: {'id': user.id},
      );
      _currentUser = user;
    } catch (e) {
      debugPrint('Error updating user: $e');
    }
  }

  static Future<bool> markProfileComplete() async {
    try {
      final authUser = SupabaseConfig.auth.currentUser;
      if (authUser == null) {
        debugPrint('Error marking profile complete: No authenticated user');
        return false;
      }

      await SupabaseService.update(
        'users',
        {
          'profile_completed': true,
          'updated_at': DateTime.now().toIso8601String(),
        },
        filters: {'id': authUser.id},
      );

      if (_currentUser != null) {
        _currentUser = await _authManager.getCurrentUser();
      }

      return true;
    } catch (e) {
      debugPrint('Error marking profile complete: $e');
      return false;
    }
  }

  static Future<User?> getUser(String userId) async {
    try {
      final userData = await SupabaseService.selectSingle(
        'users',
        filters: {'id': userId},
      );

      if (userData != null) {
        return User.fromJson({
          'id': userData['id'],
          'name': userData['name'],
          'email': userData['email'],
          'subscriptionStatus': userData['subscription_status'],
          'preferences': userData['preferences'] ?? {},
          'duasCreated': userData['duas_created'] ?? 0,
          'daysSinceJoined': userData['days_since_joined'] ?? 0,
          'createdAt': userData['created_at'],
          'updatedAt': userData['updated_at'],
        });
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  static String _getNameFromEmail(String email) {
    final namePart = email.split('@')[0];
    final words = namePart.split(RegExp(r'[._-]'));
    return words.map((word) => _capitalize(word)).join(' ');
  }
  
  static String _capitalize(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  // Last selected folder persistence (kept local for UI state)
  static Future<String?> getLastSelectedFolder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('last_selected_folder');
    } catch (_) {
      return null;
    }
  }

  static Future<void> setLastSelectedFolder(String? folderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (folderId == null) {
        await prefs.remove('last_selected_folder');
      } else {
        await prefs.setString('last_selected_folder', folderId);
      }
    } catch (_) {
      // no-op
    }
  }
}
