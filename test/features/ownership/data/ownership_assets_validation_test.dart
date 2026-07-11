import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/data/ownership_database_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ownership asset validation', () {
    test('bundled ownership assets load successfully', () async {
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();

      expect(database.companies, isNotEmpty);
      expect(database.brands, isNotEmpty);
      expect(database.sources, isNotEmpty);
    });

    test('all brand ownerCompanyIds reference existing companies', () async {
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();
      final companyIds = database.companies
          .map((company) => company.id)
          .toSet();

      for (final brand in database.brands) {
        expect(
          companyIds.contains(brand.ownerCompanyId),
          isTrue,
          reason:
              'Brand ${brand.id} references missing company ${brand.ownerCompanyId}',
        );
      }
    });

    test('company IDs are unique', () async {
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();
      final ids = database.companies.map((company) => company.id).toList();

      expect(
        ids.toSet().length,
        ids.length,
        reason: 'Duplicate company IDs found in ownership assets.',
      );
    });

    test('brand IDs are unique', () async {
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();
      final ids = database.brands.map((brand) => brand.id).toList();

      expect(
        ids.toSet().length,
        ids.length,
        reason: 'Duplicate brand IDs found in ownership assets.',
      );
    });

    test('source IDs are unique', () async {
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();
      final ids = database.sources.map((source) => source.id).toList();

      expect(
        ids.toSet().length,
        ids.length,
        reason: 'Duplicate source IDs found in ownership assets.',
      );
    });

    test('brand normalized names are not shared by different brands', () async {
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();
      final ownersByNormalizedName = <String, String>{};

      for (final brand in database.brands) {
        final names = <String>{
          brand.name.trim().toLowerCase(),
          ...brand.aliases.map((value) => value.trim().toLowerCase()),
          ...brand.normalizedNames.map((value) => value.trim().toLowerCase()),
        };

        for (final name in names.where((value) => value.isNotEmpty)) {
          final existingBrandId = ownersByNormalizedName[name];

          expect(
            existingBrandId == null || existingBrandId == brand.id,
            isTrue,
            reason:
                'Normalized name "$name" is shared by $existingBrandId and ${brand.id}.',
          );

          ownersByNormalizedName[name] = brand.id;
        }
      }
    });

    test('all brand sourceIds reference existing sources', () async {
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();
      final sourceIds = database.sources.map((source) => source.id).toSet();

      for (final brand in database.brands) {
        for (final sourceId in brand.sourceIds) {
          expect(
            sourceIds.contains(sourceId),
            isTrue,
            reason: 'Brand ${brand.id} references missing source $sourceId',
          );
        }
      }
    });
  });
}
