import 'open_food_facts_response.dart';

abstract class ProductLookupApiClient {
  Future<OpenFoodFactsResponse> lookupProduct(String barcode);
}