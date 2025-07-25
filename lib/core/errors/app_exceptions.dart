import 'package:flutter/foundation.dart';

/// Base class for all application exceptions following JP_GE Präzision principles
@immutable
abstract class AppException implements Exception {

  AppException({
    required this.code,
    required this.message,
    this.context,
    this.cause,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  /// Error code for categorization and handling
  final String code;

  /// Human-readable error message
  final String message;

  /// Additional context information for debugging
  final Map<String, dynamic>? context;

  /// Original exception that caused this error (if any)
  final Exception? cause;

  /// Timestamp when the error occurred
  final DateTime timestamp;

  /// Whether this error should be reported to crash analytics
  bool get shouldReport => true;

  /// Whether this error can be retried
  bool get isRetryable => false;

  /// User-friendly message for display
  String get userMessage => message;

  /// Severity level of the error
  ErrorSeverity get severity => ErrorSeverity.error;

  @override
  String toString() =>
      'AppException(code: $code, message: $message, context: $context)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppException &&
        other.code == code &&
        other.message == message &&
        mapEquals(other.context, context);
  }

  @override
  int get hashCode => Object.hash(code, message, context);
}

/// Error severity levels for proper categorization
enum ErrorSeverity {
  /// Informational - no action required
  info,

  /// Warning - potential issue but operation can continue
  warning,

  /// Error - operation failed but app can continue
  error,

  /// Critical - serious error that may affect app stability
  critical,

  /// Fatal - app cannot continue and must restart
  fatal;

  String get displayName {
    switch (this) {
      case ErrorSeverity.info:
        return 'Info';
      case ErrorSeverity.warning:
        return 'Warning';
      case ErrorSeverity.error:
        return 'Error';
      case ErrorSeverity.critical:
        return 'Critical';
      case ErrorSeverity.fatal:
        return 'Fatal';
    }
  }
}

/// Data layer exceptions
abstract class DataException extends AppException {
  DataException({
    required super.code,
    required super.message,
    super.context,
    super.cause,
    super.timestamp,
  });

  @override
  ErrorSeverity get severity => ErrorSeverity.error;
}

/// Database operation failed
class DatabaseException extends DataException {
  DatabaseException({required super.message, super.context, super.cause})
    : super(code: 'DATABASE_ERROR');

  @override
  String get userMessage => 'A database error occurred. Please try again.';

  @override
  bool get isRetryable => true;
}

/// Data not found in storage
class DataNotFoundException extends DataException {
  DataNotFoundException({
    required String entityType,
    required String identifier,
    super.context,
  }) : super(
         code: 'DATA_NOT_FOUND',
         message: '$entityType with identifier "$identifier" not found',
       );

  @override
  String get userMessage => 'The requested data could not be found.';

  @override
  ErrorSeverity get severity => ErrorSeverity.warning;

  @override
  bool get shouldReport => false;
}

/// Data validation failed
class DataValidationException extends DataException {

  DataValidationException({required this.validationErrors, super.context})
    : super(code: 'DATA_VALIDATION_ERROR', message: 'Data validation failed');
  final List<String> validationErrors;

  @override
  String get userMessage => 'Please check your input and try again.';

  @override
  bool get shouldReport => false;
}

/// Storage quota exceeded
class StorageQuotaExceededException extends DataException {
  StorageQuotaExceededException({super.context})
    : super(code: 'STORAGE_QUOTA_EXCEEDED', message: 'Storage quota exceeded');

  @override
  String get userMessage => 'Storage space is full. Please free up some space.';

  @override
  ErrorSeverity get severity => ErrorSeverity.warning;
}

/// Business logic exceptions
abstract class BusinessException extends AppException {
  BusinessException({
    required super.code,
    required super.message,
    super.context,
    super.cause,
    super.timestamp,
  });

  @override
  ErrorSeverity get severity => ErrorSeverity.error;

  @override
  bool get shouldReport => false;
}

/// Invalid operation attempted
class InvalidOperationException extends BusinessException {
  InvalidOperationException({required super.message, super.context})
    : super(code: 'INVALID_OPERATION');

  @override
  String get userMessage => 'This operation is not allowed at this time.';
}

/// Insufficient permissions for operation
class InsufficientPermissionsException extends BusinessException {
  InsufficientPermissionsException({required String operation, super.context})
    : super(
        code: 'INSUFFICIENT_PERMISSIONS',
        message: 'Insufficient permissions for operation: $operation',
      );

  @override
  String get userMessage =>
      'You don\'t have permission to perform this action.';
}

/// Resource limit exceeded
class ResourceLimitExceededException extends BusinessException {
  ResourceLimitExceededException({
    required this.resourceType,
    required this.currentCount,
    required this.maxAllowed,
    super.context,
  }) : super(
         code: 'RESOURCE_LIMIT_EXCEEDED',
         message: '$resourceType limit exceeded: $currentCount/$maxAllowed',
       );

  final String resourceType;
  final int currentCount;
  final int maxAllowed;

  @override
  String get userMessage =>
      'You have reached the maximum number of $resourceType allowed.';
}

/// Network and connectivity exceptions
abstract class NetworkException extends AppException {
  NetworkException({
    required super.code,
    required super.message,
    super.context,
    super.cause,
    super.timestamp,
  });

  @override
  bool get isRetryable => true;

  @override
  ErrorSeverity get severity => ErrorSeverity.warning;
}

/// No internet connection available
class NoInternetConnectionException extends NetworkException {
  NoInternetConnectionException({super.context})
    : super(
        code: 'NO_INTERNET_CONNECTION',
        message: 'No internet connection available',
      );

  @override
  String get userMessage =>
      'Please check your internet connection and try again.';
}

/// Network request timeout
class NetworkTimeoutException extends NetworkException {
  NetworkTimeoutException({super.context})
    : super(code: 'NETWORK_TIMEOUT', message: 'Network request timed out');

  @override
  String get userMessage => 'The request took too long. Please try again.';
}

/// Server error response
class ServerException extends NetworkException {
  ServerException({
    required this.statusCode,
    required super.message,
    super.context,
  }) : super(code: 'SERVER_ERROR');

  final int statusCode;

  @override
  String get userMessage => 'Server error occurred. Please try again later.';

  @override
  ErrorSeverity get severity =>
      statusCode >= 500 ? ErrorSeverity.error : ErrorSeverity.warning;
}

/// UI and presentation layer exceptions
abstract class PresentationException extends AppException {
  PresentationException({
    required super.code,
    required super.message,
    super.context,
    super.cause,
    super.timestamp,
  });

  @override
  ErrorSeverity get severity => ErrorSeverity.warning;

  @override
  bool get shouldReport => false;
}

/// Navigation error
class NavigationException extends PresentationException {
  NavigationException({required super.message, super.context})
    : super(code: 'NAVIGATION_ERROR');

  @override
  String get userMessage => 'Navigation error occurred.';
}

/// Widget rendering error
class WidgetRenderException extends PresentationException {
  WidgetRenderException({required super.message, super.context})
    : super(code: 'WIDGET_RENDER_ERROR');

  @override
  String get userMessage =>
      'Display error occurred. Please refresh the screen.';
}

/// System and platform exceptions
abstract class SystemException extends AppException {
  SystemException({
    required super.code,
    required super.message,
    super.context,
    super.cause,
    super.timestamp,
  });

  @override
  ErrorSeverity get severity => ErrorSeverity.critical;
}

/// Platform-specific error
class PlatformException extends SystemException {
  PlatformException({required super.message, super.context, super.cause})
    : super(code: 'PLATFORM_ERROR');

  @override
  String get userMessage => 'A system error occurred. Please restart the app.';
}

/// Permission denied by system
class SystemPermissionDeniedException extends SystemException {
  SystemPermissionDeniedException({required this.permission, super.context})
    : super(
        code: 'SYSTEM_PERMISSION_DENIED',
        message: 'System permission denied: $permission',
      );

  final String permission;

  @override
  String get userMessage =>
      'Permission required. Please grant access in settings.';

  @override
  ErrorSeverity get severity => ErrorSeverity.warning;
}

/// Unknown or unexpected error
class UnknownException extends AppException {
  UnknownException({required super.message, super.context, super.cause})
    : super(code: 'UNKNOWN_ERROR');

  @override
  String get userMessage => 'An unexpected error occurred. Please try again.';

  @override
  ErrorSeverity get severity => ErrorSeverity.error;
}
