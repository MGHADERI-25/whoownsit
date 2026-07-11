import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/data/ownership_database_loader.dart';
import 'package:whoownsit/features/ownership/domain/brand_name_normalizer.dart';
import 'package:whoownsit/features/ownership/domain/relationship_type.dart';
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

    test('companies contain required non-empty fields', () async {
      final database = await _loadDatabase();

      for (final company in database.companies) {
        expect(
          company.id.trim(),
          isNotEmpty,
          reason: 'Company has an empty ID.',
        );
        expect(
          company.name.trim(),
          isNotEmpty,
          reason: 'Company ${company.id} has an empty name.',
        );
        expect(
          company.countryCode.trim(),
          isNotEmpty,
          reason: 'Company ${company.id} has an empty country code.',
        );
        expect(
          company.website.trim(),
          isNotEmpty,
          reason: 'Company ${company.id} has an empty website.',
        );
      }
    });

    test('brands contain required non-empty fields', () async {
      final database = await _loadDatabase();

      for (final brand in database.brands) {
        expect(brand.id.trim(), isNotEmpty, reason: 'Brand has an empty ID.');
        expect(
          brand.name.trim(),
          isNotEmpty,
          reason: 'Brand ${brand.id} has an empty name.',
        );
        expect(
          brand.ownerCompanyId.trim(),
          isNotEmpty,
          reason: 'Brand ${brand.id} has an empty ownerCompanyId.',
        );
        expect(
          brand.sourceIds,
          isNotEmpty,
          reason: 'Brand ${brand.id} has no supporting sources.',
        );
        expect(
          brand.normalizedNames,
          isNotEmpty,
          reason: 'Brand ${brand.id} has no normalized names.',
        );
      }
    });

    test('sources contain required non-empty fields', () async {
      final database = await _loadDatabase();

      for (final source in database.sources) {
        expect(source.id.trim(), isNotEmpty, reason: 'Source has an empty ID.');
        expect(
          source.title.trim(),
          isNotEmpty,
          reason: 'Source ${source.id} has an empty title.',
        );
        expect(
          source.url.trim(),
          isNotEmpty,
          reason: 'Source ${source.id} has an empty URL.',
        );
        expect(
          source.publisher.trim(),
          isNotEmpty,
          reason: 'Source ${source.id} has an empty publisher.',
        );
      }
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

    test('current ownership records have consistent relationships', () async {
      final database = await _loadDatabase();

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
                'Brand ${brand.id} uses notOwnedBy but does not '
                'reference the target company.',
          );
        }
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
    test('company country codes use two-letter uppercase format', () async {
      final database = await _loadDatabase();
      final countryCodePattern = RegExp(r'^[A-Z]{2}$');

      for (final company in database.companies) {
        expect(
          countryCodePattern.hasMatch(company.countryCode),
          isTrue,
          reason:
              'Company ${company.id} has invalid country code '
              '"${company.countryCode}".',
        );
      }
    });

    test('company websites contain valid HTTP or HTTPS URLs', () async {
      final database = await _loadDatabase();

      for (final company in database.companies) {
        final uri = Uri.tryParse(company.website);

        expect(
          uri != null &&
              uri.hasScheme &&
              uri.host.isNotEmpty &&
              (uri.scheme == 'http' || uri.scheme == 'https'),
          isTrue,
          reason:
              'Company ${company.id} has invalid website '
              '"${company.website}".',
        );
      }
    });

    test('source URLs contain valid HTTP or HTTPS URLs', () async {
      final database = await _loadDatabase();

      for (final source in database.sources) {
        final uri = Uri.tryParse(source.url);

        expect(
          uri != null &&
              uri.hasScheme &&
              uri.host.isNotEmpty &&
              (uri.scheme == 'http' || uri.scheme == 'https'),
          isTrue,
          reason: 'Source ${source.id} has invalid URL "${source.url}".',
        );
      }
    });

    test('source dates contain valid ISO-8601 date strings', () async {
      final sources = await _loadJsonArray(
        'assets/data/ownership/sources.json',
      );
      final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      for (final entry in sources) {
        expect(
          entry,
          isA<Map<String, dynamic>>(),
          reason: 'Every sources.json entry must be an object.',
        );

        final source = entry as Map<String, dynamic>;
        final sourceId = source['id'];
        final accessedAt = source['accessedAt'];
        final publishedAt = source['publishedAt'];

        expect(
          accessedAt,
          isA<String>(),
          reason: 'Source $sourceId must have an accessedAt date.',
        );

        final accessedAtValue = accessedAt as String;

        expect(
          datePattern.hasMatch(accessedAtValue),
          isTrue,
          reason:
              'Source $sourceId has invalid accessedAt format '
              '"$accessedAtValue".',
        );

        final parsedAccessedAt = DateTime.tryParse(accessedAtValue);

        expect(
          parsedAccessedAt,
          isNotNull,
          reason:
              'Source $sourceId has an invalid accessedAt date '
              '"$accessedAtValue".',
        );

        if (publishedAt != null) {
          expect(
            publishedAt,
            isA<String>(),
            reason: 'Source $sourceId publishedAt must be a string or null.',
          );

          final publishedAtValue = publishedAt as String;

          expect(
            datePattern.hasMatch(publishedAtValue),
            isTrue,
            reason:
                'Source $sourceId has invalid publishedAt format '
                '"$publishedAtValue".',
          );

          final parsedPublishedAt = DateTime.tryParse(publishedAtValue);

          expect(
            parsedPublishedAt,
            isNotNull,
            reason:
                'Source $sourceId has an invalid publishedAt date '
                '"$publishedAtValue".',
          );

          if (parsedPublishedAt != null && parsedAccessedAt != null) {
            expect(
              parsedPublishedAt.isAfter(parsedAccessedAt),
              isFalse,
              reason:
                  'Source $sourceId has publishedAt later than '
                  'accessedAt.',
            );
          }
        }
      }
    });

    test('brand effective dates use valid ISO-8601 date strings', () async {
      final brands = await _loadJsonArray('assets/data/ownership/brands.json');
      final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

      for (final entry in brands) {
        expect(
          entry,
          isA<Map<String, dynamic>>(),
          reason: 'Every brands.json entry must be an object.',
        );

        final brand = entry as Map<String, dynamic>;
        final brandId = brand['id'];
        final effectiveFrom = brand['effectiveFrom'];
        final effectiveTo = brand['effectiveTo'];

        expect(
          effectiveFrom,
          isA<String>(),
          reason: 'Brand $brandId must have an effectiveFrom date.',
        );

        final effectiveFromValue = effectiveFrom as String;

        expect(
          datePattern.hasMatch(effectiveFromValue),
          isTrue,
          reason:
              'Brand $brandId has invalid effectiveFrom format '
              '"$effectiveFromValue".',
        );

        final parsedEffectiveFrom = _parseStrictDate(effectiveFromValue);

        expect(
          parsedEffectiveFrom,
          isNotNull,
          reason:
              'Brand $brandId has an invalid effectiveFrom date '
              '"$effectiveFromValue".',
        );

        if (effectiveTo != null) {
          expect(
            effectiveTo,
            isA<String>(),
            reason: 'Brand $brandId effectiveTo must be a string or null.',
          );

          final effectiveToValue = effectiveTo as String;

          expect(
            datePattern.hasMatch(effectiveToValue),
            isTrue,
            reason:
                'Brand $brandId has invalid effectiveTo format '
                '"$effectiveToValue".',
          );

          final parsedEffectiveTo = _parseStrictDate(effectiveToValue);

          expect(
            parsedEffectiveTo,
            isNotNull,
            reason:
                'Brand $brandId has an invalid effectiveTo date '
                '"$effectiveToValue".',
          );

          if (parsedEffectiveFrom != null && parsedEffectiveTo != null) {
            expect(
              parsedEffectiveTo.isBefore(parsedEffectiveFrom),
              isFalse,
              reason:
                  'Brand $brandId has effectiveTo earlier than '
                  'effectiveFrom.',
            );
          }
        }
      }
    });

    test('brand market codes use unique uppercase two-letter values', () async {
      final brands = await _loadJsonArray('assets/data/ownership/brands.json');
      final marketCodePattern = RegExp(r'^[A-Z]{2}$');

      for (final entry in brands) {
        final brand = entry as Map<String, dynamic>;
        final brandId = brand['id'];
        final markets = brand['markets'];

        expect(
          markets,
          isA<List<dynamic>>(),
          reason: 'Brand $brandId must contain a markets array.',
        );

        final marketValues = markets as List<dynamic>;
        final seenMarketCodes = <String>{};

        for (final market in marketValues) {
          expect(
            market,
            isA<String>(),
            reason: 'Brand $brandId contains a non-string market code.',
          );

          final marketCode = market as String;

          expect(
            marketCodePattern.hasMatch(marketCode),
            isTrue,
            reason:
                'Brand $brandId has invalid market code '
                '"$marketCode". Expected two uppercase letters.',
          );

          expect(
            seenMarketCodes.add(marketCode),
            isTrue,
            reason:
                'Brand $brandId contains duplicate market code '
                '"$marketCode".',
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

DateTime? _parseStrictDate(String value) {
  final parsed = DateTime.tryParse(value);

  if (parsed == null) {
    return null;
  }

  final expected =
      '${parsed.year.toString().padLeft(4, '0')}-'
      '${parsed.month.toString().padLeft(2, '0')}-'
      '${parsed.day.toString().padLeft(2, '0')}';

  return expected == value ? parsed : null;
}

Future<OwnershipDatabase> _loadDatabase() {
  return OwnershipDatabaseLoader(assetBundle: rootBundle).load();
}

Future<List<dynamic>> _loadJsonArray(String assetPath) async {
  final jsonString = await rootBundle.loadString(assetPath);

  final decoded = jsonDecode(jsonString);

  expect(
    decoded,
    isA<List<dynamic>>(),
    reason: '$assetPath must contain a JSON array.',
  );

  return decoded as List<dynamic>;
}
