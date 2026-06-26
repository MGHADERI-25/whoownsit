import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/product_lookup/application/lookup_product_by_barcode_use_case.dart';
import 'package:whoownsit/features/product_lookup/domain/product.dart';
import 'package:whoownsit/features/product_lookup/domain/product_lookup_result.dart';
import 'package:whoownsit/features/product_lookup/domain/product_repository.dart';

class FakeProductRepository implements ProductRepository {
  const FakeProductRepository(this.result);

  final ProductLookupResult result;

  @override
  Future<ProductLookupResult> lookupByBarcode(String barcode) async {
    return result;
  }
}

void main() {
  group('LookupProductByBarcodeUseCase', () {
    test('returns failure when barcode is empty', () async {
      final useCase = LookupProductByBarcodeUseCase(
        productRepository: FakeProductRepository(
          ProductFound(
            Product(
              barcode: '7613036242925',
              name: 'KitKat',
              brandNames: const ['KitKat'],
            ),
          ),
        ),
      );

      final result = await useCase.execute('   ');

      expect(result, isA<ProductLookupFailure>());
      expect(
        (result as ProductLookupFailure).message,
        'Barcode cannot be empty.',
      );
    });

    test('trims barcode before lookup', () async {
      final repository = RecordingProductRepository(
        const ProductNotFound(),
      );

      final useCase = LookupProductByBarcodeUseCase(
        productRepository: repository,
      );

      await useCase.execute('  7613036242925  ');

      expect(repository.lastBarcode, '7613036242925');
    });

    test('returns repository result', () async {
      const expectedProduct = Product(
        barcode: '7613036242925',
        name: 'KitKat',
        brandNames: ['KitKat'],
      );

      final useCase = LookupProductByBarcodeUseCase(
        productRepository: FakeProductRepository(
          const ProductFound(expectedProduct),
        ),
      );

      final result = await useCase.execute('7613036242925');

      expect(result, isA<ProductFound>());
      expect((result as ProductFound).product.name, 'KitKat');
    });
  });
}

class RecordingProductRepository implements ProductRepository {
  RecordingProductRepository(this.result);

  final ProductLookupResult result;
  String? lastBarcode;

  @override
  Future<ProductLookupResult> lookupByBarcode(String barcode) async {
    lastBarcode = barcode;
    return result;
  }
}