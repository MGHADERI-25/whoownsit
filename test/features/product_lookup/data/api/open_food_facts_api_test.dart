import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/product_lookup/data/api/open_food_facts_api.dart';

void main() {
  group('OpenFoodFactsApi', () {
    test('builds product lookup URL', () {
      const barcode = '7613036242925';

      final url = OpenFoodFactsApi.productLookupUrl(barcode);

      expect(
        url,
        'https://world.openfoodfacts.org/api/v2/product/7613036242925'
        '?fields=code,product_name,brands,image_front_url',
      );
    });
  });
}