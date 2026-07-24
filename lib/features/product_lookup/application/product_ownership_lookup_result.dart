import '../../ownership/domain/ownership_result.dart';
import '../domain/product.dart';

class ProductOwnershipLookupResult {
  const ProductOwnershipLookupResult({
    required this.product,
    required this.ownership,
  });

  final Product? product;
  final OwnershipResult ownership;
}
