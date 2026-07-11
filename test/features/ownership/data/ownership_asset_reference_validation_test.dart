import 'package:flutter_test/flutter_test.dart';

import 'helpers/ownership_asset_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ownership asset reference validation', () {
    test('all brand ownerCompanyIds reference existing companies', () async {
      final database = await loadOwnershipDatabase();
      final companyIds = database.companies
          .map((company) => company.id)
          .toSet();

      for (final brand in database.brands) {
        expect(
          companyIds.contains(brand.ownerCompanyId),
          isTrue,
          reason:
              'Brand ${brand.id} references missing company '
              '${brand.ownerCompanyId}.',
        );
      }
    });

    test('all brand sourceIds reference existing sources', () async {
      final database = await loadOwnershipDatabase();
      final sourceIds = database.sources.map((source) => source.id).toSet();

      for (final brand in database.brands) {
        for (final sourceId in brand.sourceIds) {
          expect(
            sourceIds.contains(sourceId),
            isTrue,
            reason:
                'Brand ${brand.id} references missing source '
                '$sourceId.',
          );
        }
      }
    });

    test('company IDs are unique', () async {
      final database = await loadOwnershipDatabase();
      final ids = database.companies.map((company) => company.id).toList();

      expect(
        ids.toSet().length,
        ids.length,
        reason: 'Duplicate company IDs found in ownership assets.',
      );
    });

    test('brand IDs are unique', () async {
      final database = await loadOwnershipDatabase();
      final ids = database.brands.map((brand) => brand.id).toList();

      expect(
        ids.toSet().length,
        ids.length,
        reason: 'Duplicate brand IDs found in ownership assets.',
      );
    });

    test('source IDs are unique', () async {
      final database = await loadOwnershipDatabase();
      final ids = database.sources.map((source) => source.id).toList();

      expect(
        ids.toSet().length,
        ids.length,
        reason: 'Duplicate source IDs found in ownership assets.',
      );
    });

    test('brand normalized names are not shared by different brands', () async {
      final database = await loadOwnershipDatabase();
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
                'Normalized name "$name" is shared by '
                '$existingBrandId and ${brand.id}.',
          );

          ownersByNormalizedName[name] = brand.id;
        }
      }
    });
  });
}
