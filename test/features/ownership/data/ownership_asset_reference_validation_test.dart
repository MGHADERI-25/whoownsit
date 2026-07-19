import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/domain/brand_name_normalizer.dart';
import 'helpers/ownership_asset_test_helpers.dart';
import 'package:whoownsit/features/ownership/domain/relationship_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ownership asset reference validation', () {
    test('brand ownerCompanyIds reference existing companies', () async {
      final database = await loadOwnershipDatabase();
      final companyIds = database.companies
          .map((company) => company.id)
          .toSet();

      for (final brand in database.brands) {
        expect(
          companyIds.contains(brand.ownerCompanyId),
          isTrue,
          reason:
              'Brand "${brand.id}" references missing company '
              '"${brand.ownerCompanyId}" through ownerCompanyId.',
        );
      }
    });

    test('brand sourceIds reference existing sources', () async {
      final database = await loadOwnershipDatabase();
      final sourceIds = database.sources.map((source) => source.id).toSet();

      for (final brand in database.brands) {
        for (final sourceId in brand.sourceIds) {
          expect(
            sourceIds.contains(sourceId),
            isTrue,
            reason:
                'Brand "${brand.id}" references missing source '
                '"$sourceId" through sourceIds.',
          );
        }
      }
    });

    test(
      'brands use supported relationship types and valid notOwnedBy targets',
      () async {
        final database = await loadOwnershipDatabase();

        for (final brand in database.brands) {
          expect(
            brand.relationshipType == RelationshipType.unknown,
            isFalse,
            reason:
                'Brand "${brand.id}" uses unsupported relationship type '
                '"${brand.relationshipType}".',
          );

          if (brand.relationshipType == RelationshipType.notOwnedBy) {
            expect(
              brand.ownerCompanyId == 'company_nestle_sa',
              isTrue,
              reason:
                  'Brand "${brand.id}" uses notOwnedBy but references company '
                  '"${brand.ownerCompanyId}" instead of "company_nestle_sa".',
            );
          }
        }
      },
    );

    test('company IDs are unique', () async {
      final database = await loadOwnershipDatabase();
      final seenIds = <String>{};
      final duplicateIds = <String>{};

      for (final company in database.companies) {
        if (!seenIds.add(company.id)) {
          duplicateIds.add(company.id);
        }
      }

      expect(
        duplicateIds,
        isEmpty,
        reason:
            'Ownership assets contain duplicate company IDs: '
            '${duplicateIds.join(', ')}.',
      );
    });

    test('brand IDs are unique', () async {
      final database = await loadOwnershipDatabase();
      final seenIds = <String>{};
      final duplicateIds = <String>{};

      for (final brand in database.brands) {
        if (!seenIds.add(brand.id)) {
          duplicateIds.add(brand.id);
        }
      }

      expect(
        duplicateIds,
        isEmpty,
        reason:
            'Ownership assets contain duplicate brand IDs: '
            '${duplicateIds.join(', ')}.',
      );
    });

    test('source IDs are unique', () async {
      final database = await loadOwnershipDatabase();
      final seenIds = <String>{};
      final duplicateIds = <String>{};

      for (final source in database.sources) {
        if (!seenIds.add(source.id)) {
          duplicateIds.add(source.id);
        }
      }

      expect(
        duplicateIds,
        isEmpty,
        reason:
            'Ownership assets contain duplicate source IDs: '
            '${duplicateIds.join(', ')}.',
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
                'Searchable name "$normalizedName" is shared by brands '
                '"$existingBrandId" and "${brand.id}".',
          );

          ownersByNormalizedName[normalizedName] = brand.id;
        }
      }
    });
  });
}
