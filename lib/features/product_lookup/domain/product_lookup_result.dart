import 'product.dart';

sealed class ProductLookupResult {
  const ProductLookupResult();
}

class ProductFound extends ProductLookupResult {
  const ProductFound(this.product);

  final Product product;
}

class ProductNotFound extends ProductLookupResult {
  const ProductNotFound();
}

class ProductLookupFailure extends ProductLookupResult {
  const ProductLookupFailure(this.message);

  final String message;
}