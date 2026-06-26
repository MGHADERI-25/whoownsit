import 'dart:io';
import 'package:whoownsit/features/product_lookup/application/lookup_product_by_barcode_use_case.dart';
import 'package:whoownsit/features/product_lookup/data/api/open_food_facts_client.dart';
import 'package:whoownsit/features/product_lookup/data/repository/open_food_facts_product_repository.dart';
import 'package:whoownsit/features/product_lookup/domain/product_lookup_result.dart';

Future<void> main(List<String> args) async {
  final barcode = args.isNotEmpty ? args.first : '7613036242925';

  final client = OpenFoodFactsClient();
  final repository = OpenFoodFactsProductRepository(client: client);
  final useCase = LookupProductByBarcodeUseCase(
    productRepository: repository,
  );

  final result = await useCase.execute(barcode);

  switch (result) {
    case ProductFound(:final product):
      stdout.writeln('Product found');
      stdout.writeln('Barcode: ${product.barcode}');
      stdout.writeln('Name: ${product.name}');
      stdout.writeln('Brands: ${product.brandNames.join(', ')}');
      stdout.writeln('Image: ${product.imageUrl}');
    case ProductNotFound():
      stdout.writeln('Product not found');
    case ProductLookupFailure(:final message):
      stdout.writeln('Lookup failed: $message');
  }
}