import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:whoownsit/features/scan/domain/select_barcode_value.dart';

void main() {
  group('selectBarcodeValue', () {
    test('returns null when capture contains no barcodes', () {
      const capture = BarcodeCapture(barcodes: []);

      expect(selectBarcodeValue(capture), isNull);
    });

    test('returns null when raw value is null', () {
      const capture = BarcodeCapture(barcodes: [Barcode()]);

      expect(selectBarcodeValue(capture), isNull);
    });

    test('returns null when raw value contains only whitespace', () {
      const capture = BarcodeCapture(barcodes: [Barcode(rawValue: '   ')]);

      expect(selectBarcodeValue(capture), isNull);
    });

    test('returns the first valid barcode value', () {
      const capture = BarcodeCapture(
        barcodes: [
          Barcode(rawValue: '   '),
          Barcode(rawValue: '  7613035974685  '),
          Barcode(rawValue: '5000112637922'),
        ],
      );

      expect(selectBarcodeValue(capture), '7613035974685');
    });

    test('trims the returned barcode value', () {
      const capture = BarcodeCapture(
        barcodes: [Barcode(rawValue: '  4008400401620  ')],
      );

      expect(selectBarcodeValue(capture), '4008400401620');
    });
  });
}
