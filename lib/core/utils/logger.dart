import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// ANSI color codes for terminal output
class _AnsiColors {
  static const String reset = '\x1B[0m';
  static const String bold = '\x1B[1m';

  // Text colors
  // ignore: unused_field
  static const String blue = '\x1B[34m';
  static const String brightBlue = '\x1B[94m';
  static const String cyan = '\x1B[36m';
  static const String green = '\x1B[32m';
  // ignore: unused_field
  static const String yellow = '\x1B[33m';
  static const String orange = '\x1B[38;5;208m';
  // ignore: unused_field
  static const String red = '\x1B[31m';
  // ignore: unused_field
  static const String brightRed = '\x1B[91m';
  static const String white = '\x1B[37m';
  // ignore: unused_field
  static const String gray = '\x1B[90m';

  // Background colors
  static const String bgRed = '\x1B[41m';
  // ignore: unused_field
  static const String bgBlue = '\x1B[44m';
  // ignore: unused_field
  static const String bgYellow = '\x1B[43m';
}

/// Logging utility for the SmartFlash application
class Logger {
  static const String _tag = 'SmartFlash';

  /// Format log message with colors and icons
  static String _formatLogMessage({
    required String message,
    required String tag,
    required String icon,
    required String color,
    String? level,
    bool isError = false,
  }) {
    final levelText = level != null ? ' $level' : '';
    final tagColor = isError ? _AnsiColors.white : _AnsiColors.cyan;
    final messageColor = isError ? _AnsiColors.white : color;

    if (isError) {
      // Error with red background
      return '${_AnsiColors.bgRed}${_AnsiColors.bold}$icon $tagColor[$tag]${_AnsiColors.reset}${_AnsiColors.bgRed}$levelText: $messageColor$message${_AnsiColors.reset}';
    } else {
      // Normal colored log
      return '$color$icon $tagColor[$tag]${_AnsiColors.reset}$levelText: $messageColor$message${_AnsiColors.reset}';
    }
  }

  /// Log debug message
  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final tagName = tag ?? _tag;
      developer.log(
        message,
        name: tagName,
        level: 500, // Debug level
        error: error,
        stackTrace: stackTrace,
      );
      // Print with color and icon
      print(
        _formatLogMessage(
          message: message,
          tag: tagName,
          icon: '🌿',
          color: _AnsiColors.green,
          level: 'DEBUG',
        ),
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
    final tagName = tag ?? _tag;
    developer.log(
      message,
      name: tagName,
      level: 800, // Info level
      error: error,
      stackTrace: stackTrace,
    );
    // Print with blue color and lightbulb icon
    print(
      _formatLogMessage(
        message: message,
        tag: tagName,
        icon: '💡',
        color: _AnsiColors.brightBlue,
      ),
    );
  }

  /// Log warning message
  static void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final tagName = tag ?? _tag;
    developer.log(
      message,
      name: tagName,
      level: 900, // Warning level
      error: error,
      stackTrace: stackTrace,
    );
    // Print with orange/yellow color and warning icon
    print(
      _formatLogMessage(
        message: message,
        tag: tagName,
        icon: '⚠️',
        color: _AnsiColors.orange,
        level: 'WARNING',
      ),
    );
  }

  /// Log error message
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final tagName = tag ?? _tag;
    developer.log(
      message,
      name: tagName,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
    // Print error with red background and stop icon
    print(
      _formatLogMessage(
        message: message,
        tag: tagName,
        icon: '🚫',
        color: _AnsiColors.white,
        level: 'ERROR',
        isError: true,
      ),
    );
    if (error != null) {
      print(
        '$_AnsiColors.red  └─ Error details: $_AnsiColors.brightRed$error$_AnsiColors.reset',
      );
    }
    if (stackTrace != null) {
      print('$_AnsiColors.gray  └─ Stack trace:$_AnsiColors.reset');
      print('$_AnsiColors.gray$stackTrace$_AnsiColors.reset');
    }
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
