/// Custom exceptions for the SmartFlash application
class SmartFlashException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const SmartFlashException({required this.message, this.code, this.details});

  @override
  String toString() =>
      'SmartFlashException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Authentication related exceptions
class AuthenticationException extends SmartFlashException {
  const AuthenticationException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Network related exceptions
class NetworkException extends SmartFlashException {
  const NetworkException({required super.message, super.code, super.details});
}

/// Database related exceptions
class DatabaseException extends SmartFlashException {
  const DatabaseException({required super.message, super.code, super.details});
}

/// File operation exceptions
class FileException extends SmartFlashException {
  const FileException({required super.message, super.code, super.details});
}

/// Validation exceptions
class ValidationException extends SmartFlashException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
  });
}

/// AI service exceptions
class AIServiceException extends SmartFlashException {
  const AIServiceException({required super.message, super.code, super.details});
}

/// Sync related exceptions
class SyncException extends SmartFlashException {
  const SyncException({required super.message, super.code, super.details});
}

/// Cache related exceptions
class CacheException extends SmartFlashException {
  const CacheException({required super.message, super.code, super.details});
}
