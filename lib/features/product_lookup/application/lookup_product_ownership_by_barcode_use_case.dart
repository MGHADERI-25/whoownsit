import '../../ownership/application/determine_ownership_use_case.dart';
import '../../ownership/domain/ownership_result.dart';
import '../../ownership/domain/ownership_result_status.dart';
import '../domain/product_lookup_result.dart';
import 'lookup_product_by_barcode_use_case.dart';
import 'product_ownership_lookup_result.dart';

class LookupProductOwnershipByBarcodeUseCase {
  const LookupProductOwnershipByBarcodeUseCase({
    required this.lookupProductByBarcodeUseCase,
    required this.determineOwnershipUseCase,
  });

  final LookupProductByBarcodeUseCase lookupProductByBarcodeUseCase;
  final DetermineOwnershipUseCase determineOwnershipUseCase;

  Future<ProductOwnershipLookupResult> execute(String barcode) async {
    final productLookupResult = await lookupProductByBarcodeUseCase.execute(
      barcode,
    );

    return switch (productLookupResult) {
      ProductFound(:final product) => ProductOwnershipLookupResult(
        product: product,
        ownership: await determineOwnershipUseCase.execute(
          brandNames: product.brandNames,
        ),
      ),
      ProductNotFound() => const ProductOwnershipLookupResult(
        product: null,
        ownership: OwnershipResult(
          status: OwnershipResultStatus.productNotFound,
          message: 'Product was not found.',
        ),
      ),
      ProductLookupFailure(:final message) => ProductOwnershipLookupResult(
        product: null,
        ownership: OwnershipResult(
          status: OwnershipResultStatus.unknown,
          message: message,
        ),
      ),
    };
  }
}
