import 'package:dio/dio.dart';

import '../../domain/product_lookup_result.dart';
import '../../domain/product_repository.dart';
import '../api/product_lookup_api_client.dart';
import '../dto/open_food_facts_product_dto.dart';

class OpenFoodFactsProductRepository implements ProductRepository {
  const OpenFoodFactsProductRepository({required this.client});

  final ProductLookupApiClient client;

  @override
  Future<ProductLookupResult> lookupByBarcode(String barcode) async {
    try {
      final response = await client.lookupProduct(barcode);
      final status = response.data['status'];

      if (status == 0) {
        return const ProductNotFound();
      }

      final dto = OpenFoodFactsProductDto.fromJson(response.data);
      return ProductFound(dto.toDomain());
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return const ProductNotFound();
      }

      return ProductLookupFailure(
        'Product lookup failed. Please check your internet connection and try again.',
      );
    }
  }
}
