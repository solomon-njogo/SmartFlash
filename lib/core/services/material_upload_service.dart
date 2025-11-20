import 'dart:typed_data';
import '../../data/models/course_material_model.dart';
import '../../data/remote/material_remote.dart';
import '../../data/remote/document_text_remote.dart';
import '../services/file_validation_service.dart';
import '../services/text_extraction_service.dart';
import '../utils/logger.dart';

/// Result of material upload operation
class UploadResult {
  final bool success;
  final String? materialId;
  final String? extractedTextId;
  final String? error;

  UploadResult({
    required this.success,
    this.materialId,
    this.extractedTextId,
    this.error,
  });

  factory UploadResult.success({
    required String materialId,
    String? extractedTextId,
  }) {
    return UploadResult(
      success: true,
      materialId: materialId,
      extractedTextId: extractedTextId,
    );
  }

  factory UploadResult.failure(String error) {
    return UploadResult(
      success: false,
      error: error,
    );
  }
}

/// Service for orchestrating the complete material upload flow
class MaterialUploadService {
  final MaterialRemoteDataSource _materialRemote;
  final DocumentTextRemoteDataSource _documentTextRemote;
  final FileValidationService _validationService;
  final TextExtractionService _extractionService;

  MaterialUploadService({
    MaterialRemoteDataSource? materialRemote,
    DocumentTextRemoteDataSource? documentTextRemote,
    FileValidationService? validationService,
    TextExtractionService? extractionService,
  })  : _materialRemote = materialRemote ?? MaterialRemoteDataSource(),
        _documentTextRemote =
            documentTextRemote ?? DocumentTextRemoteDataSource(),
        _validationService =
            validationService ?? FileValidationService.instance,
        _extractionService =
            extractionService ?? TextExtractionService.instance;

  /// Upload a material with text extraction
  /// Flow: Validate -> Upload to Storage -> Store Metadata -> Extract Text -> Store Text
  Future<UploadResult> uploadMaterial({
    required CourseMaterialModel material,
    Uint8List? fileBytes,
    Function(double)? onProgress,
  }) async {
    try {
      Logger.info(
        'Starting material upload for: ${material.name}',
        tag: 'MaterialUpload',
      );

      // Step 1: Validate file
      final validationResult = _validationService.validateFile(
        fileName: material.name,
        fileSizeBytes: material.fileSizeBytes,
      );

      if (!validationResult.isValid) {
        Logger.error(
          'File validation failed: ${validationResult.error}',
          tag: 'MaterialUpload',
        );
        return UploadResult.failure(validationResult.error ?? 'Validation failed');
      }

      // Step 2: Upload file to cloud storage and store metadata
      // Report progress: 0-70% for upload
      try {
        Logger.info(
          'Uploading file to storage: ${material.name}',
          tag: 'MaterialUpload',
        );

        final inserted = await _materialRemote.uploadAndInsertMaterial(
          material,
          fileBytes: fileBytes,
          onProgress: (progress) {
            // Map upload progress to 0-70% of total
            onProgress?.call(progress * 0.7);
          },
        );

        final materialId = inserted['id'] as String? ?? material.id;

        Logger.info(
          'File uploaded successfully. Material ID: $materialId',
          tag: 'MaterialUpload',
        );

        // Step 3: Extract text (only for PDF, TXT, DOCX)
        // Report progress: 70-90% for extraction
        String? extractedTextId;
        if (_shouldExtractText(material.fileType)) {
          try {
            Logger.info(
              'Starting text extraction for: ${material.name}',
              tag: 'MaterialUpload',
            );

            onProgress?.call(0.7);

            final extractionResult = await _extractionService.extractText(
              fileType: material.fileType,
              filePath: material.filePath,
              fileBytes: fileBytes,
              fileName: material.name,
            );

            onProgress?.call(0.9);

            if (extractionResult.success && extractionResult.extractedText.isNotEmpty) {
              // Step 4: Store extracted text in database
              try {
                Logger.info(
                  'Storing extracted text. Characters: ${extractionResult.characterCount}, Words: ${extractionResult.wordCount}',
                  tag: 'MaterialUpload',
                );

                final documentText = await _documentTextRemote.storeDocumentText(
                  materialId: materialId,
                  extractedText: extractionResult.extractedText,
                  wordCount: extractionResult.wordCount,
                  metadata: {
                    'extraction_method': extractionResult.extractionMethod,
                    'character_count': extractionResult.characterCount,
                    'word_count': extractionResult.wordCount,
                  },
                );

                extractedTextId = documentText.id;
                Logger.info(
                  'Extracted text stored successfully. Document Text ID: $extractedTextId',
                  tag: 'MaterialUpload',
                );
              } catch (e, stackTrace) {
                // Log warning but don't fail the entire operation
                Logger.warning(
                  'Failed to store extracted text: $e',
                  tag: 'MaterialUpload',
                  error: e,
                  stackTrace: stackTrace,
                );
              }
            } else {
              Logger.warning(
                'Text extraction failed or returned empty text: ${extractionResult.error}',
                tag: 'MaterialUpload',
              );
            }
          } catch (e, stackTrace) {
            // Log warning but don't fail the entire operation
            Logger.warning(
              'Text extraction error (non-fatal): $e',
              tag: 'MaterialUpload',
              error: e,
              stackTrace: stackTrace,
            );
          }
        }

        // Report completion
        onProgress?.call(1.0);

        Logger.info(
          'Material upload completed successfully. Material ID: $materialId',
          tag: 'MaterialUpload',
        );

        return UploadResult.success(
          materialId: materialId,
          extractedTextId: extractedTextId,
        );
      } catch (e, stackTrace) {
        Logger.error(
          'Error uploading file to storage: $e',
          tag: 'MaterialUpload',
          error: e,
          stackTrace: stackTrace,
        );
        return UploadResult.failure('Failed to upload file: $e');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error during material upload: $e',
        tag: 'MaterialUpload',
        error: e,
        stackTrace: stackTrace,
      );
      return UploadResult.failure('Upload failed: $e');
    }
  }

  /// Check if text extraction should be performed for this file type
  bool _shouldExtractText(FileType fileType) {
    return fileType == FileType.pdf ||
        fileType == FileType.text ||
        fileType == FileType.docx;
  }
}

