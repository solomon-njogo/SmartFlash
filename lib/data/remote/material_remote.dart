import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course_material_model.dart';
import '../../core/utils/logger.dart';
import 'profile_remote.dart';

/// Remote data source for persisting course materials to Supabase
class MaterialRemoteDataSource {
  MaterialRemoteDataSource({SupabaseClient? client, String? bucketName})
      : _client = client ?? Supabase.instance.client,
        _bucketName = bucketName ?? 'materials';

  final SupabaseClient _client;
  final String _bucketName;

  /// Uploads the local file to Storage and inserts a row into public.materials
  /// Returns the inserted row (as a map) including the resolved public URL.
  Future<Map<String, dynamic>> uploadAndInsertMaterial(
    CourseMaterialModel material,
  ) async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    // Ensure profile exists to satisfy RLS foreign keys
    await ProfileRemoteDataSource(client: _client).ensureCurrentProfile();

    if (material.filePath == null || material.filePath!.isEmpty) {
      throw Exception('File path is required to upload material');
    }

    final String storagePath =
        'courses/${material.courseId}/${material.id}/${material.name}';

    try {
      Logger.info('Uploading material to storage: $storagePath', tag: 'Storage');
      final File file = File(material.filePath!);

      // Upload file to the bucket. By default this creates/overwrites.
      await _client.storage.from(_bucketName).upload(storagePath, file);

      // Get a public URL (assuming bucket is public). If private, generate a signed URL instead.
      final String fileUrl =
          _client.storage.from(_bucketName).getPublicUrl(storagePath);

      final Map<String, dynamic> row = {
        'id': material.id,
        'course_id': material.courseId,
        'name': material.name,
        'description': material.description,
        'file_type': material.fileType.name,
        'file_size_bytes': material.fileSizeBytes,
        'file_url': fileUrl,
        'uploaded_by': userId,
        'uploaded_at': material.uploadedAt.toIso8601String(),
        'updated_at': material.updatedAt.toIso8601String(),
        'tags': material.tags,
        'thumbnail_url': material.thumbnailUrl,
        'metadata': material.metadata,
        'download_count': material.downloadCount,
        'last_accessed_at': material.lastAccessedAt?.toIso8601String(),
      };

      Logger.logDatabase('INSERT', 'materials', data: row);
      final inserted = await _client.from('materials').insert(row).select().single();
      final Map<String, dynamic> insertedMap = Map<String, dynamic>.from(inserted);
      Logger.info('Inserted material ${material.id} into Supabase', tag: 'Database');

      // Return with ensured file_url
      return insertedMap..putIfAbsent('file_url', () => fileUrl);
    } on StorageException catch (e, st) {
      Logger.error('StorageException uploading material: ${e.message}', tag: 'Storage', error: e, stackTrace: st);
      rethrow;
    } on PostgrestException catch (e, st) {
      Logger.error('PostgrestException inserting material: ${e.message}', tag: 'Database', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      Logger.error('Unknown error uploading/inserting material', tag: 'Materials', error: e, stackTrace: st);
      rethrow;
    }
  }
}


