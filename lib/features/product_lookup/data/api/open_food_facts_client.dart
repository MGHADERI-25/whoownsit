import 'package:dio/dio.dart';

import 'open_food_facts_api.dart';
import 'open_food_facts_response.dart';
import 'product_lookup_api_client.dart';

class OpenFoodFactsClient implements ProductLookupApiClient {
  OpenFoodFactsClient({
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                sendTimeout: const Duration(seconds: 10),
                responseType: ResponseType.json,
              ),
            );

  final Dio _dio;

  @override
  Future<OpenFoodFactsResponse> lookupProduct(String barcode) async {
    final response = await _dio.get<Map<String, dynamic>>(
      OpenFoodFactsApi.productLookupUrl(barcode),
    );

    final data = response.data;

    if (data == null) {
      throw const FormatException('Open Food Facts returned no data.');
    }

    return OpenFoodFactsResponse(data: data);
  }
}