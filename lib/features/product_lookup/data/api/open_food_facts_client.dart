import 'package:dio/dio.dart';

import 'open_food_facts_api.dart';

class OpenFoodFactsClient {
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

  Future<Map<String, dynamic>> lookupProduct(String barcode) async {
    final response = await _dio.get<Map<String, dynamic>>(
      OpenFoodFactsApi.productLookupUrl(barcode),
    );

    final data = response.data;

    if (data == null) {
      throw const FormatException('Open Food Facts returned no data.');
    }

    return data;
  }
}