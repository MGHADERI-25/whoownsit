import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/data/ownership_database_loader.dart';
import 'package:whoownsit/features/ownership/domain/brand_name_normalizer.dart';
import 'package:whoownsit/features/ownership/data/ownership_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ownership asset validation', () {
    test('bundled ownership assets load successfully', () async {
      final database = await _loadDatabase();

      expect(database.companies, isNotEmpty);
      expect(database.brands, isNotEmpty);
      expect(database.sources, isNotEmpty);
    });

    test('brand effective date ranges are valid', () async {
      final database = await _loadDatabase();

      for (final brand in database.brands) {
        final effectiveTo = brand.effectiveTo;

        if (effectiveTo == null) {
          continue;
        }

        expect(
          effectiveTo.isBefore(brand.effectiveFrom),
          isFalse,
          reason: 'Brand ${brand.id} has effectiveTo before effectiveFrom.',
        );
      }
    });

    test('brand normalized names are lowercase and trimmed', () async {
      final database = await _loadDatabase();

      for (final brand in database.brands) {
        for (final normalizedName in brand.normalizedNames) {
          expect(
            normalizedName,
            normalizedName.trim(),
            reason: 'Brand ${brand.id} contains an untrimmed normalized name.',
          );
          expect(
            normalizedName,
            normalizedName.toLowerCase(),
            reason:
                'Brand ${brand.id} contains a non-lowercase '
                'normalized name.',
          );
          expect(
            normalizedName,
            isNotEmpty,
            reason: 'Brand ${brand.id} contains an empty normalized name.',
          );
        }
      }
    });
    test('brand aliases normalize to non-empty values', () async {
      const normalizer = BrandNameNormalizer();
      final database = await _loadDatabase();

      for (final brand in database.brands) {
        for (final alias in brand.aliases) {
          expect(
            alias.trim(),
            isNotEmpty,
            reason: 'Brand ${brand.id} contains an empty alias.',
          );

          expect(
            normalizer.normalize(alias),
            isNotEmpty,
            reason: 'Brand ${brand.id} contains an unusable alias "$alias".',
          );
        }
      }
    });

    test(
      'stored normalized names use the production normalizer format',
      () async {
        const normalizer = BrandNameNormalizer();
        final database = await _loadDatabase();

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
      final database = await _loadDatabase();

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

    test('every brand has usable canonical-name coverage', () async {
      const normalizer = BrandNameNormalizer();
      final database = await _loadDatabase();

      for (final brand in database.brands) {
        final normalizedCanonicalName = normalizer.normalize(brand.name);

        expect(
          normalizedCanonicalName,
          isNotEmpty,
          reason:
              'Brand ${brand.id} has an unusable canonical name '
              '"${brand.name}".',
        );

        final searchableNames = <String>{
          normalizedCanonicalName,
          ...brand.aliases.map(normalizer.normalize),
          ...brand.normalizedNames.map(normalizer.normalize),
        }..removeWhere((value) => value.isEmpty);

        expect(
          searchableNames,
          isNotEmpty,
          reason: 'Brand ${brand.id} has no usable searchable names.',
        );

        expect(
          searchableNames.contains(normalizedCanonicalName),
          isTrue,
          reason:
              'Brand ${brand.id} does not include its canonical name '
              'in the searchable-name set.',
        );
      }
    });
  });
}

Future<OwnershipDatabase> _loadDatabase() {
  return OwnershipDatabaseLoader(assetBundle: rootBundle).load();
}
