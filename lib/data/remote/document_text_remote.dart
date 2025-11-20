import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/document_text_model.dart';
import '../../core/utils/logger.dart';

/// Remote data source for document text storage
class DocumentTextRemoteDataSource {
  DocumentTextRemoteDataSource({SupabaseClient? client, String? tableName})
    : _client = client ?? Supabase.instance.client,
      _tableName = tableName ?? 'document_texts';

  final SupabaseClient _client;
  final String _tableName;

  /// Store parsed document text
  Future<DocumentTextModel> storeDocumentText({
    required String materialId,
    required String extractedText,
    required int wordCount,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      Logger.info(
        'Storing document text for material: $materialId',
        tag: 'DocumentText',
      );

      final textLength = extractedText.length;
      final now = DateTime.now();

      final row = {
        'material_id': materialId,
        'extracted_text': extractedText,
        'text_length': textLength,
        'word_count': wordCount,
        'parsing_status': ParsingStatus.completed.name,
        'parsed_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'metadata': metadata,
      };

      Logger.logDatabase('INSERT', _tableName, data: row);
      final response =
          await _client.from(_tableName).insert(row).select().single();

      Logger.info(
        'Document text stored successfully for material: $materialId',
        tag: 'DocumentText',
      );

      return DocumentTextModel.fromJson(response);
    } on PostgrestException catch (e, st) {
      Logger.error(
        'PostgrestException storing document text: ${e.message}',
        tag: 'DocumentText',
        error: e,
        stackTrace: st,
      );
      throw Exception('Database error: ${e.message}');
    } catch (e, st) {
      Logger.error(
        'Error storing document text: $e',
        tag: 'DocumentText',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Get document text by material ID
  Future<DocumentTextModel?> getDocumentTextByMaterialId(
    String materialId,
  ) async {
    try {
      Logger.logDatabase(
        'SELECT',
        _tableName,
        data: {'material_id': materialId},
      );
      final response =
          await _client
              .from(_tableName)
              .select()
              .eq('material_id', materialId)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return DocumentTextModel.fromJson(response);
    } on PostgrestException catch (e, st) {
      Logger.error(
        'PostgrestException fetching document text: ${e.message}',
        tag: 'DocumentText',
        error: e,
        stackTrace: st,
      );
      throw Exception('Database error: ${e.message}');
    } catch (e, st) {
      Logger.error(
        'Error fetching document text: $e',
        tag: 'DocumentText',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Update parsing status
  Future<void> updateParsingStatus({
    required String materialId,
    required ParsingStatus status,
    String? errorMessage,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'parsing_status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (status == ParsingStatus.completed) {
        updateData['parsed_at'] = DateTime.now().toIso8601String();
      }

      if (errorMessage != null) {
        updateData['metadata'] = {'error': errorMessage};
      }

      Logger.logDatabase('UPDATE', _tableName, data: updateData);
      await _client
          .from(_tableName)
          .update(updateData)
          .eq('material_id', materialId);

      Logger.info(
        'Updated parsing status for material $materialId: ${status.name}',
        tag: 'DocumentText',
      );
    } on PostgrestException catch (e, st) {
      Logger.error(
        'PostgrestException updating parsing status: ${e.message}',
        tag: 'DocumentText',
        error: e,
        stackTrace: st,
      );
      throw Exception('Database error: ${e.message}');
    } catch (e, st) {
      Logger.error(
        'Error updating parsing status: $e',
        tag: 'DocumentText',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  // Edge function trigger removed - text extraction now happens client-side
}
