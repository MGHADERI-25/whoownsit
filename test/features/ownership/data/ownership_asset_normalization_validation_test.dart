import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/domain/brand_name_normalizer.dart';

import 'helpers/ownership_asset_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ownership asset normalization validation', () {
    test('brand normalized names are lowercase and trimmed', () async {
      final database = await loadOwnershipDatabase();

      for (final brand in database.brands) {
        for (final normalizedName in brand.normalizedNames) {
          expect(
            normalizedName,
            normalizedName.trim(),
            reason:
                'Brand "${brand.id}" contains untrimmed normalized name '
                '"$normalizedName".',
          );
          expect(
            normalizedName,
            normalizedName.toLowerCase(),
            reason:
                'Brand "${brand.id}" contains non-lowercase normalized name '
                '"$normalizedName".',
          );
          expect(
            normalizedName,
            isNotEmpty,
            reason: 'Brand "${brand.id}" contains an empty normalized name.',
          );
        }
      }
    });

    test('brand aliases normalize to non-empty values', () async {
      const normalizer = BrandNameNormalizer();
      final database = await loadOwnershipDatabase();

      for (final brand in database.brands) {
        for (final alias in brand.aliases) {
          expect(
            alias.trim(),
            isNotEmpty,
            reason: 'Brand "${brand.id}" contains an empty alias.',
          );

          expect(
            normalizer.normalize(alias),
            isNotEmpty,
            reason:
                'Brand "${brand.id}" contains alias "$alias", which normalizes '
                'to an empty value.',
          );
        }
      }
    });

    test(
      'stored normalized names use the production normalizer format',
      () async {
        const normalizer = BrandNameNormalizer();
        final database = await loadOwnershipDatabase();

        for (final brand in database.brands) {
          for (final normalizedName in brand.normalizedNames) {
            expect(
              normalizedName,
              normalizer.normalize(normalizedName),
              reason:
                  'Brand ${brand.id} contains a value that is not fully '
                  'normalized: "$normalizedName".',
            );
          }
        }
      },
    );

    test('brand normalized names are unique within each record', () async {
      const normalizer = BrandNameNormalizer();
      final database = await loadOwnershipDatabase();

      for (final brand in database.brands) {
        final normalizedNames = brand.normalizedNames
            .map(normalizer.normalize)
            .where((value) => value.isNotEmpty)
            .toList();

        expect(
          normalizedNames.toSet().length,
          normalizedNames.length,
          reason: 'Brand ${brand.id} contains duplicate normalized names.',
        );
      }
    });

    test('every brand stores its canonical normalized name', () async {
      const normalizer = BrandNameNormalizer();
      final database = await loadOwnershipDatabase();

      for (final brand in database.brands) {
        final normalizedCanonicalName = normalizer.normalize(brand.name);

        expect(
          normalizedCanonicalName,
          isNotEmpty,
          reason:
              'Brand ${brand.id} has an unusable canonical name '
              '"${brand.name}".',
        );

        final storedNormalizedNames = brand.normalizedNames
            .map(normalizer.normalize)
            .where((value) => value.isNotEmpty)
            .toSet();

        expect(
          storedNormalizedNames,
          isNotEmpty,
          reason: 'Brand ${brand.id} has no usable normalized names.',
        );

        expect(
          storedNormalizedNames.contains(normalizedCanonicalName),
          isTrue,
          reason:
              'Brand ${brand.id} does not store its canonical normalized name '
              '"$normalizedCanonicalName".',
        );
      }
    });
  });
}
