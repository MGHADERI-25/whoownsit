import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:whoownsit/features/product_lookup/presentation/manual_barcode_lookup_screen.dart';

class RecordingProductRepository implements ProductRepository {
  RecordingProductRepository({this.result = const ProductNotFound()});

  final ProductLookupResult result;
  final List<String> requestedBarcodes = [];

  @override
  Future<ProductLookupResult> lookupByBarcode(String barcode) async {
    requestedBarcodes.add(barcode);
    return result;
  }
}

class PendingProductRepository implements ProductRepository {
  final Completer<ProductLookupResult> completer =
      Completer<ProductLookupResult>();

  final List<String> requestedBarcodes = [];

  @override
  Future<ProductLookupResult> lookupByBarcode(String barcode) {
    requestedBarcodes.add(barcode);
    return completer.future;
  }
}

class FakeOwnershipRepository implements OwnershipRepository {
  const FakeOwnershipRepository({
    this.companies = const [],
    this.brands = const [],
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

LookupProductOwnershipByBarcodeUseCase buildLookupUseCase({
  required ProductRepository productRepository,
  OwnershipRepository ownershipRepository = const FakeOwnershipRepository(),
}) {
  final determineOwnershipUseCase = DetermineOwnershipUseCase(
    ownershipRepository: ownershipRepository,
  );

  return LookupProductOwnershipByBarcodeUseCase(
    lookupProductByBarcodeUseCase: LookupProductByBarcodeUseCase(
      productRepository: productRepository,
    ),
    determineOwnershipUseCase: determineOwnershipUseCase,
  );
}

Widget buildTestApp({
  required LookupProductOwnershipByBarcodeUseCase useCase,
  WidgetBuilder? barcodeScannerScreenBuilder,
}) {
  return MaterialApp(
    home: ManualBarcodeLookupScreen(
      lookupProductOwnershipByBarcodeUseCase: useCase,
      barcodeScannerScreenBuilder: barcodeScannerScreenBuilder,
    ),
  );
}

void main() {
  group('ManualBarcodeLookupScreen', () {
    testWidgets('does not perform lookup when barcode is empty', (
      tester,
    ) async {
      final repository = RecordingProductRepository();

      await tester.pumpWidget(
        buildTestApp(
          useCase: buildLookupUseCase(productRepository: repository),
        ),
      );

      await tester.tap(find.text('Lookup ownership'));
      await tester.pump();

      expect(repository.requestedBarcodes, isEmpty);
    });

    testWidgets('trims barcode before performing lookup', (tester) async {
      final repository = RecordingProductRepository();

      await tester.pumpWidget(
        buildTestApp(
          useCase: buildLookupUseCase(productRepository: repository),
        ),
      );

      await tester.enterText(find.byType(TextField), '  3017620422003  ');

      await tester.tap(find.text('Lookup ownership'));
      await tester.pumpAndSettle();

      expect(repository.requestedBarcodes, ['3017620422003']);
    });

    testWidgets('keyboard search action performs lookup', (tester) async {
      final repository = RecordingProductRepository();

      await tester.pumpWidget(
        buildTestApp(
          useCase: buildLookupUseCase(productRepository: repository),
        ),
      );

      await tester.enterText(find.byType(TextField), '3017620422003');

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(repository.requestedBarcodes, ['3017620422003']);
    });

    testWidgets('loading state disables lookup and scan actions', (
      tester,
    ) async {
      final repository = PendingProductRepository();

      await tester.pumpWidget(
        buildTestApp(
          useCase: buildLookupUseCase(productRepository: repository),
        ),
      );

      await tester.enterText(find.byType(TextField), '3017620422003');

      await tester.tap(find.text('Lookup ownership'));
      await tester.pump();

      expect(find.text('Looking up...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final lookupButton = tester.widget<FilledButton>(
        find.byType(FilledButton),
      );
      final scanButton = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );

      expect(lookupButton.onPressed, isNull);
      expect(scanButton.onPressed, isNull);

      repository.completer.complete(const ProductNotFound());
      await tester.pumpAndSettle();

      expect(find.text('Product not found'), findsOneWidget);
    });

    testWidgets('scanner result populates barcode and starts lookup', (
      tester,
    ) async {
      final repository = RecordingProductRepository();

      await tester.pumpWidget(
        buildTestApp(
          useCase: buildLookupUseCase(productRepository: repository),
          barcodeScannerScreenBuilder: (context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop('7613036242925');
                  },
                  child: const Text('Return barcode'),
                ),
              ),
            );
          },
        ),
      );

      await tester.tap(find.text('Scan barcode'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Return barcode'));
      await tester.pumpAndSettle();

      expect(repository.requestedBarcodes, ['7613036242925']);

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.controller?.text, '7613036242925');
    });

    testWidgets('cancelling scanner does not perform lookup', (tester) async {
      final repository = RecordingProductRepository();

      await tester.pumpWidget(
        buildTestApp(
          useCase: buildLookupUseCase(productRepository: repository),
          barcodeScannerScreenBuilder: (context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel scanner'),
                ),
              ),
            );
          },
        ),
      );

      await tester.tap(find.text('Scan barcode'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel scanner'));
      await tester.pumpAndSettle();

      expect(repository.requestedBarcodes, isEmpty);
    });

    testWidgets('renders ownership result details', (tester) async {
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

      final productRepository = RecordingProductRepository(
        result: const ProductFound(
          Product(
            barcode: '7613036242925',
            name: 'KitKat',
            brandNames: ['KitKat'],
          ),
        ),
      );

      await tester.pumpWidget(
        buildTestApp(
          useCase: buildLookupUseCase(
            productRepository: productRepository,
            ownershipRepository: FakeOwnershipRepository(
              companies: [company],
              brands: [brand],
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '7613036242925');

      await tester.tap(find.text('Lookup ownership'));
      await tester.pumpAndSettle();

      expect(find.text('Owned by Nestlé'), findsOneWidget);
      expect(find.text('KitKat'), findsOneWidget);
      expect(find.text('Nestlé S.A.'), findsOneWidget);
      expect(find.text('VERIFICATION'), findsOneWidget);
      expect(find.text('maintainerVerified'), findsOneWidget);
    });

    testWidgets('lookup may finish after screen is disposed', (tester) async {
      final repository = PendingProductRepository();

      await tester.pumpWidget(
        buildTestApp(
          useCase: buildLookupUseCase(productRepository: repository),
        ),
      );

      await tester.enterText(find.byType(TextField), '3017620422003');

      await tester.tap(find.text('Lookup ownership'));
      await tester.pump();

      expect(repository.requestedBarcodes, ['3017620422003']);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Replacement screen'))),
      );

      repository.completer.complete(const ProductNotFound());
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Replacement screen'), findsOneWidget);
    });
  });
}
