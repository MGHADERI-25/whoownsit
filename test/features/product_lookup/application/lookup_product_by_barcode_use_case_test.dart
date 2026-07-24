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

class RecordingProductRepository implements ProductRepository {
  RecordingProductRepository(this.result);

  final ProductLookupResult result;
  String? lastBarcode;
  int callCount = 0;

  @override
  Future<ProductLookupResult> lookupByBarcode(String barcode) async {
    callCount++;
    lastBarcode = barcode;
    return result;
  }
}

void main() {
  group('LookupProductByBarcodeUseCase', () {
    test('returns failure when barcode is empty', () async {
      final repository = RecordingProductRepository(const ProductNotFound());

      final useCase = LookupProductByBarcodeUseCase(
        productRepository: repository,
      );

      final result = await useCase.execute('   ');

      expect(result, isA<ProductLookupFailure>());
      expect(
        (result as ProductLookupFailure).message,
        'Barcode cannot be empty.',
      );
      expect(repository.callCount, 0);
    });

    test(
      'returns failure when barcode contains non-digit characters',
      () async {
        final repository = RecordingProductRepository(const ProductNotFound());

        final useCase = LookupProductByBarcodeUseCase(
          productRepository: repository,
        );

        final result = await useCase.execute('761303ABC2925');

        expect(result, isA<ProductLookupFailure>());
        expect(
          (result as ProductLookupFailure).message,
          'Barcode must contain digits only.',
        );
        expect(repository.callCount, 0);
      },
    );

    test('returns failure when barcode length is unsupported', () async {
      final repository = RecordingProductRepository(const ProductNotFound());

      final useCase = LookupProductByBarcodeUseCase(
        productRepository: repository,
      );

      final result = await useCase.execute('1234567890');

      expect(result, isA<ProductLookupFailure>());
      expect(
        (result as ProductLookupFailure).message,
        'Barcode must contain 8, 12, 13, or 14 digits.',
      );
      expect(repository.callCount, 0);
    });

    test('trims barcode before lookup', () async {
      final repository = RecordingProductRepository(const ProductNotFound());

      final useCase = LookupProductByBarcodeUseCase(
        productRepository: repository,
      );

      await useCase.execute('  7613036242925  ');

      expect(repository.lastBarcode, '7613036242925');
      expect(repository.callCount, 1);
    });

    test('returns repository result for a valid barcode', () async {
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
