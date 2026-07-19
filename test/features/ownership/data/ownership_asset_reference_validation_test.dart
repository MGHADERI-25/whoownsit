import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/domain/brand_name_normalizer.dart';
import 'helpers/ownership_asset_test_helpers.dart';
import 'package:whoownsit/features/ownership/domain/relationship_type.dart';

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

    test('current ownership records have consistent relationships', () async {
      final database = await loadOwnershipDatabase();

      for (final brand in database.brands) {
        expect(
          brand.relationshipType == RelationshipType.unknown,
          isFalse,
          reason: 'Brand ${brand.id} uses an unknown relationship type.',
        );

        if (brand.relationshipType == RelationshipType.notOwnedBy) {
          expect(
            brand.ownerCompanyId == 'company_nestle_sa',
            isTrue,
            reason:
                'Brand ${brand.id} uses notOwnedBy but does not reference '
                'the target company.',
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

    test('searchable brand names are not shared by different brands', () async {
      const normalizer = BrandNameNormalizer();
      final database = await loadOwnershipDatabase();
      final ownersByNormalizedName = <String, String>{};

      for (final brand in database.brands) {
        final normalizedNames = <String>{
          normalizer.normalize(brand.name),
          ...brand.aliases.map(normalizer.normalize),
          ...brand.normalizedNames.map(normalizer.normalize),
        }..removeWhere((value) => value.isEmpty);

        for (final normalizedName in normalizedNames) {
          final existingBrandId = ownersByNormalizedName[normalizedName];

          expect(
            existingBrandId == null || existingBrandId == brand.id,
            isTrue,
            reason:
                'Searchable name "$normalizedName" is shared by '
                '$existingBrandId and ${brand.id}.',
          );

          ownersByNormalizedName[normalizedName] = brand.id;
        }
      }
    });
  });
}
