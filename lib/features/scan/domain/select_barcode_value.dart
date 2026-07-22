import 'package:mobile_scanner/mobile_scanner.dart';

String? selectBarcodeValue(BarcodeCapture capture) {
  for (final barcode in capture.barcodes) {
    final value = barcode.rawValue?.trim();

    if (value != null && value.isNotEmpty) {
      return value;
    }
  }

  return null;
}
