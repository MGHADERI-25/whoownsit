class OpenFoodFactsApi {
  const OpenFoodFactsApi._();

  static const String baseUrl =
      'https://world.openfoodfacts.org/api/v2';

  static const String productFields =
      'code,product_name,brands,image_front_url';

  static String productLookupUrl(String barcode) {
    return '$baseUrl/product/$barcode.json?fields=$productFields';
  }
}