import '../domain/product_lookup_result.dart';
import '../domain/product_repository.dart';

class LookupProductByBarcodeUseCase {
  const LookupProductByBarcodeUseCase({
    required this.productRepository,
  });

  final ProductRepository productRepository;

  Future<ProductLookupResult> execute(String barcode) async {
    final sanitizedBarcode = barcode.trim();

    if (sanitizedBarcode.isEmpty) {
      return const ProductLookupFailure('Barcode cannot be empty.');
    }

    return productRepository.lookupByBarcode(sanitizedBarcode);
  }
}