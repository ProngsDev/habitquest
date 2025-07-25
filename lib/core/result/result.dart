import 'package:flutter/foundation.dart';

import '../errors/app_exceptions.dart';
import '../errors/error_handler.dart';

/// Result type for functional error handling following JP_GE principles
@immutable
sealed class Result<T> {
  const Result();

  /// Create a successful result
  const factory Result.success(T data) = Success<T>;

  /// Create a failed result
  const factory Result.failure(AppException error) = Failure<T>;

  /// Check if result is successful
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get data if successful, null otherwise
  T? get data => switch (this) {
    Success<T>(data: final data) => data,
    Failure<T>() => null,
  };

  /// Get error if failure, null otherwise
  AppException? get error => switch (this) {
    Success<T>() => null,
    Failure<T>(error: final error) => error,
  };

  /// Transform the data if successful
  Result<U> map<U>(U Function(T) transform) => switch (this) {
    Success<T>(data: final data) => Result.success(transform(data)),
    Failure<T>(error: final error) => Result.failure(error),
  };

  /// Transform the data if successful, allowing for failure
  Result<U> flatMap<U>(Result<U> Function(T) transform) => switch (this) {
    Success<T>(data: final data) => transform(data),
    Failure<T>(error: final error) => Result.failure(error),
  };

  /// Handle both success and failure cases
  U fold<U>(U Function(AppException) onFailure, U Function(T) onSuccess) =>
      switch (this) {
        Success<T>(data: final data) => onSuccess(data),
        Failure<T>(error: final error) => onFailure(error),
      };

  /// Execute action if successful
  Result<T> onSuccess(void Function(T) action) {
    if (this is Success<T>) {
      action((this as Success<T>).data);
    }
    return this;
  }

  /// Execute action if failure
  Result<T> onFailure(void Function(AppException) action) {
    if (this is Failure<T>) {
      action((this as Failure<T>).error);
    }
    return this;
  }

  /// Get data or throw exception
  T getOrThrow() => switch (this) {
    Success<T>(data: final data) => data,
    Failure<T>(error: final error) => throw error,
  };

  /// Get data or return default value
  T getOrElse(T defaultValue) => switch (this) {
    Success<T>(data: final data) => data,
    Failure<T>() => defaultValue,
  };

  /// Get data or compute default value
  T getOrElseGet(T Function() defaultValue) => switch (this) {
    Success<T>(data: final data) => data,
    Failure<T>() => defaultValue(),
  };

  /// Recover from failure with a new value
  Result<T> recover(T Function(AppException) recovery) => switch (this) {
    Success<T>() => this,
    Failure<T>(error: final error) => Result.success(recovery(error)),
  };

  /// Recover from failure with a new Result
  Result<T> recoverWith(Result<T> Function(AppException) recovery) =>
      switch (this) {
        Success<T>() => this,
        Failure<T>(error: final error) => recovery(error),
      };

  @override
  String toString() => switch (this) {
    Success<T>(data: final data) => 'Success($data)',
    Failure<T>(error: final error) => 'Failure($error)',
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Result<T> &&
        switch ((this, other)) {
          (Success<T>(data: final data1), Success<T>(data: final data2)) =>
            data1 == data2,
          (Failure<T>(error: final error1), Failure<T>(error: final error2)) =>
            error1 == error2,
          _ => false,
        };
  }

  @override
  int get hashCode => switch (this) {
    Success<T>(data: final data) => Object.hash('Success', data),
    Failure<T>(error: final error) => Object.hash('Failure', error),
  };
}

/// Successful result containing data
@immutable
final class Success<T> extends Result<T> {
  const Success(this.data);
  @override
  final T data;

  @override
  String toString() => 'Success($data)';
}

/// Failed result containing error
@immutable
final class Failure<T> extends Result<T> {
  const Failure(this.error);
  @override
  final AppException error;

  @override
  String toString() => 'Failure($error)';
}

/// Extension methods for working with Results
extension ResultExtensions<T> on Result<T> {
  /// Convert to Future&lt;Result&lt;T&gt;&gt;
  Future<Result<T>> toFuture() => Future.value(this);

  /// Filter result based on predicate
  Result<T> filter(
    bool Function(T) predicate,
    AppException Function() onFalse,
  ) => switch (this) {
    Success<T>(data: final data) when predicate(data) => this,
    Success<T>() => Result.failure(onFalse()),
    Failure<T>() => this,
  };

  /// Tap into the result for side effects without changing it
  Result<T> tap(
    void Function(T) onSuccess, [
    void Function(AppException)? onFailure,
  ]) {
    switch (this) {
      case Success<T>(data: final data):
        onSuccess(data);
      case Failure<T>(error: final error):
        onFailure?.call(error);
    }
    return this;
  }
}

/// Extension methods for Future&lt;Result&lt;T&gt;&gt;
extension FutureResultExtensions<T> on Future<Result<T>> {
  /// Map the data if successful
  Future<Result<U>> mapAsync<U>(Future<U> Function(T) transform) async {
    final result = await this;
    return switch (result) {
      Success<T>(data: final data) => Result.success(await transform(data)),
      Failure<T>(error: final error) => Result.failure(error),
    };
  }

  /// FlatMap for async operations
  Future<Result<U>> flatMapAsync<U>(
    Future<Result<U>> Function(T) transform,
  ) async {
    final result = await this;
    return switch (result) {
      Success<T>(data: final data) => await transform(data),
      Failure<T>(error: final error) => Result.failure(error),
    };
  }

  /// Handle both success and failure cases asynchronously
  Future<U> foldAsync<U>(
    Future<U> Function(AppException) onFailure,
    Future<U> Function(T) onSuccess,
  ) async {
    final result = await this;
    return switch (result) {
      Success<T>(data: final data) => await onSuccess(data),
      Failure<T>(error: final error) => await onFailure(error),
    };
  }
}

/// Utility functions for working with Results
class ResultUtils {
  /// Combine multiple Results into a single Result containing a list
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final values = <T>[];

    for (final result in results) {
      switch (result) {
        case Success<T>(data: final data):
          values.add(data);
        case Failure<T>(error: final error):
          return Result.failure(error);
      }
    }

    return Result.success(values);
  }

  /// Execute a function that might throw and wrap in Result
  static Result<T> tryExecute<T>(T Function() function) {
    try {
      return Result.success(function());
    } on Exception catch (error, stackTrace) {
      final appException = ErrorHandler.handleError(error, stackTrace);
      return Result.failure(appException);
    }
  }

  /// Execute an async function that might throw and wrap in Result
  static Future<Result<T>> tryExecuteAsync<T>(
    Future<T> Function() function,
  ) async {
    try {
      final result = await function();
      return Result.success(result);
    } on Exception catch (error, stackTrace) {
      final appException = ErrorHandler.handleError(error, stackTrace);
      return Result.failure(appException);
    }
  }

  /// Convert a nullable value to Result
  static Result<T> fromNullable<T>(T? value, AppException Function() onNull) =>
      value != null ? Result.success(value) : Result.failure(onNull());

  /// Sequence a list of async Results
  static Future<Result<List<T>>> sequence<T>(
    List<Future<Result<T>>> futures,
  ) async {
    final results = await Future.wait(futures);
    return combine(results);
  }

  /// Traverse a list with an async function that returns Result
  static Future<Result<List<U>>> traverse<T, U>(
    List<T> items,
    Future<Result<U>> Function(T) transform,
  ) async {
    final futures = items.map(transform).toList();
    return sequence(futures);
  }

  /// Fold a list of Results, collecting all errors
  static Result<List<T>> collectErrors<T>(List<Result<T>> results) {
    final values = <T>[];
    final errors = <AppException>[];

    for (final result in results) {
      switch (result) {
        case Success<T>(data: final data):
          values.add(data);
        case Failure<T>(error: final error):
          errors.add(error);
      }
    }

    if (errors.isNotEmpty) {
      // Combine all errors into a single exception
      final combinedError = DataValidationException(
        validationErrors: errors.map((e) => e.message).toList(),
        context: {'errorCount': errors.length},
      );
      return Result.failure(combinedError);
    }

    return Result.success(values);
  }
}
