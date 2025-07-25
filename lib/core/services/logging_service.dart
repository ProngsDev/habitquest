import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../errors/app_exceptions.dart';

/// Structured logging service following JP_GE principles
class LoggingService {

  LoggingService._internal() {
    _logger = Logger(
      filter: _LogFilter(),
      printer: _LogPrinter(),
      output: _LogOutput(),
    );
  }
  static LoggingService? _instance;
  late final Logger _logger;

  /// Singleton instance
  static LoggingService get instance {
    _instance ??= LoggingService._internal();
    return _instance!;
  }

  /// Log debug information
  void debug(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.d(
      message,
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
    _logWithContext(Level.debug, message, context, error, stackTrace);
  }

  /// Log informational messages
  void info(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.i(
      message,
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
    _logWithContext(Level.info, message, context, error, stackTrace);
  }

  /// Log warning messages
  void warning(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.w(
      message,
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
    _logWithContext(Level.warning, message, context, error, stackTrace);
  }

  /// Log error messages
  void error(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
    _logWithContext(Level.error, message, context, error, stackTrace);
  }

  /// Log fatal errors
  void fatal(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.f(
      message,
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
    _logWithContext(Level.fatal, message, context, error, stackTrace);
  }

  /// Log AppException with appropriate level
  void logException(AppException exception) {
    final context = {
      'code': exception.code,
      'severity': exception.severity.displayName,
      'retryable': exception.isRetryable,
      'shouldReport': exception.shouldReport,
      'timestamp': exception.timestamp.toIso8601String(),
      if (exception.context != null) 'context': exception.context,
    };

    switch (exception.severity) {
      case ErrorSeverity.info:
        info(exception.message, context: context, error: exception.cause);
        break;
      case ErrorSeverity.warning:
        warning(exception.message, context: context, error: exception.cause);
        break;
      case ErrorSeverity.error:
        error(exception.message, context: context, error: exception.cause);
        break;
      case ErrorSeverity.critical:
        error(exception.message, context: context, error: exception.cause);
        break;
      case ErrorSeverity.fatal:
        fatal(exception.message, context: context, error: exception.cause);
        break;
    }
  }

  /// Log with structured context
  void _logWithContext(
    Level level,
    String message,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (context == null || context.isEmpty) return;

    final structuredLog = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level.name,
      'message': message,
      'context': context,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };

    // In production, send to logging service
    if (!kDebugMode) {
      _sendToLoggingService(structuredLog);
    }
  }

  /// Send logs to external logging service (placeholder)
  void _sendToLoggingService(Map<String, dynamic> logData) {
    // TODO(logging): Implement external logging service integration
    // Example: Send to Firebase Analytics, Sentry, or custom logging endpoint
    debugPrint('Would send to logging service: ${jsonEncode(logData)}');
  }
}

/// Custom log filter for controlling log levels
class _LogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // In debug mode, log everything
    if (kDebugMode) {
      return true;
    }

    // In production, only log warnings and above
    return event.level.index >= Level.warning.index;
  }
}

/// Custom log printer for structured output
class _LogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final color = PrettyPrinter.defaultLevelColors[event.level];
    final emoji = PrettyPrinter.defaultLevelEmojis[event.level];
    final timestamp = DateTime.now().toIso8601String();

    final message =
        '$emoji [$timestamp] ${event.level.name.toUpperCase()}: ${event.message}';

    final lines = <String>[];
    if (color != null) {
      lines.add(color(message));
    } else {
      lines.add(message);
    }

    if (event.error != null) {
      lines.add('Error: ${event.error}');
    }

    if (event.stackTrace != null && event.level.index >= Level.error.index) {
      lines
        ..add('Stack trace:')
        ..addAll(event.stackTrace.toString().split('\n'));
    }

    return lines;
  }
}

/// Custom log output for handling different environments
class _LogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      // In debug mode, use debugPrint for better IDE integration
      if (kDebugMode) {
        debugPrint(line);
      } else {
        // In production, you might want to write to a file or send to a service
        // Using debugPrint even in production to avoid lint warning
        debugPrint(line);
      }
    }
  }
}
