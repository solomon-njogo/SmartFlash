import '../../data/models/course_material_model.dart';
import '../utils/logger.dart';

/// Result of file validation
class FileValidationResult {
  final bool isValid;
  final String? error;
  final FileType? fileType;

  FileValidationResult({
    required this.isValid,
    this.error,
    this.fileType,
  });

  factory FileValidationResult.success(FileType fileType) {
    return FileValidationResult(
      isValid: true,
      fileType: fileType,
    );
  }

  factory FileValidationResult.failure(String error) {
    return FileValidationResult(
      isValid: false,
      error: error,
    );
  }
}

/// Service for validating uploaded files
class FileValidationService {
  static FileValidationService? _instance;
  static FileValidationService get instance =>
      _instance ??= FileValidationService._();

  FileValidationService._();

  /// Maximum file size in bytes (50MB)
  static const int maxFileSizeBytes = 50 * 1024 * 1024;

  /// Valid MIME types for text extraction
  static const Set<String> validMimeTypes = {
    'application/pdf',
    'text/plain',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  };

  /// Valid file extensions
  static const Set<String> validExtensions = {
    'pdf',
    'txt',
    'docx',
  };

  /// Validate a file based on its properties
  FileValidationResult validateFile({
    required String fileName,
    required int fileSizeBytes,
    String? mimeType,
    String? extension,
  }) {
    try {
      Logger.info(
        'Validating file: $fileName (${fileSizeBytes} bytes)',
        tag: 'FileValidation',
      );

      // Validate file size
      if (fileSizeBytes > maxFileSizeBytes) {
        return FileValidationResult.failure(
          'File size exceeds maximum limit of ${maxFileSizeBytes ~/ (1024 * 1024)}MB',
        );
      }

      if (fileSizeBytes <= 0) {
        return FileValidationResult.failure('File size must be greater than 0');
      }

      // Get file extension from filename if not provided
      final fileExt = extension ??
          (fileName.contains('.')
              ? fileName.split('.').last.toLowerCase()
              : null);

      if (fileExt == null) {
        return FileValidationResult.failure(
          'Unable to determine file extension from filename',
        );
      }

      // Validate file extension
      if (!validExtensions.contains(fileExt)) {
        return FileValidationResult.failure(
          'Unsupported file extension: .$fileExt. Supported formats: ${validExtensions.map((e) => '.$e').join(', ')}',
        );
      }

      // Validate MIME type if provided
      if (mimeType != null && !validMimeTypes.contains(mimeType)) {
        Logger.warning(
          'MIME type $mimeType does not match expected types, but extension is valid',
          tag: 'FileValidation',
        );
        // Don't fail validation based on MIME type alone if extension is valid
      }

      // Map extension to FileType
      final fileType = _mapExtensionToFileType(fileExt);
      if (fileType == null) {
        return FileValidationResult.failure(
          'Unable to determine file type from extension: .$fileExt',
        );
      }

      Logger.info(
        'File validation successful: $fileName (${fileType.name})',
        tag: 'FileValidation',
      );

      return FileValidationResult.success(fileType);
    } catch (e, stackTrace) {
      Logger.error(
        'Error during file validation: $e',
        tag: 'FileValidation',
        error: e,
        stackTrace: stackTrace,
      );
      return FileValidationResult.failure('File validation error: $e');
    }
  }

  /// Map file extension to FileType enum
  FileType? _mapExtensionToFileType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return FileType.pdf;
      case 'txt':
        return FileType.text;
      case 'docx':
        return FileType.docx;
      default:
        return null;
    }
  }

  /// Sanitize filename to prevent path traversal issues
  String sanitizeFileName(String fileName) {
    // Remove path separators and other dangerous characters
    final sanitized = fileName
        .replaceAll(RegExp(r'[<>:"|?*\x00-\x1f]'), '_')
        .replaceAll(RegExp(r'[/\\]'), '_');

    // Limit filename length
    if (sanitized.length > 255) {
      final ext = sanitized.contains('.')
          ? '.${sanitized.split('.').last}'
          : '';
      final nameWithoutExt = sanitized.substring(0, 255 - ext.length);
      return '$nameWithoutExt$ext';
    }

    return sanitized;
  }
}

