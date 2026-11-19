import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hearth_prayer/auth/auth_manager.dart';
import 'package:hearth_prayer/models/user.dart';
import 'package:hearth_prayer/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class SupabaseAuthManager extends AuthManager with EmailSignInManager, AnonymousSignInManager {
  @override
  Future<User?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final response = await SupabaseConfig.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Failed to sign in');
      }

      // Fetch or create user profile
      return await _fetchOrCreateUserProfile(response.user!);
    } on supabase.AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Sign in error: $e');
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<User?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password, {
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await SupabaseConfig.auth.signUp(
        email: email,
        password: password,
        data: {
          if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
          if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
          if (firstName != null && lastName != null) 'name': '$firstName $lastName',
        },
      );

      if (response.user == null) {
        throw Exception('Failed to create account');
      }

      // User profile is automatically created by database trigger
      // Fetch the created profile
      return await _fetchOrCreateUserProfile(response.user!);
    } on supabase.AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Sign up error: $e');
      throw Exception('Failed to create account: $e');
    }
  }

  @override
  Future signOut() async {
    try {
      await SupabaseConfig.auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<User?> signInAnonymously(BuildContext context) async {
    try {
      final response = await SupabaseConfig.auth.signInAnonymously();
      if (response.user != null) {
        debugPrint('Anonymous sign-in successful: ${response.user!.id}');
        return await _fetchOrCreateUserProfile(response.user!);
      }
      return null;
    } catch (e) {
      debugPrint('Anonymous sign-in error: $e');
      return null;
    }
  }

  /// Convert an anonymous Supabase user to a real email-authenticated user.
  Future<bool> convertAnonymousToEmail({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final updateResponse = await SupabaseConfig.auth.updateUser(
        supabase.UserAttributes(
          email: email,
          password: password,
          data: {
            if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
            if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
            if (firstName != null && lastName != null) 'name': '$firstName $lastName',
          },
        ),
      );

      if (updateResponse.user != null) {
        debugPrint('Anonymous user converted to email: ${updateResponse.user!.email}');
        // Update the users table with the real name and email
        await SupabaseService.update('users', {
          'email': email,
          'name': '$firstName $lastName',
          'first_name': firstName ?? '',
          'last_name': lastName ?? '',
          'updated_at': DateTime.now().toIso8601String(),
        }, filters: {'id': updateResponse.user!.id});
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Convert anonymous error: $e');
      return false;
    }
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      final user = SupabaseConfig.auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      // Delete user profile (cascade will handle related data)
      await SupabaseService.delete('users', filters: {'id': user.id});
      
      // Sign out
      await signOut();
    } catch (e) {
      debugPrint('Delete user error: $e');
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await SupabaseConfig.auth.updateUser(
        supabase.UserAttributes(email: email),
      );

      // Update user profile
      final user = SupabaseConfig.auth.currentUser;
      if (user != null) {
        await SupabaseService.update(
          'users',
          {'email': email, 'updated_at': DateTime.now().toIso8601String()},
          filters: {'id': user.id},
        );
      }
    } on supabase.AuthException catch (e) {
      debugPrint('Update email error: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Update email error: $e');
      throw Exception('Failed to update email: $e');
    }
  }

  @override
  Future resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await SupabaseConfig.auth.resetPasswordForEmail(email);
    } on supabase.AuthException catch (e) {
      debugPrint('Reset password error: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Reset password error: $e');
      throw Exception('Failed to reset password: $e');
    }
  }

  /// Fetches user profile from database or creates if missing
  Future<User?> _fetchOrCreateUserProfile(supabase.User authUser) async {
    try {
      final userData = await SupabaseService.selectSingle(
        'users',
        filters: {'id': authUser.id},
      );

      if (userData != null) {
        return User.fromJson({
          'id': userData['id'],
          'name': userData['name'],
          'first_name': userData['first_name'],
          'last_name': userData['last_name'],
          'email': userData['email'],
          'subscriptionStatus': userData['subscription_status'],
          'preferences': userData['preferences'] ?? {},
          'duasCreated': userData['duas_created'] ?? 0,
          'daysSinceJoined': userData['days_since_joined'] ?? 0,
          'createdAt': userData['created_at'],
          'updatedAt': userData['updated_at'],
          'dateOfBirth': userData['date_of_birth'],
          'gender': userData['gender'],
          'location': userData['location'],
          'profileCompleted': userData['profile_completed'],
          'has_seen_inaugural_dua': userData['has_seen_inaugural_dua'],
        });
      }

      // Create profile if it doesn't exist
      final firstName = authUser.userMetadata?['first_name'] as String?;
      final lastName = authUser.userMetadata?['last_name'] as String?;
      final fullName = (firstName != null && lastName != null)
          ? '$firstName $lastName'
          : (authUser.userMetadata?['name'] as String? ?? _getNameFromEmail(authUser.email ?? ''));
      final now = DateTime.now();
      
      final newUserData = {
        'id': authUser.id,
        'name': fullName,
        'first_name': firstName,
        'last_name': lastName,
        'email': authUser.email ?? '',
        'subscription_status': 'trial',
        'preferences': <String, dynamic>{},
        'duas_created': 0,
        'days_since_joined': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await SupabaseService.insert('users', newUserData);

      return User.fromJson({
        'id': authUser.id,
        'name': fullName,
        'first_name': firstName,
        'last_name': lastName,
        'email': authUser.email ?? '',
        'subscriptionStatus': 'trial',
        'preferences': <String, dynamic>{},
        'duasCreated': 0,
        'daysSinceJoined': 0,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'dateOfBirth': null,
        'gender': null,
        'location': null,
        'profileCompleted': false,
      });
    } catch (e) {
      debugPrint('Fetch or create user profile error: $e');
      return null;
    }
  }

  String _getNameFromEmail(String email) {
    final namePart = email.split('@')[0];
    final words = namePart.split(RegExp(r'[._-]'));
    return words.map((word) => _capitalize(word)).join(' ');
  }

  String _capitalize(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  /// Get current authenticated user from database
  Future<User?> getCurrentUser() async {
    final authUser = SupabaseConfig.auth.currentUser;
    if (authUser == null) return null;
    
    return await _fetchOrCreateUserProfile(authUser);
  }
}
