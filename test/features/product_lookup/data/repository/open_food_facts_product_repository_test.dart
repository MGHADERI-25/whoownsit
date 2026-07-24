import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/product_lookup/data/api/open_food_facts_response.dart';
import 'package:whoownsit/features/product_lookup/data/api/product_lookup_api_client.dart';
import 'package:whoownsit/features/product_lookup/data/repository/open_food_facts_product_repository.dart';
import 'package:whoownsit/features/product_lookup/domain/product_lookup_result.dart';

class FakeOpenFoodFactsClient implements ProductLookupApiClient {
  const FakeOpenFoodFactsClient(this.response);

  final OpenFoodFactsResponse response;

  @override
  Future<OpenFoodFactsResponse> lookupProduct(String barcode) async {
    return response;
  }
}

class ThrowingOpenFoodFactsClient implements ProductLookupApiClient {
  const ThrowingOpenFoodFactsClient(this.error);

  final Object error;

  @override
  Future<OpenFoodFactsResponse> lookupProduct(String barcode) async {
    throw error;
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

      final repository = OpenFoodFactsProductRepository(client: client);

      final result = await repository.lookupByBarcode('7613036242925');

      expect(result, isA<ProductFound>());

      final found = result as ProductFound;
      expect(found.product.name, 'KitKat');
      expect(found.product.brandNames, ['KitKat', 'Nestlé']);
    });

    test('returns ProductNotFound when Open Food Facts status is 0', () async {
      final client = FakeOpenFoodFactsClient(
        const OpenFoodFactsResponse(
          data: {'status': 0, 'code': '0000000000000'},
        ),
      );

      final repository = OpenFoodFactsProductRepository(client: client);

      final result = await repository.lookupByBarcode('0000000000000');

      expect(result, isA<ProductNotFound>());
    });

    test('returns ProductNotFound when API returns 404', () async {
      final requestOptions = RequestOptions(
        path: '/api/v2/product/0000000000000.json',
      );

      final client = ThrowingOpenFoodFactsClient(
        DioException(
          requestOptions: requestOptions,
          response: Response<void>(
            requestOptions: requestOptions,
            statusCode: 404,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final repository = OpenFoodFactsProductRepository(client: client);

      final result = await repository.lookupByBarcode('0000000000000');

      expect(result, isA<ProductNotFound>());
    });

    test('returns ProductLookupFailure for network errors', () async {
      final client = ThrowingOpenFoodFactsClient(
        DioException(
          requestOptions: RequestOptions(
            path: '/api/v2/product/7613036242925.json',
          ),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final repository = OpenFoodFactsProductRepository(client: client);

      final result = await repository.lookupByBarcode('7613036242925');

      expect(result, isA<ProductLookupFailure>());

      final failure = result as ProductLookupFailure;
      expect(
        failure.message,
        'Product lookup failed. Please check your internet connection and try again.',
      );
    });

    test(
      'returns ProductLookupFailure when product object is missing',
      () async {
        final client = FakeOpenFoodFactsClient(
          const OpenFoodFactsResponse(
            data: {'status': 1, 'code': '7613036242925'},
          ),
        );

        final repository = OpenFoodFactsProductRepository(client: client);

        final result = await repository.lookupByBarcode('7613036242925');

        expect(result, isA<ProductLookupFailure>());

        final failure = result as ProductLookupFailure;
        expect(
          failure.message,
          'Received an invalid response from the product database.',
        );
      },
    );

    test(
      'returns ProductLookupFailure when client throws FormatException',
      () async {
        const client = ThrowingOpenFoodFactsClient(
          FormatException('Open Food Facts returned no data.'),
        );

        final repository = OpenFoodFactsProductRepository(client: client);

        final result = await repository.lookupByBarcode('7613036242925');

        expect(result, isA<ProductLookupFailure>());

        final failure = result as ProductLookupFailure;
        expect(
          failure.message,
          'Received an invalid response from the product database.',
        );
      },
    );
  });
}
