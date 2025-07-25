import 'package:flutter/foundation.dart';

import '../errors/app_exceptions.dart';

/// Validation result containing success status and errors
@immutable
class ValidationResult {

  const ValidationResult({required this.isValid, this.errors = const []});

  /// Create a successful validation result
  const ValidationResult.success() : this(isValid: true);

  /// Create a failed validation result with errors
  const ValidationResult.failure(List<String> errors)
    : this(isValid: false, errors: errors);
  final bool isValid;
  final List<String> errors;

  /// Combine multiple validation results
  static ValidationResult combine(List<ValidationResult> results) {
    final allErrors = <String>[];
    var isValid = true;

    for (final result in results) {
      if (!result.isValid) {
        isValid = false;
        allErrors.addAll(result.errors);
      }
    }

    return ValidationResult(isValid: isValid, errors: allErrors);
  }

  @override
  String toString() => 'ValidationResult(isValid: $isValid, errors: $errors)';
}

/// Base validator interface
abstract class Validator<T> {
  /// Validate the given value
  ValidationResult validate(T? value);

  /// Get the field name for error messages
  String get fieldName;
}

/// String validators
class StringValidator implements Validator<String> {

  const StringValidator({
    required this.fieldName,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.required = true,
    this.customMessage,
  });
  @override
  final String fieldName;
  final int? minLength;
  final int? maxLength;
  final RegExp? pattern;
  final bool required;
  final String? customMessage;

  @override
  ValidationResult validate(String? value) {
    final errors = <String>[];

    // Check if required
    if (required && (value == null || value.trim().isEmpty)) {
      errors.add(customMessage ?? '$fieldName is required');
      return ValidationResult.failure(errors);
    }

    // If not required and empty, it's valid
    if (!required && (value == null || value.trim().isEmpty)) {
      return const ValidationResult.success();
    }

    final trimmedValue = value!.trim();

    // Check minimum length
    if (minLength != null && trimmedValue.length < minLength!) {
      errors.add('$fieldName must be at least $minLength characters long');
    }

    // Check maximum length
    if (maxLength != null && trimmedValue.length > maxLength!) {
      errors.add('$fieldName must be no more than $maxLength characters long');
    }

    // Check pattern
    if (pattern != null && !pattern!.hasMatch(trimmedValue)) {
      errors.add(customMessage ?? '$fieldName format is invalid');
    }

    return errors.isEmpty
        ? const ValidationResult.success()
        : ValidationResult.failure(errors);
  }
}

/// Email validator
class EmailValidator extends StringValidator {

  EmailValidator({super.fieldName = 'Email', super.required = true})
    : super(
        pattern: _emailRegex,
        customMessage: 'Please enter a valid email address',
      );
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
}

/// Numeric validators
class NumericValidator implements Validator<num> {

  const NumericValidator({
    required this.fieldName,
    this.min,
    this.max,
    this.required = true,
    this.allowNegative = true,
    this.allowZero = true,
  });
  @override
  final String fieldName;
  final num? min;
  final num? max;
  final bool required;
  final bool allowNegative;
  final bool allowZero;

  @override
  ValidationResult validate(num? value) {
    final errors = <String>[];

    // Check if required
    if (required && value == null) {
      errors.add('$fieldName is required');
      return ValidationResult.failure(errors);
    }

    // If not required and null, it's valid
    if (!required && value == null) {
      return const ValidationResult.success();
    }

    // Check negative values
    if (!allowNegative && value! < 0) {
      errors.add('$fieldName cannot be negative');
    }

    // Check zero values
    if (!allowZero && value! == 0) {
      errors.add('$fieldName cannot be zero');
    }

    // Check minimum value
    if (min != null && value! < min!) {
      errors.add('$fieldName must be at least $min');
    }

    // Check maximum value
    if (max != null && value! > max!) {
      errors.add('$fieldName must be no more than $max');
    }

    return errors.isEmpty
        ? const ValidationResult.success()
        : ValidationResult.failure(errors);
  }
}

/// Date validator
class DateValidator implements Validator<DateTime> {

  const DateValidator({
    required this.fieldName,
    this.minDate,
    this.maxDate,
    this.required = true,
  });
  @override
  final String fieldName;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool required;

  @override
  ValidationResult validate(DateTime? value) {
    final errors = <String>[];

    // Check if required
    if (required && value == null) {
      errors.add('$fieldName is required');
      return ValidationResult.failure(errors);
    }

    // If not required and null, it's valid
    if (!required && value == null) {
      return const ValidationResult.success();
    }

    // Check minimum date
    if (minDate != null && value!.isBefore(minDate!)) {
      errors.add('$fieldName must be after ${_formatDate(minDate!)}');
    }

    // Check maximum date
    if (maxDate != null && value!.isAfter(maxDate!)) {
      errors.add('$fieldName must be before ${_formatDate(maxDate!)}');
    }

    return errors.isEmpty
        ? const ValidationResult.success()
        : ValidationResult.failure(errors);
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// List validator
class ListValidator<T> implements Validator<List<T>> {

  const ListValidator({
    required this.fieldName,
    this.minLength,
    this.maxLength,
    this.required = true,
    this.itemValidator,
  });
  @override
  final String fieldName;
  final int? minLength;
  final int? maxLength;
  final bool required;
  final Validator<T>? itemValidator;

  @override
  ValidationResult validate(List<T>? value) {
    final errors = <String>[];

    // Check if required
    if (required && (value == null || value.isEmpty)) {
      errors.add('$fieldName is required');
      return ValidationResult.failure(errors);
    }

    // If not required and empty, it's valid
    if (!required && (value == null || value.isEmpty)) {
      return const ValidationResult.success();
    }

    // Check minimum length
    if (minLength != null && value!.length < minLength!) {
      errors.add('$fieldName must have at least $minLength items');
    }

    // Check maximum length
    if (maxLength != null && value!.length > maxLength!) {
      errors.add('$fieldName must have no more than $maxLength items');
    }

    // Validate individual items if validator provided
    if (itemValidator != null && value != null) {
      for (var i = 0; i < value.length; i++) {
        final itemResult = itemValidator!.validate(value[i]);
        if (!itemResult.isValid) {
          errors.addAll(itemResult.errors.map((e) => '$fieldName[$i]: $e'));
        }
      }
    }

    return errors.isEmpty
        ? const ValidationResult.success()
        : ValidationResult.failure(errors);
  }
}

/// Composite validator for validating objects with multiple fields
class CompositeValidator<T> implements Validator<T> {

  const CompositeValidator({
    required this.fieldName,
    required Map<String, ValidationResult Function(T)> fieldValidators,
  }) : _fieldValidators = fieldValidators;
  @override
  final String fieldName;
  final Map<String, ValidationResult Function(T)> _fieldValidators;

  @override
  ValidationResult validate(T? value) {
    if (value == null) {
      return ValidationResult.failure(['$fieldName is required']);
    }

    final results = <ValidationResult>[];

    for (final validator in _fieldValidators.values) {
      results.add(validator(value));
    }

    return ValidationResult.combine(results);
  }
}

/// Validation helper class for common validation patterns
class ValidationHelper {
  /// Validate and throw exception if validation fails
  static void validateAndThrow(ValidationResult result) {
    if (!result.isValid) {
      throw DataValidationException(validationErrors: result.errors);
    }
  }

  /// Validate multiple fields and return combined result
  static ValidationResult validateFields(
    Map<String, ValidationResult> fieldResults,
  ) {
    final results = fieldResults.values.toList();
    return ValidationResult.combine(results);
  }

  /// Create a habit name validator
  static StringValidator habitNameValidator() => const StringValidator(
      fieldName: 'Habit name',
      minLength: 1,
      maxLength: 100,
    );

  /// Create a habit description validator
  static StringValidator habitDescriptionValidator() => const StringValidator(
      fieldName: 'Habit description',
      maxLength: 500,
      required: false,
    );

  /// Create a user name validator
  static StringValidator userNameValidator() => const StringValidator(
      fieldName: 'User name',
      minLength: 1,
      maxLength: 50,
    );

  /// Create an XP validator
  static NumericValidator xpValidator() => const NumericValidator(
      fieldName: 'XP',
      min: 0,
      allowNegative: false,
    );

  /// Create a level validator
  static NumericValidator levelValidator() => const NumericValidator(
      fieldName: 'Level',
      min: 1,
      max: 100,
      allowNegative: false,
      allowZero: false,
    );

  /// Create a streak validator
  static NumericValidator streakValidator() => const NumericValidator(
      fieldName: 'Streak',
      min: 0,
      allowNegative: false,
    );

  /// Create a habit search query validator
  static StringValidator habitSearchQueryValidator() => const StringValidator(
      fieldName: 'Search query',
      required: false,
      maxLength: 200,
    );

  /// Create a user email validator
  static EmailValidator userEmailValidator() => EmailValidator(fieldName: 'User email');
}
