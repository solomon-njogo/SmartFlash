import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    final uploadStartTime = DateTime.now();
    try {
      Logger.info(
        '=== Starting material upload process ===',
        tag: 'MaterialUpload',
      );
      Logger.info(
        'Material details - Name: ${material.name}, ID: ${material.id}, Type: ${material.fileType.name}, Size: ${material.fileSizeBytes} bytes, Course: ${material.courseId}',
        tag: 'MaterialUpload',
      );
      Logger.debug(
        'Upload parameters - Has fileBytes: ${fileBytes != null}, Has filePath: ${material.filePath != null && material.filePath!.isNotEmpty}',
        tag: 'MaterialUpload',
      );

      // Step 1: Validate file
      Logger.info(
        'Step 1/4: Validating file...',
        tag: 'MaterialUpload',
      );
      final validationStartTime = DateTime.now();
      final validationResult = _validationService.validateFile(
        fileName: material.name,
        fileSizeBytes: material.fileSizeBytes,
      );
      final validationDuration = DateTime.now().difference(validationStartTime);
      
      Logger.info(
        'Validation completed in ${validationDuration.inMilliseconds}ms - Valid: ${validationResult.isValid}',
        tag: 'MaterialUpload',
      );

      if (!validationResult.isValid) {
        Logger.error(
          'File validation failed: ${validationResult.error}',
          tag: 'MaterialUpload',
        );
        return UploadResult.failure(validationResult.error ?? 'Validation failed');
      }
      
      Logger.info(
        'File validation passed',
        tag: 'MaterialUpload',
      );

      // Step 2: Upload file to cloud storage and store metadata
      // Report progress: 0-70% for upload
      try {
        Logger.info(
          'Step 2/4: Uploading file to cloud storage and storing metadata...',
          tag: 'MaterialUpload',
        );
        final storageUploadStartTime = DateTime.now();

        final inserted = await _materialRemote.uploadAndInsertMaterial(
          material,
          fileBytes: fileBytes,
          onProgress: (progress) {
            // Map upload progress to 0-70% of total
            final mappedProgress = progress * 0.7;
            Logger.debug(
              'Upload progress: ${(mappedProgress * 100).toStringAsFixed(1)}% (storage: ${(progress * 100).toStringAsFixed(1)}%)',
              tag: 'MaterialUpload',
            );
            onProgress?.call(mappedProgress);
          },
        );

        final uploadDuration = DateTime.now().difference(storageUploadStartTime);
        final materialId = inserted['id'] as String? ?? material.id;
        final fileUrl = inserted['file_url'] as String? ?? 'N/A';

        Logger.info(
          'File uploaded successfully in ${uploadDuration.inMilliseconds}ms',
          tag: 'MaterialUpload',
        );
        Logger.info(
          'Material stored in database - ID: $materialId, URL: $fileUrl',
          tag: 'MaterialUpload',
        );

        // Step 3: Extract text (only for PDF, TXT, DOCX)
        // Report progress: 70-90% for extraction
        String? extractedTextId;
        if (_shouldExtractText(material.fileType)) {
          try {
            Logger.info(
              'Step 3/4: Starting text extraction for: ${material.name} (Type: ${material.fileType.name})',
              tag: 'MaterialUpload',
            );
            final extractionStartTime = DateTime.now();

            onProgress?.call(0.7);
            Logger.debug(
              'Progress: 70% - Starting text extraction',
              tag: 'MaterialUpload',
            );

            Logger.debug(
              'Extraction parameters - FileType: ${material.fileType.name}, Has filePath: ${material.filePath != null}, Has fileBytes: ${fileBytes != null}',
              tag: 'MaterialUpload',
            );

            final extractionResult = await _extractionService.extractText(
              fileType: material.fileType,
              filePath: material.filePath,
              fileBytes: fileBytes,
              fileName: material.name,
            );

            final extractionDuration = DateTime.now().difference(extractionStartTime);
            Logger.info(
              'Text extraction completed in ${extractionDuration.inMilliseconds}ms - Success: ${extractionResult.success}, Method: ${extractionResult.extractionMethod}',
              tag: 'MaterialUpload',
            );

            onProgress?.call(0.9);
            Logger.debug(
              'Progress: 90% - Text extraction completed',
              tag: 'MaterialUpload',
            );

            if (extractionResult.success && extractionResult.extractedText.isNotEmpty) {
              Logger.info(
                'Extraction result - Characters: ${extractionResult.characterCount}, Words: ${extractionResult.wordCount}, Text preview: ${extractionResult.extractedText.substring(0, extractionResult.extractedText.length > 100 ? 100 : extractionResult.extractedText.length)}...',
                tag: 'MaterialUpload',
              );
              
              // Step 4: Store extracted text in database
              try {
                Logger.info(
                  'Step 4/4: Storing extracted text in document_texts table...',
                  tag: 'MaterialUpload',
                );
                final storageStartTime = DateTime.now();
                Logger.info(
                  'Storing extracted text - Characters: ${extractionResult.characterCount}, Words: ${extractionResult.wordCount}',
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

                final storageDuration = DateTime.now().difference(storageStartTime);
                extractedTextId = documentText.id;
                Logger.info(
                  'Extracted text stored successfully in ${storageDuration.inMilliseconds}ms',
                  tag: 'MaterialUpload',
                );
                Logger.info(
                  'Document text record - ID: $extractedTextId, Material ID: $materialId, Status: ${documentText.parsingStatus}',
                  tag: 'MaterialUpload',
                );
              } catch (e, stackTrace) {
                // Log error with detailed information but don't fail the entire operation
                // The file upload succeeded, so we don't want to fail the whole operation
                // However, text extraction storage failure means quiz generation won't work
                final errorMessage = e is PostgrestException
                    ? 'Database error storing extracted text: ${e.message}. Code: ${e.code}. Details: ${e.details}'
                    : 'Error storing extracted text: $e';
                
                Logger.error(
                  errorMessage,
                  tag: 'MaterialUpload',
                  error: e,
                  stackTrace: stackTrace,
                );
                
                // Also log as warning for visibility
                Logger.warning(
                  'Text extraction completed but storage failed. Material uploaded successfully, but quiz generation may not work until text is stored.',
                  tag: 'MaterialUpload',
                );
              }
            } else {
              Logger.warning(
                'Text extraction failed or returned empty text: ${extractionResult.error}',
                tag: 'MaterialUpload',
              );
              Logger.warning(
                'Skipping text storage - extraction was not successful',
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
            Logger.warning(
              'File upload succeeded but text extraction/storage failed. Material is available but quiz generation may not work.',
              tag: 'MaterialUpload',
            );
          }
        } else {
          Logger.info(
            'Skipping text extraction - File type ${material.fileType.name} does not support text extraction',
            tag: 'MaterialUpload',
          );
        }

        // Report completion
        onProgress?.call(1.0);
        Logger.debug(
          'Progress: 100% - Upload process completed',
          tag: 'MaterialUpload',
        );

        final totalDuration = DateTime.now().difference(uploadStartTime);
        Logger.info(
          '=== Material upload completed successfully ===',
          tag: 'MaterialUpload',
        );
        Logger.info(
          'Total upload time: ${totalDuration.inMilliseconds}ms (${totalDuration.inSeconds}s)',
          tag: 'MaterialUpload',
        );
        Logger.info(
          'Final result - Material ID: $materialId, Document Text ID: ${extractedTextId ?? "N/A (no text extraction)"}',
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

