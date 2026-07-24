import '../domain/barcode_validator.dart';
import '../domain/product_lookup_result.dart';
import '../domain/product_repository.dart';

class LookupProductByBarcodeUseCase {
  const LookupProductByBarcodeUseCase({
    required this.productRepository,
    this.barcodeValidator = const BarcodeValidator(),
  });

  final ProductRepository productRepository;
  final BarcodeValidator barcodeValidator;

  Future<ProductLookupResult> execute(String barcode) async {
    final validationResult = barcodeValidator.validate(barcode);

    if (!validationResult.isValid) {
      return ProductLookupFailure(validationResult.errorMessage!);
    }

    return productRepository.lookupByBarcode(validationResult.sanitizedBarcode);
  }
}
