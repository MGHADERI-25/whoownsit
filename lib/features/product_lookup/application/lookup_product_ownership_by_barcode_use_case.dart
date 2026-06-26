import '../../ownership/application/determine_ownership_use_case.dart';
import '../../ownership/domain/ownership_result.dart';
import '../../ownership/domain/ownership_result_status.dart';
import '../domain/product_lookup_result.dart';
import 'lookup_product_by_barcode_use_case.dart';

class LookupProductOwnershipByBarcodeUseCase {
  const LookupProductOwnershipByBarcodeUseCase({
    required this.lookupProductByBarcodeUseCase,
    required this.determineOwnershipUseCase,
  });

  final LookupProductByBarcodeUseCase lookupProductByBarcodeUseCase;
  final DetermineOwnershipUseCase determineOwnershipUseCase;

  Future<OwnershipResult> execute(String barcode) async {
    final productLookupResult = await lookupProductByBarcodeUseCase.execute(
      barcode,
    );

    return switch (productLookupResult) {
      ProductFound(:final product) => determineOwnershipUseCase.execute(
          brandNames: product.brandNames,
        ),
      ProductNotFound() => const OwnershipResult(
          status: OwnershipResultStatus.productNotFound,
          message: 'Product was not found.',
        ),
      ProductLookupFailure(:final message) => OwnershipResult(
          status: OwnershipResultStatus.unknown,
          message: message,
        ),
    };
  }
}