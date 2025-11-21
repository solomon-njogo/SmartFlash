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
      Logger.info(
        'Inserted course ${course.id} into Supabase',
        tag: 'Database',
      );
    } on PostgrestException catch (e, st) {
      Logger.error(
        'PostgrestException inserting course: ${e.message}',
        tag: 'Database',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      Logger.error(
        'Unknown error inserting course',
        tag: 'Database',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Fetch all courses visible to the current authenticated user.
  /// Returns an empty list if none are found.
  Future<List<CourseModel>> fetchCourses() async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      Logger.warning('User not authenticated, returning empty course list');
      return [];
    }

    try {
      final response =
          await _client
                  .from('courses')
                  .select()
                  .eq('created_by', userId)
                  .order('created_at', ascending: false)
              as List<dynamic>?;

      if (response == null) return [];

      final List<CourseModel> courses =
          response
              .map(
                (raw) =>
                    _mapRowToCourseModel(Map<String, dynamic>.from(raw as Map)),
              )
              .toList();

      Logger.logDatabase('SELECT', 'courses', data: {'count': courses.length, 'user_id': userId});
      return courses;
    } on PostgrestException catch (e, st) {
      Logger.error(
        'PostgrestException fetching courses: ${e.message}',
        tag: 'Database',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      Logger.error(
        'Unknown error fetching courses',
        tag: 'Database',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Update an existing course row and return the updated model
  Future<CourseModel> updateCourse(CourseModel course) async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final Map<String, dynamic> updates = {
      'name': course.name,
      'description': course.description,
      'cover_image_url': course.coverImageUrl,
      'icon_name': course.iconName,
      'color_value': course.colorValue,
      'deck_ids': course.deckIds,
      'quiz_ids': course.quizIds,
      'material_ids': course.materialIds,
      'tags': course.tags,
      'category': course.category,
      'subject': course.subject,
      'total_decks': course.totalDecks,
      'total_quizzes': course.totalQuizzes,
      'total_materials': course.totalMaterials,
      'last_accessed_at': course.lastAccessedAt?.toIso8601String(),
      'metadata': course.metadata,
      'updated_at': course.updatedAt.toIso8601String(),
    };

    Logger.logDatabase('UPDATE', 'courses', data: {'id': course.id});
    try {
      final response =
          await _client
              .from('courses')
              .update(updates)
              .eq('id', course.id)
              .eq('created_by', userId)
              .select()
              .single();

      return _mapRowToCourseModel(Map<String, dynamic>.from(response as Map));
    } on PostgrestException catch (e, st) {
      Logger.error(
        'PostgrestException updating course: ${e.message}',
        tag: 'Database',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      Logger.error(
        'Unknown error updating course',
        tag: 'Database',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Delete a course row
  Future<void> deleteCourse(String courseId) async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    Logger.logDatabase('DELETE', 'courses', data: {'id': courseId});
    try {
      await _client
          .from('courses')
          .delete()
          .eq('id', courseId)
          .eq('created_by', userId);
    } on PostgrestException catch (e, st) {
      Logger.error(
        'PostgrestException deleting course: ${e.message}',
        tag: 'Database',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      Logger.error(
        'Unknown error deleting course',
        tag: 'Database',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  CourseModel _mapRowToCourseModel(Map<String, dynamic> row) {
    final Map<String, dynamic> json = {
      'id': row['id'],
      'name': row['name'],
      'description': row['description'],
      'coverImageUrl': row['cover_image_url'] ?? row['coverImageUrl'],
      'iconName': row['icon_name'] ?? row['iconName'],
      'colorValue': row['color_value'] ?? row['colorValue'] ?? 0xFF2196F3,
      'deckIds':
          (row['deck_ids'] ?? row['deckIds'] ?? []) is List
              ? List<String>.from(row['deck_ids'] ?? row['deckIds'] ?? [])
              : <String>[],
      'quizIds':
          (row['quiz_ids'] ?? row['quizIds'] ?? []) is List
              ? List<String>.from(row['quiz_ids'] ?? row['quizIds'] ?? [])
              : <String>[],
      'materialIds':
          (row['material_ids'] ?? row['materialIds'] ?? []) is List
              ? List<String>.from(
                row['material_ids'] ?? row['materialIds'] ?? [],
              )
              : <String>[],
      'createdBy': row['created_by'] ?? row['createdBy'] ?? '',
      'createdAt': (row['created_at'] ?? row['createdAt'])?.toString(),
      'updatedAt': (row['updated_at'] ?? row['updatedAt'])?.toString(),
      'tags':
          (row['tags'] ?? row['tags'] ?? []) is List
              ? List<String>.from(row['tags'] ?? [])
              : <String>[],
      'category': row['category'],
      'subject': row['subject'],
      'totalDecks': row['total_decks'] ?? row['totalDecks'] ?? 0,
      'totalQuizzes': row['total_quizzes'] ?? row['totalQuizzes'] ?? 0,
      'totalMaterials': row['total_materials'] ?? row['totalMaterials'] ?? 0,
      'lastAccessedAt':
          (row['last_accessed_at'] ?? row['lastAccessedAt'])?.toString(),
      'metadata': row['metadata'],
    };

    return CourseModel.fromJson(json);
  }
}
