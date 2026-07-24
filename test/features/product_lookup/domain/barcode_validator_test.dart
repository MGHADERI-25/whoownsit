import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/product_lookup/domain/barcode_validator.dart';

void main() {
  const validator = BarcodeValidator();

  group('BarcodeValidator', () {
    test('accepts an 8-digit barcode', () {
      final result = validator.validate('96385074');

      expect(result.isValid, isTrue);
      expect(result.sanitizedBarcode, '96385074');
      expect(result.errorMessage, isNull);
    });

    test('accepts a 12-digit barcode', () {
      final result = validator.validate('012345678905');

      expect(result.isValid, isTrue);
    });

    test('accepts a 13-digit barcode', () {
      final result = validator.validate('7613036242925');

      expect(result.isValid, isTrue);
    });

    test('accepts a 14-digit barcode', () {
      final result = validator.validate('12345678901231');

      expect(result.isValid, isTrue);
    });

    test('trims surrounding whitespace', () {
      final result = validator.validate('  7613036242925  ');

      expect(result.isValid, isTrue);
      expect(result.sanitizedBarcode, '7613036242925');
    });

    test('rejects an empty barcode', () {
      final result = validator.validate('   ');

      expect(result.isValid, isFalse);
      expect(result.errorMessage, 'Barcode cannot be empty.');
    });

    test('rejects letters', () {
      final result = validator.validate('761303ABC2925');

      expect(result.isValid, isFalse);
      expect(result.errorMessage, 'Barcode must contain digits only.');
    });

    test('rejects punctuation', () {
      final result = validator.validate('761303-6242925');

      expect(result.isValid, isFalse);
      expect(result.errorMessage, 'Barcode must contain digits only.');
    });

    test('rejects unsupported barcode lengths', () {
      final result = validator.validate('1234567890');

      expect(result.isValid, isFalse);
      expect(
        result.errorMessage,
        'Barcode must contain 8, 12, 13, or 14 digits.',
      );
    });
  });
}
