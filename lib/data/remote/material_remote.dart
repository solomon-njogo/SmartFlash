import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course_material_model.dart';
import '../../core/utils/logger.dart';
import 'profile_remote.dart';

/// Remote data source for persisting course materials to Supabase
class MaterialRemoteDataSource {
  MaterialRemoteDataSource({
    SupabaseClient? client,
    String? bucketName,
    String? tableName,
  }) : _client = client ?? Supabase.instance.client,
       _bucketName = bucketName ?? 'materials',
       _tableName = tableName ?? 'course_materials';

  final SupabaseClient _client;
  final String _bucketName;
  final String _tableName;

  /// Uploads the local file to Storage and inserts a row into public.materials
  /// Returns the inserted row (as a map) including the resolved public URL.
  /// Supports both file path (mobile/desktop) and bytes (web).
  Future<Map<String, dynamic>> uploadAndInsertMaterial(
    CourseMaterialModel material, {
    Uint8List? fileBytes,
    Function(double)? onProgress,
  }) async {
    Logger.info(
      '=== Starting storage upload and database insert ===',
      tag: 'Storage',
    );
    
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      Logger.error('Not authenticated - cannot upload material', tag: 'Storage');
      throw Exception('Not authenticated');
    }

    Logger.debug('Authenticated user ID: $userId', tag: 'Storage');

    // Ensure profile exists to satisfy RLS foreign keys
    Logger.debug('Ensuring profile exists for RLS foreign keys...', tag: 'Storage');
    await ProfileRemoteDataSource(client: _client).ensureCurrentProfile();
    Logger.debug('Profile check completed', tag: 'Storage');

    final String storagePath =
        'courses/${material.courseId}/${material.id}/${material.name}';

    Logger.info(
      'Storage path: $storagePath, Bucket: $_bucketName',
      tag: 'Storage',
    );

    try {
      Logger.info(
        'Uploading file to storage bucket: $_bucketName',
        tag: 'Storage',
      );
      final storageUploadStartTime = DateTime.now();

      // Handle file upload - support both path (mobile/desktop) and bytes (web)
      if (fileBytes != null) {
        // Web platform - upload from bytes
        Logger.info(
          'Uploading from bytes (web platform) - Size: ${fileBytes.length} bytes',
          tag: 'Storage',
        );
        await _client.storage
            .from(_bucketName)
            .uploadBinary(
              storagePath,
              fileBytes,
              fileOptions: const FileOptions(upsert: true),
            );
        Logger.info(
          'File bytes uploaded successfully to storage',
          tag: 'Storage',
        );
      } else if (material.filePath != null && material.filePath!.isNotEmpty) {
        // Mobile/Desktop platform - upload from file path
        Logger.info(
          'Uploading from file path (mobile/desktop platform) - Path: ${material.filePath}',
          tag: 'Storage',
        );
        final File file = File(material.filePath!);
        if (!await file.exists()) {
          Logger.error(
            'File does not exist at path: ${material.filePath}',
            tag: 'Storage',
          );
          throw Exception('File does not exist at path: ${material.filePath}');
        }
        final fileSize = await file.length();
        Logger.debug(
          'File exists, size: $fileSize bytes',
          tag: 'Storage',
        );
        await _client.storage
            .from(_bucketName)
            .upload(
              storagePath,
              file,
              fileOptions: const FileOptions(upsert: true),
            );
        Logger.info(
          'File uploaded successfully to storage from path',
          tag: 'Storage',
        );
      } else {
        Logger.error(
          'Neither file path nor file bytes provided - cannot upload',
          tag: 'Storage',
        );
        throw Exception('Either file path or file bytes must be provided');
      }
      
      final storageUploadDuration = DateTime.now().difference(storageUploadStartTime);
      Logger.info(
        'Storage upload completed in ${storageUploadDuration.inMilliseconds}ms',
        tag: 'Storage',
      );

      // Get a public URL (assuming bucket is public). If private, generate a signed URL instead.
      Logger.debug('Generating public URL for uploaded file...', tag: 'Storage');
      final String fileUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(storagePath);
      Logger.info(
        'Generated file URL: $fileUrl',
        tag: 'Storage',
      );

      Logger.info(
        'Preparing database insert for material metadata...',
        tag: 'Database',
      );
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

      Logger.debug(
        'Database row data - ID: ${row['id']}, Course: ${row['course_id']}, Name: ${row['name']}, Type: ${row['file_type']}, Size: ${row['file_size_bytes']} bytes',
        tag: 'Database',
      );
      Logger.logDatabase('INSERT', _tableName, data: row);
      
      final dbInsertStartTime = DateTime.now();
      final inserted =
          await _client.from(_tableName).insert(row).select().single();
      final dbInsertDuration = DateTime.now().difference(dbInsertStartTime);
      
      final Map<String, dynamic> insertedMap = Map<String, dynamic>.from(
        inserted,
      );
      Logger.info(
        'Material inserted into database in ${dbInsertDuration.inMilliseconds}ms',
        tag: 'Database',
      );
      Logger.info(
        'Inserted material record - ID: ${insertedMap['id']}, Table: $_tableName',
        tag: 'Database',
      );

      // Text extraction is now handled client-side via MaterialUploadService
      // No edge function trigger needed

      // Return with ensured file_url
      final result = insertedMap..putIfAbsent('file_url', () => fileUrl);
      Logger.info(
        '=== Storage upload and database insert completed successfully ===',
        tag: 'Storage',
      );
      return result;
    } on StorageException catch (e, st) {
      Logger.error(
        'StorageException uploading material: ${e.message}',
        tag: 'Storage',
        error: e,
        stackTrace: st,
      );
      Logger.error(
        'Storage error details - Code: ${e.statusCode}, Message: ${e.message}',
        tag: 'Storage',
      );
      throw Exception('Storage error: ${e.message}');
    } on PostgrestException catch (e, st) {
      Logger.error(
        'PostgrestException inserting material: ${e.message}',
        tag: 'Database',
        error: e,
        stackTrace: st,
      );
      Logger.error(
        'Database error details - Code: ${e.code}, Message: ${e.message}, Details: ${e.details}',
        tag: 'Database',
      );
      throw Exception('Database error: ${e.message}');
    } catch (e, st) {
      Logger.error(
        'Unknown error uploading/inserting material: $e',
        tag: 'Materials',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Downloads a material file from storage
  Future<Uint8List> downloadMaterial(String fileUrl) async {
    try {
      Logger.info('Downloading material from: $fileUrl', tag: 'Storage');
      final response = await _client.storage
          .from(_bucketName)
          .download(_extractStoragePath(fileUrl));
      Logger.info('Downloaded material successfully', tag: 'Storage');
      return response;
    } on StorageException catch (e, st) {
      Logger.error(
        'StorageException downloading material: ${e.message}',
        tag: 'Storage',
        error: e,
        stackTrace: st,
      );
      throw Exception('Failed to download file: ${e.message}');
    } catch (e, st) {
      Logger.error(
        'Unknown error downloading material: $e',
        tag: 'Materials',
        error: e,
        stackTrace: st,
      );
      throw Exception('Failed to download file: $e');
    }
  }

  /// Deletes a material from both storage and database
  Future<void> deleteMaterial(String materialId, String? fileUrl) async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    try {
      // Delete from storage if file URL exists
      if (fileUrl != null && fileUrl.isNotEmpty) {
        try {
          final storagePath = _extractStoragePath(fileUrl);
          Logger.info(
            'Deleting material from storage: $storagePath',
            tag: 'Storage',
          );
          await _client.storage.from(_bucketName).remove([storagePath]);
          Logger.info('Deleted material from storage', tag: 'Storage');
        } catch (e) {
          Logger.warning(
            'Failed to delete from storage (may not exist): $e',
            tag: 'Storage',
          );
          // Continue with database deletion even if storage deletion fails
        }
      }

      // Delete from database
      Logger.logDatabase('DELETE', _tableName, data: {'id': materialId});
      await _client
          .from(_tableName)
          .delete()
          .eq('id', materialId)
          .eq('uploaded_by', userId);
      Logger.info(
        'Deleted material $materialId from database',
        tag: 'Database',
      );
    } on PostgrestException catch (e, st) {
      Logger.error(
        'PostgrestException deleting material: ${e.message}',
        tag: 'Database',
        error: e,
        stackTrace: st,
      );
      throw Exception('Database error: ${e.message}');
    } catch (e, st) {
      Logger.error(
        'Unknown error deleting material: $e',
        tag: 'Materials',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Fetches all materials for a specific course
  Future<List<Map<String, dynamic>>> fetchMaterialsByCourseId(
    String courseId,
  ) async {
    try {
      Logger.logDatabase('SELECT', _tableName, data: {'course_id': courseId});
      final response = await _client
          .from(_tableName)
          .select()
          .eq('course_id', courseId)
          .order('uploaded_at', ascending: false);

      final List<Map<String, dynamic>> materials =
          (response as List).map((e) => Map<String, dynamic>.from(e)).toList();
      Logger.info(
        'Fetched ${materials.length} materials for course $courseId',
        tag: 'Database',
      );
      return materials;
    } on PostgrestException catch (e, st) {
      Logger.error(
        'PostgrestException fetching materials: ${e.message}',
        tag: 'Database',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      Logger.error(
        'Unknown error fetching materials: $e',
        tag: 'Materials',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Fetches all materials for all courses
  Future<List<Map<String, dynamic>>> fetchAllMaterials() async {
    try {
      Logger.logDatabase('SELECT', _tableName, data: {'all': true});
      final response = await _client
          .from(_tableName)
          .select()
          .order('uploaded_at', ascending: false);

      final List<Map<String, dynamic>> materials =
          (response as List).map((e) => Map<String, dynamic>.from(e)).toList();
      Logger.info(
        'Fetched ${materials.length} materials for all courses',
        tag: 'Database',
      );
      return materials;
    } on PostgrestException catch (e, st) {
      Logger.error(
        'PostgrestException fetching all materials: ${e.message}',
        tag: 'Database',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      Logger.error(
        'Unknown error fetching all materials: $e',
        tag: 'Materials',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Extracts storage path from a public URL
  String _extractStoragePath(String fileUrl) {
    // Extract path from URL like: https://xxx.supabase.co/storage/v1/object/public/materials/courses/...
    final uri = Uri.parse(fileUrl);
    final pathSegments = uri.pathSegments;
    final materialsIndex = pathSegments.indexOf(_bucketName);
    if (materialsIndex != -1 && materialsIndex < pathSegments.length - 1) {
      return pathSegments.sublist(materialsIndex + 1).join('/');
    }
    // Fallback: try to extract from the full path
    return fileUrl.split('/$_bucketName/').last.split('?').first;
  }
}
