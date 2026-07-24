import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/app/app.dart';
import 'package:whoownsit/app/app_dependencies.dart';
import 'package:whoownsit/features/ownership/application/determine_ownership_use_case.dart';
import 'package:whoownsit/features/ownership/domain/brand.dart';
import 'package:whoownsit/features/ownership/domain/company.dart';
import 'package:whoownsit/features/ownership/domain/ownership_repository.dart';
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
  });

  final List<Company> companies;
  final List<Brand> brands;

  @override
  Future<List<Company>> getCompanies() async => companies;

  @override
  Future<List<Brand>> getBrands() async => brands;

  @override
  Future<List<OwnershipSource>> getSources() async => const [];
}

void main() {
  testWidgets('WhoOwnsIt app loads manual barcode lookup screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WhoOwnsItApp());

    expect(find.text('WhoOwnsIt'), findsOneWidget);
    expect(find.text('Barcode'), findsOneWidget);
    expect(find.text('Lookup ownership'), findsOneWidget);
  });

  testWidgets('WhoOwnsIt app uses injected dependencies for lookup', (
    WidgetTester tester,
  ) async {
    final company = Company(
      id: 'company_nestle_sa',
      name: 'Nestlé S.A.',
      aliases: const ['Nestle', 'Nestlé'],
      countryCode: 'CH',
      website: 'https://www.nestle.com',
    );

    final brand = Brand(
      id: 'brand_kitkat',
      name: 'KitKat',
      aliases: const ['Kit Kat'],
      normalizedNames: const ['kitkat', 'kit kat'],
      ownerCompanyId: company.id,
      relationshipType: RelationshipType.ownedBy,
      verificationStatus: VerificationStatus.maintainerVerified,
      sourceIds: const [],
      effectiveFrom: DateTime(1988),
      effectiveTo: null,
      markets: const [],
    );

    const productRepository = FakeProductRepository(
      ProductFound(
        Product(
          barcode: '3017620422003',
          name: 'KitKat',
          brandNames: ['KitKat'],
        ),
      ),
    );

    final ownershipRepository = FakeOwnershipRepository(
      companies: [company],
      brands: [brand],
    );

    final determineOwnershipUseCase = DetermineOwnershipUseCase(
      ownershipRepository: ownershipRepository,
    );

    final lookupProductByBarcodeUseCase = LookupProductByBarcodeUseCase(
      productRepository: productRepository,
    );

    final dependencies = AppDependencies(
      determineOwnershipUseCase: determineOwnershipUseCase,
      lookupProductOwnershipByBarcodeUseCase:
          LookupProductOwnershipByBarcodeUseCase(
            lookupProductByBarcodeUseCase: lookupProductByBarcodeUseCase,
            determineOwnershipUseCase: determineOwnershipUseCase,
          ),
    );

    await tester.pumpWidget(WhoOwnsItApp(dependencies: dependencies));

    await tester.enterText(find.byType(TextField), '3017620422003');

    await tester.tap(find.text('Lookup ownership'));
    await tester.pumpAndSettle();

    expect(find.text('Owned by Nestlé'), findsOneWidget);
    expect(find.text('KitKat'), findsWidgets);
    expect(find.text('Nestlé S.A.'), findsOneWidget);
  });
}
