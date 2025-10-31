import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course_model.dart';
import '../../core/utils/logger.dart';
import 'profile_remote.dart';

/// Remote data source for persisting courses in Supabase
class CourseRemoteDataSource {
  CourseRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Inserts a course row into public.courses according to the backend schema.
  /// Uses the authenticated user's id for created_by to satisfy RLS.
  Future<void> insertCourse(CourseModel course) async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    // Ensure foreign key: a profile row must exist for the current user
    await ProfileRemoteDataSource(client: _client).ensureCurrentProfile();

    final Map<String, dynamic> row = {
      'id': course.id,
      'name': course.name,
      'description': course.description,
      'cover_image_url': course.coverImageUrl,
      'icon_name': course.iconName,
      'color_value': course.colorValue,
      'deck_ids': course.deckIds,
      'quiz_ids': course.quizIds,
      'material_ids': course.materialIds,
      'created_by': userId,
      'tags': course.tags,
      'category': course.category,
      'subject': course.subject,
      'total_decks': course.totalDecks,
      'total_quizzes': course.totalQuizzes,
      'total_materials': course.totalMaterials,
      'last_accessed_at': course.lastAccessedAt?.toIso8601String(),
      'metadata': course.metadata,
    };

    Logger.logDatabase('INSERT', 'courses', data: row);
    try {
      await _client.from('courses').insert(row).select().single();
      Logger.info('Inserted course ${course.id} into Supabase', tag: 'Database');
    } on PostgrestException catch (e, st) {
      Logger.error(
        'PostgrestException inserting course: ${e.message}',
        tag: 'Database',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      Logger.error('Unknown error inserting course', tag: 'Database', error: e, stackTrace: st);
      rethrow;
    }
  }
}


