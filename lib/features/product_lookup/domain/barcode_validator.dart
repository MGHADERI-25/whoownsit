class BarcodeValidationResult {
  const BarcodeValidationResult._({
    required this.sanitizedBarcode,
    this.errorMessage,
  });

  const BarcodeValidationResult.valid(String sanitizedBarcode)
    : this._(sanitizedBarcode: sanitizedBarcode);

  const BarcodeValidationResult.invalid(
    String sanitizedBarcode,
    String errorMessage,
  ) : this._(sanitizedBarcode: sanitizedBarcode, errorMessage: errorMessage);

  final String sanitizedBarcode;
  final String? errorMessage;

  bool get isValid => errorMessage == null;
}

class BarcodeValidator {
  const BarcodeValidator();

  static const Set<int> supportedLengths = {8, 12, 13, 14};

  BarcodeValidationResult validate(String barcode) {
    final sanitizedBarcode = barcode.trim();

    if (sanitizedBarcode.isEmpty) {
      return const BarcodeValidationResult.invalid(
        '',
        'Barcode cannot be empty.',
      );
    }

    if (!RegExp(r'^\d+$').hasMatch(sanitizedBarcode)) {
      return BarcodeValidationResult.invalid(
        sanitizedBarcode,
        'Barcode must contain digits only.',
      );
    }

    if (!supportedLengths.contains(sanitizedBarcode.length)) {
      return BarcodeValidationResult.invalid(
        sanitizedBarcode,
        'Barcode must contain 8, 12, 13, or 14 digits.',
      );
    }

    return BarcodeValidationResult.valid(sanitizedBarcode);
  }
}
