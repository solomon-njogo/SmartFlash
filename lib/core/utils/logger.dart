import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Logging utility for the SmartFlash application
class Logger {
  static const String _tag = 'SmartFlash';

  /// Log debug message
  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? _tag,
        level: 500, // Debug level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log info message
  static void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800, // Info level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log warning message
  static void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 900, // Warning level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log error message
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log API request
  static void logApiRequest(
    String method,
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    debug('API Request: $method $url', tag: 'API');
    if (body != null) {
      debug('Request Body: $body', tag: 'API');
    }
    if (headers != null) {
      debug('Request Headers: $headers', tag: 'API');
    }
  }

  /// Log API response
  static void logApiResponse(
    int statusCode,
    String url, {
    Map<String, dynamic>? body,
  }) {
    if (statusCode >= 200 && statusCode < 300) {
      info('API Response: $statusCode $url', tag: 'API');
    } else {
      error('API Error: $statusCode $url', tag: 'API');
    }
    if (body != null) {
      debug('Response Body: $body', tag: 'API');
    }
  }

  /// Log database operation
  static void logDatabase(
    String operation,
    String table, {
    Map<String, dynamic>? data,
  }) {
    info('Database $operation on $table', tag: 'Database');
    if (data != null) {
      debug('Data: $data', tag: 'Database');
    }
  }

  /// Log authentication event
  static void logAuth(String event, {String? userId, String? email}) {
    info(
      'Auth $event${userId != null ? ' for user: $userId' : ''}${email != null ? ' ($email)' : ''}',
      tag: 'Auth',
    );
  }

  /// Log user action
  static void logUserAction(String action, {Map<String, dynamic>? data}) {
    info('User Action: $action', tag: 'User');
    if (data != null) {
      debug('Action Data: $data', tag: 'User');
    }
  }

  /// Log performance metric
  static void logPerformance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metadata,
  }) {
    info(
      'Performance: $operation took ${duration.inMilliseconds}ms',
      tag: 'Performance',
    );
    if (metadata != null) {
      debug('Metadata: $metadata', tag: 'Performance');
    }
  }

  /// Log sync operation
  static void logSync(
    String operation, {
    String? status,
    Map<String, dynamic>? data,
  }) {
    info('Sync $operation${status != null ? ': $status' : ''}', tag: 'Sync');
    if (data != null) {
      debug('Sync Data: $data', tag: 'Sync');
    }
  }

  /// Log AI operation
  static void logAI(
    String operation, {
    String? model,
    Map<String, dynamic>? data,
  }) {
    info('AI $operation${model != null ? ' using $model' : ''}', tag: 'AI');
    if (data != null) {
      debug('AI Data: $data', tag: 'AI');
    }
  }

  /// Log file operation
  static void logFile(String operation, String fileName, {int? fileSize}) {
    info(
      'File $operation: $fileName${fileSize != null ? ' (${fileSize} bytes)' : ''}',
      tag: 'File',
    );
  }

  /// Log network status
  static void logNetwork(String status, {String? connectionType}) {
    info(
      'Network: $status${connectionType != null ? ' ($connectionType)' : ''}',
      tag: 'Network',
    );
  }

  /// Log exception with stack trace
  static void logException(
    Object exception,
    StackTrace stackTrace, {
    String? context,
  }) {
    error(
      'Exception${context != null ? ' in $context' : ''}: $exception',
      error: exception,
      stackTrace: stackTrace,
    );
  }

  /// Log with custom tag
  static void logWithTag(
    String message,
    String tag, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    info(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log method entry
  static void logMethodEntry(
    String methodName, {
    Map<String, dynamic>? parameters,
  }) {
    debug('Entering $methodName', tag: 'Method');
    if (parameters != null) {
      debug('Parameters: $parameters', tag: 'Method');
    }
  }

  /// Log method exit
  static void logMethodExit(String methodName, {dynamic result}) {
    debug('Exiting $methodName', tag: 'Method');
    if (result != null) {
      debug('Result: $result', tag: 'Method');
    }
  }
}
