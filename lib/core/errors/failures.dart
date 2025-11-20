/// Failure classes for error handling in repositories
abstract class Failure {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({required this.message, this.code, this.details});

  @override
  String toString() =>
      'Failure: $message${code != null ? ' (Code: $code)' : ''}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure &&
        other.message == message &&
        other.code == code &&
        other.details == details;
  }

  @override
  int get hashCode => Object.hash(message, code, details);
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code, super.details});
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code, super.details});
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code, super.details});
}

/// Database failure
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code, super.details});
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code, super.details});
}

/// File operation failure
class FileFailure extends Failure {
  const FileFailure({required super.message, super.code, super.details});
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code, super.details});
}

/// AI service failure
class AIServiceFailure extends Failure {
  const AIServiceFailure({required super.message, super.code, super.details});
}

/// Sync failure
class SyncFailure extends Failure {
  const SyncFailure({required super.message, super.code, super.details});
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code, super.details});
}
