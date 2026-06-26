import 'product_lookup_result.dart';

abstract class ProductRepository {
  Future<ProductLookupResult> lookupByBarcode(String barcode);
}