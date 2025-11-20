import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';

/// Remote data source for user profiles
class ProfileRemoteDataSource {
  ProfileRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Ensures a profile row exists for the authenticated user (by id only)
  Future<void> ensureCurrentProfile() async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated'); 
    }
    try {
      final existing =
          await _client
              .from('profiles')
              .select('id')
              .eq('id', userId)
              .maybeSingle();
      if (existing == null) {
        Logger.logDatabase('INSERT', 'profiles', data: {'id': userId});
        await _client.from('profiles').insert({'id': userId});
      }
    } on PostgrestException catch (e, st) {
      Logger.error(
        'PostgrestException ensuring profile: ${e.message}',
        tag: 'Database',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      Logger.error(
        'Unknown error ensuring profile',
        tag: 'Database',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
