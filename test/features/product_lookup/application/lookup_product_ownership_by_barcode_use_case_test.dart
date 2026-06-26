import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/application/determine_ownership_use_case.dart';
import 'package:whoownsit/features/ownership/domain/brand.dart';
import 'package:whoownsit/features/ownership/domain/company.dart';
import 'package:whoownsit/features/ownership/domain/ownership_repository.dart';
import 'package:whoownsit/features/ownership/domain/ownership_result_status.dart';
import 'package:whoownsit/features/ownership/domain/ownership_source.dart';
import 'package:whoownsit/features/ownership/domain/relationship_type.dart';
import 'package:whoownsit/features/ownership/domain/verification_status.dart';
import 'package:whoownsit/features/product_lookup/application/lookup_product_by_barcode_use_case.dart';
import 'package:whoownsit/features/product_lookup/application/lookup_product_ownership_by_barcode_use_case.dart';
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

class FakeOwnershipRepository implements OwnershipRepository {
  const FakeOwnershipRepository({
    required this.companies,
    required this.brands,
    this.sources = const [],
  });

  final List<Company> companies;
  final List<Brand> brands;
  final List<OwnershipSource> sources;

  @override
  Future<List<Company>> getCompanies() async => companies;

  @override
  Future<List<Brand>> getBrands() async => brands;

  @override
  Future<List<OwnershipSource>> getSources() async => sources;
}

void main() {
  group('LookupProductOwnershipByBarcodeUseCase', () {
    final nestle = Company(
      id: 'company_nestle_sa',
      name: 'Nestlé S.A.',
      aliases: const ['Nestle', 'Nestlé'],
      countryCode: 'CH',
      website: 'https://www.nestle.com',
    );

    final kitKat = Brand(
      id: 'brand_kitkat',
      name: 'KitKat',
      aliases: const ['Kit Kat', 'KITKAT'],
      normalizedNames: const ['kitkat', 'kit kat'],
      ownerCompanyId: 'company_nestle_sa',
      relationshipType: RelationshipType.ownedBy,
      verificationStatus: VerificationStatus.maintainerVerified,
      sourceIds: const ['source_nestle_brands_page'],
      effectiveFrom: DateTime(1988),
      effectiveTo: null,
      markets: const [],
    );

    LookupProductOwnershipByBarcodeUseCase buildUseCase(
      ProductLookupResult productResult,
    ) {
      final productUseCase = LookupProductByBarcodeUseCase(
        productRepository: FakeProductRepository(productResult),
      );

      final ownershipUseCase = DetermineOwnershipUseCase(
        ownershipRepository: FakeOwnershipRepository(
          companies: [nestle],
          brands: [kitKat],
        ),
      );

      return LookupProductOwnershipByBarcodeUseCase(
        lookupProductByBarcodeUseCase: productUseCase,
        determineOwnershipUseCase: ownershipUseCase,
      );
    }

    test('returns ownedByTarget when product brand matches ownership data', () async {
      final useCase = buildUseCase(
        const ProductFound(
          Product(
            barcode: '7613036242925',
            name: 'KitKat',
            brandNames: ['KitKat'],
          ),
        ),
      );

      final result = await useCase.execute('7613036242925');

      expect(result.status, OwnershipResultStatus.ownedByTarget);
      expect(result.matchedBrandName, 'KitKat');
      expect(result.ownerCompanyName, 'Nestlé S.A.');
    });

    test('returns productNotFound when product lookup fails to find product', () async {
      final useCase = buildUseCase(const ProductNotFound());

      final result = await useCase.execute('0000000000000');

      expect(result.status, OwnershipResultStatus.productNotFound);
      expect(result.message, 'Product was not found.');
    });

    test('returns unknown when product lookup fails with error', () async {
      final useCase = buildUseCase(
        const ProductLookupFailure('Network unavailable.'),
      );

      final result = await useCase.execute('7613036242925');

      expect(result.status, OwnershipResultStatus.unknown);
      expect(result.message, 'Network unavailable.');
    });

    test('returns brandNotFound when product has no brand names', () async {
      final useCase = buildUseCase(
        const ProductFound(
          Product(
            barcode: '7613036242925',
            name: 'Unknown Product',
            brandNames: [],
          ),
        ),
      );

      final result = await useCase.execute('7613036242925');

      expect(result.status, OwnershipResultStatus.brandNotFound);
    });
  });
}