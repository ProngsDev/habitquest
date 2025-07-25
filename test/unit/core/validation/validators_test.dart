import 'package:flutter_test/flutter_test.dart';
import 'package:habitquest/core/errors/app_exceptions.dart';
import 'package:habitquest/core/validation/validators.dart';

void main() {
  group('ValidationResult', () {
    test('should create successful result', () {
      const result = ValidationResult.success();

      expect(result.isValid, true);
      expect(result.errors, isEmpty);
    });

    test('should create failed result', () {
      const result = ValidationResult.failure(['Error 1', 'Error 2']);

      expect(result.isValid, false);
      expect(result.errors, ['Error 1', 'Error 2']);
    });

    test('should combine multiple results', () {
      const success = ValidationResult.success();
      const failure1 = ValidationResult.failure(['Error 1']);
      const failure2 = ValidationResult.failure(['Error 2', 'Error 3']);

      final combined = ValidationResult.combine([success, failure1, failure2]);

      expect(combined.isValid, false);
      expect(combined.errors, ['Error 1', 'Error 2', 'Error 3']);
    });

    test('should combine all successful results', () {
      const success1 = ValidationResult.success();
      const success2 = ValidationResult.success();

      final combined = ValidationResult.combine([success1, success2]);

      expect(combined.isValid, true);
      expect(combined.errors, isEmpty);
    });
  });

  group('StringValidator', () {
    test('should validate required field', () {
      const validator = StringValidator(fieldName: 'Name');

      expect(validator.validate('test').isValid, true);
      expect(validator.validate('').isValid, false);
      expect(validator.validate(null).isValid, false);
      expect(validator.validate('   ').isValid, false);
    });

    test('should validate optional field', () {
      const validator = StringValidator(
        fieldName: 'Description',
        required: false,
      );

      expect(validator.validate('test').isValid, true);
      expect(validator.validate('').isValid, true);
      expect(validator.validate(null).isValid, true);
      expect(validator.validate('   ').isValid, true);
    });

    test('should validate minimum length', () {
      const validator = StringValidator(fieldName: 'Name', minLength: 3);

      expect(validator.validate('test').isValid, true);
      expect(validator.validate('ab').isValid, false);
      expect(validator.validate('abc').isValid, true);
    });

    test('should validate maximum length', () {
      const validator = StringValidator(fieldName: 'Name', maxLength: 5);

      expect(validator.validate('test').isValid, true);
      expect(validator.validate('toolong').isValid, false);
      expect(validator.validate('exact').isValid, true);
    });

    test('should validate pattern', () {
      final validator = StringValidator(
        fieldName: 'Code',
        pattern: RegExp(r'^[A-Z]{3}$'),
      );

      expect(validator.validate('ABC').isValid, true);
      expect(validator.validate('abc').isValid, false);
      expect(validator.validate('ABCD').isValid, false);
      expect(validator.validate('AB').isValid, false);
    });

    test('should provide custom error message', () {
      const validator = StringValidator(
        fieldName: 'Code',
        customMessage: 'Invalid code format',
      );

      final result = validator.validate('');
      expect(result.isValid, false);
      expect(result.errors.first, 'Invalid code format');
    });

    test('should trim whitespace', () {
      const validator = StringValidator(fieldName: 'Name', minLength: 3);

      expect(validator.validate('  abc  ').isValid, true);
      expect(validator.validate('  ab  ').isValid, false);
    });
  });

  group('EmailValidator', () {
    test('should validate correct email addresses', () {
      final validator = EmailValidator();

      expect(validator.validate('test@example.com').isValid, true);
      expect(validator.validate('user.name@domain.co.uk').isValid, true);
      expect(validator.validate('user+tag@example.org').isValid, true);
    });

    test('should reject invalid email addresses', () {
      final validator = EmailValidator();

      expect(validator.validate('invalid').isValid, false);
      expect(validator.validate('test@').isValid, false);
      expect(validator.validate('@example.com').isValid, false);
      expect(validator.validate('test.example.com').isValid, false);
      expect(validator.validate('test@example').isValid, false);
    });

    test('should handle required vs optional', () {
      final requiredValidator = EmailValidator();
      final optionalValidator = EmailValidator(required: false);

      expect(requiredValidator.validate('').isValid, false);
      expect(optionalValidator.validate('').isValid, true);
      expect(requiredValidator.validate(null).isValid, false);
      expect(optionalValidator.validate(null).isValid, true);
    });
  });

  group('NumericValidator', () {
    test('should validate required numbers', () {
      const validator = NumericValidator(fieldName: 'Age');

      expect(validator.validate(25).isValid, true);
      expect(validator.validate(0).isValid, true);
      expect(validator.validate(null).isValid, false);
    });

    test('should validate optional numbers', () {
      const validator = NumericValidator(fieldName: 'Score', required: false);

      expect(validator.validate(100).isValid, true);
      expect(validator.validate(null).isValid, true);
    });

    test('should validate minimum value', () {
      const validator = NumericValidator(fieldName: 'Age', min: 18);

      expect(validator.validate(25).isValid, true);
      expect(validator.validate(18).isValid, true);
      expect(validator.validate(17).isValid, false);
    });

    test('should validate maximum value', () {
      const validator = NumericValidator(fieldName: 'Age', max: 65);

      expect(validator.validate(30).isValid, true);
      expect(validator.validate(65).isValid, true);
      expect(validator.validate(66).isValid, false);
    });

    test('should handle negative values', () {
      const allowNegative = NumericValidator(
        fieldName: 'Temperature',
      );
      const disallowNegative = NumericValidator(
        fieldName: 'Count',
        allowNegative: false,
      );

      expect(allowNegative.validate(-10).isValid, true);
      expect(disallowNegative.validate(-10).isValid, false);
      expect(disallowNegative.validate(10).isValid, true);
    });

    test('should handle zero values', () {
      const allowZero = NumericValidator(fieldName: 'Count');
      const disallowZero = NumericValidator(
        fieldName: 'Count',
        allowZero: false,
      );

      expect(allowZero.validate(0).isValid, true);
      expect(disallowZero.validate(0).isValid, false);
      expect(disallowZero.validate(1).isValid, true);
    });
  });

  group('DateValidator', () {
    test('should validate required dates', () {
      const validator = DateValidator(fieldName: 'Birthday');

      expect(validator.validate(DateTime.now()).isValid, true);
      expect(validator.validate(null).isValid, false);
    });

    test('should validate optional dates', () {
      const validator = DateValidator(fieldName: 'LastLogin', required: false);

      expect(validator.validate(DateTime.now()).isValid, true);
      expect(validator.validate(null).isValid, true);
    });

    test('should validate minimum date', () {
      final minDate = DateTime(2020);
      final validator = DateValidator(fieldName: 'StartDate', minDate: minDate);

      expect(validator.validate(DateTime(2021)).isValid, true);
      expect(validator.validate(DateTime(2020)).isValid, true);
      expect(validator.validate(DateTime(2019)).isValid, false);
    });

    test('should validate maximum date', () {
      final maxDate = DateTime(2025, 12, 31);
      final validator = DateValidator(fieldName: 'EndDate', maxDate: maxDate);

      expect(validator.validate(DateTime(2024)).isValid, true);
      expect(validator.validate(DateTime(2025, 12, 31)).isValid, true);
      expect(validator.validate(DateTime(2026)).isValid, false);
    });
  });

  group('ListValidator', () {
    test('should validate required lists', () {
      const validator = ListValidator<String>(
        fieldName: 'Items',
      );

      expect(validator.validate(['item1', 'item2']).isValid, true);
      expect(validator.validate(<String>[]).isValid, false);
      expect(validator.validate(null).isValid, false);
    });

    test('should validate optional lists', () {
      const validator = ListValidator<String>(
        fieldName: 'Items',
        required: false,
      );

      expect(validator.validate(['item1']).isValid, true);
      expect(validator.validate(<String>[]).isValid, true);
      expect(validator.validate(null).isValid, true);
    });

    test('should validate minimum length', () {
      const validator = ListValidator<String>(fieldName: 'Items', minLength: 2);

      expect(validator.validate(['item1', 'item2']).isValid, true);
      expect(validator.validate(['item1', 'item2', 'item3']).isValid, true);
      expect(validator.validate(['item1']).isValid, false);
    });

    test('should validate maximum length', () {
      const validator = ListValidator<String>(fieldName: 'Items', maxLength: 3);

      expect(validator.validate(['item1', 'item2']).isValid, true);
      expect(validator.validate(['item1', 'item2', 'item3']).isValid, true);
      expect(
        validator.validate(['item1', 'item2', 'item3', 'item4']).isValid,
        false,
      );
    });

    test('should validate individual items', () {
      const itemValidator = StringValidator(fieldName: 'Item', minLength: 3);
      const validator = ListValidator<String>(
        fieldName: 'Items',
        itemValidator: itemValidator,
      );

      expect(validator.validate(['item1', 'item2']).isValid, true);
      expect(validator.validate(['item1', 'ab']).isValid, false);
    });
  });

  group('ValidationHelper', () {
    test('should validate and throw on failure', () {
      const result = ValidationResult.failure(['Error message']);

      expect(
        () => ValidationHelper.validateAndThrow(result),
        throwsA(isA<DataValidationException>()),
      );
    });

    test('should not throw on success', () {
      const result = ValidationResult.success();

      expect(() => ValidationHelper.validateAndThrow(result), returnsNormally);
    });

    test('should validate multiple fields', () {
      final fieldResults = {
        'name': const ValidationResult.success(),
        'email': const ValidationResult.failure(['Invalid email']),
        'age': const ValidationResult.failure(['Age required']),
      };

      final combined = ValidationHelper.validateFields(fieldResults);

      expect(combined.isValid, false);
      expect(combined.errors, ['Invalid email', 'Age required']);
    });

    test('should create habit name validator', () {
      final validator = ValidationHelper.habitNameValidator();

      expect(validator.validate('My Habit').isValid, true);
      expect(validator.validate('').isValid, false);
      expect(validator.validate('A' * 101).isValid, false);
    });

    test('should create habit description validator', () {
      final validator = ValidationHelper.habitDescriptionValidator();

      expect(validator.validate('Description').isValid, true);
      expect(validator.validate('').isValid, true);
      expect(validator.validate(null).isValid, true);
      expect(validator.validate('A' * 501).isValid, false);
    });

    test('should create XP validator', () {
      final validator = ValidationHelper.xpValidator();

      expect(validator.validate(100).isValid, true);
      expect(validator.validate(0).isValid, true);
      expect(validator.validate(-10).isValid, false);
      expect(validator.validate(null).isValid, false);
    });

    test('should create level validator', () {
      final validator = ValidationHelper.levelValidator();

      expect(validator.validate(5).isValid, true);
      expect(validator.validate(1).isValid, true);
      expect(validator.validate(100).isValid, true);
      expect(validator.validate(0).isValid, false);
      expect(validator.validate(101).isValid, false);
    });

    test('should create streak validator', () {
      final validator = ValidationHelper.streakValidator();

      expect(validator.validate(10).isValid, true);
      expect(validator.validate(0).isValid, true);
      expect(validator.validate(-1).isValid, false);
    });
  });
}
