import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/product_lookup/data/api/open_food_facts_response.dart';
import 'package:whoownsit/features/product_lookup/data/repository/open_food_facts_product_repository.dart';
import 'package:whoownsit/features/product_lookup/domain/product_lookup_result.dart';
import 'package:whoownsit/features/product_lookup/data/api/product_lookup_api_client.dart';

class FakeOpenFoodFactsClient implements ProductLookupApiClient {
  const FakeOpenFoodFactsClient(this.response);

  final OpenFoodFactsResponse response;

  @override
  Future<OpenFoodFactsResponse> lookupProduct(String barcode) async {
    return response;
  }
}

void main() {
  group('OpenFoodFactsProductRepository', () {
    test('returns ProductFound when product exists', () async {
      final client = FakeOpenFoodFactsClient(
        const OpenFoodFactsResponse(
          data: {
            'status': 1,
            'code': '7613036242925',
            'product': {
              'product_name': 'KitKat',
              'brands': 'KitKat, Nestlé',
              'image_front_url': 'https://example.com/image.jpg',
            },
          },
        ),
      );

      final repository = OpenFoodFactsProductRepository(
        client: client,
      );

      final result = await repository.lookupByBarcode('7613036242925');

      expect(result, isA<ProductFound>());

      final found = result as ProductFound;
      expect(found.product.name, 'KitKat');
      expect(found.product.brandNames, ['KitKat', 'Nestlé']);
    });

    test('returns ProductNotFound when Open Food Facts status is 0', () async {
      final client = FakeOpenFoodFactsClient(
        const OpenFoodFactsResponse(
          data: {
            'status': 0,
            'code': '0000000000000',
          },
        ),
      );

      final repository = OpenFoodFactsProductRepository(
        client: client,
      );

      final result = await repository.lookupByBarcode('0000000000000');

      expect(result, isA<ProductNotFound>());
    });
  });
}