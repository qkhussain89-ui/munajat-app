import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Generic Supabase configuration template
/// Replace YOUR_ and YOUR_ with your actual values
class SupabaseConfig {
  static const String supabaseUrl = 'https://fmvujhprruwwkvhuxtfa.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZtdnVqaHBycnV3d2t2aHV4dGZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyMjM3NjAsImV4cCI6MjA4Mzc5OTc2MH0.YrY4o92Mj6D1fl5MB4E6fiXBOkTa1OtiMDLWlHlfKKI';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: anonKey,
      debug: kDebugMode,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
}

/// Generic database service for CRUD operations
class SupabaseService {
  /// Select multiple records from a table
  static Future<List<Map<String, dynamic>>> select(
    String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).select(select ?? '*');

      // Apply filters
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return await query;
    } catch (e) {
      throw _handleDatabaseError('select', table, e);
    }
  }

  /// Select a single record from a table
  static Future<Map<String, dynamic>?> selectSingle(
    String table, {
    String? select,
    required Map<String, dynamic> filters,
  }) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).select(select ?? '*');

      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      return await query.maybeSingle();
    } catch (e) {
      throw _handleDatabaseError('selectSingle', table, e);
    }
  }

  /// Insert a record into a table
  static Future<List<Map<String, dynamic>>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      return await SupabaseConfig.client.from(table).insert(data).select();
    } catch (e) {
      throw _handleDatabaseError('insert', table, e);
    }
  }

  /// Insert multiple records into a table
  static Future<List<Map<String, dynamic>>> insertMultiple(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    try {
      return await SupabaseConfig.client.from(table).insert(data).select();
    } catch (e) {
      throw _handleDatabaseError('insertMultiple', table, e);
    }
  }

  /// Update records in a table
  static Future<List<Map<String, dynamic>>> update(
    String table,
    Map<String, dynamic> data, {
    required Map<String, dynamic> filters,
  }) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).update(data);

      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      final result = await query.select();
      
      // Validate that update affected at least 1 row
      if (result.isEmpty) {
        throw Exception(
          'Update failed: 0 rows affected. '
          'Possible causes: Row not found, RLS policy blocking update, or permission denied.'
        );
      }
      
      return result;
    } catch (e) {
      throw _handleDatabaseError('update', table, e);
    }
  }

  /// Delete records from a table
  static Future<void> delete(
    String table, {
    required Map<String, dynamic> filters,
  }) async {
    try {
      dynamic query = SupabaseConfig.client.from(table).delete();

      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      await query;
    } catch (e) {
      throw _handleDatabaseError('delete', table, e);
    }
  }

  /// Get direct table reference for complex queries
  static SupabaseQueryBuilder from(String table) =>
      SupabaseConfig.client.from(table);

  /// Invoke a Supabase Edge Function
  /// Minimal hardening:
  /// - require a valid session (auth-required endpoint)
  /// - explicitly send Authorization Bearer token + apikey
  /// - clearer errors including request_id if returned
  static Future<Map<String, dynamic>> invokeFunction(
    String functionName,
    Map<String, dynamic> payload,
  ) async {
    try {
      // Try to get the current session, refreshing if expired
      var session = SupabaseConfig.auth.currentSession;
      final currentUser = SupabaseConfig.auth.currentUser;

      if (kDebugMode) {
        debugPrint('=== INVOKE FUNCTION DEBUG ===');
        debugPrint('Function: $functionName');
        debugPrint('currentUser: ${currentUser?.id ?? "NULL"}');
        debugPrint('currentUser email: ${currentUser?.email ?? "NULL"}');
        debugPrint('currentSession: ${session != null ? "EXISTS" : "NULL"}');
        if (session != null) {
          debugPrint('accessToken empty: ${session.accessToken.isEmpty}');
          debugPrint('accessToken first 20 chars: ${session.accessToken.substring(0, session.accessToken.length > 20 ? 20 : session.accessToken.length)}');
          debugPrint('expiresAt: ${session.expiresAt}');
        }
      }

      // If session is null or token looks expired, attempt a refresh
      if (session == null || session.accessToken.isEmpty) {
        if (kDebugMode) debugPrint('Attempting session refresh...');
        try {
          final refreshResponse = await SupabaseConfig.auth.refreshSession();
          session = refreshResponse.session;
          if (kDebugMode) debugPrint('Session refresh result: ${session != null ? "SUCCESS" : "STILL NULL"}');
        } catch (e) {
          if (kDebugMode) debugPrint('Session refresh failed: $e');
        }
      }

      // If still no valid session after refresh attempt, throw
      if (session == null || session.accessToken.isEmpty) {
        if (kDebugMode) debugPrint('=== SESSION FAILURE — THROWING 401 ===');
        throw Exception(
          'Not authenticated: no active session found. Please log in again and retry.',
        );
      }

      if (kDebugMode) debugPrint('=== SESSION OK — Proceeding with edge function call ===');

      final uri = Uri.parse('${SupabaseConfig.supabaseUrl}/functions/v1/$functionName');
      final httpResponse = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.accessToken}',
          'apikey': SupabaseConfig.anonKey,
        },
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        debugPrint('=== HTTP RESPONSE ===');
        debugPrint('Status: ${httpResponse.statusCode}');
        debugPrint('Body: ${httpResponse.body}');
      }

      if (httpResponse.statusCode != 200) {
        final data = jsonDecode(httpResponse.body);
        final requestId = data is Map ? data['request_id'] : null;
        final errorCode = data is Map ? data['error'] : null;

        throw Exception(
          'Edge function $functionName failed with status ${httpResponse.statusCode}'
          '${errorCode != null ? ' (error: $errorCode)' : ''}'
          '${requestId != null ? ' (request_id: $requestId)' : ''}',
        );
      }

      final data = jsonDecode(httpResponse.body);

      if (data is! Map) {
        throw Exception(
          'Edge function $functionName returned invalid response format',
        );
      }

      return Map<String, dynamic>.from(data);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
        'Failed to invoke edge function $functionName: ${e.toString()}',
      );
    }
  }

  /// Handle database errors
  static String _handleDatabaseError(
    String operation,
    String table,
    dynamic error,
  ) {
    if (error is PostgrestException) {
      return 'Failed to $operation from $table: ${error.message}';
    } else {
      return 'Failed to $operation from $table: ${error.toString()}';
    }
  }
}