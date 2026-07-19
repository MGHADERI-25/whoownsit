import 'package:flutter_test/flutter_test.dart';

import 'helpers/ownership_asset_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ownership asset format validation', () {
    test('companies contain required non-empty fields', () async {
      final database = await loadOwnershipDatabase();
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
      final database = await loadOwnershipDatabase();

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
      final database = await loadOwnershipDatabase();

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

    test('company country codes use two-letter uppercase format', () async {
      final database = await loadOwnershipDatabase();
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
      final database = await loadOwnershipDatabase();

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
      final database = await loadOwnershipDatabase();

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
      final sources = await loadOwnershipJsonArray(
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

        final parsedAccessedAt = parseStrictDate(accessedAtValue);

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

          final parsedPublishedAt = parseStrictDate(publishedAtValue);

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
              reason: 'Source $sourceId has publishedAt later than accessedAt.',
            );
          }
        }
      }
    });

    test('brand effective dates use valid ISO-8601 date strings', () async {
      final brands = await loadOwnershipJsonArray(
        'assets/data/ownership/brands.json',
      );

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

        final parsedEffectiveFrom = parseStrictDate(effectiveFromValue);

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

          final parsedEffectiveTo = parseStrictDate(effectiveToValue);

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
                  'Brand $brandId has effectiveTo earlier than effectiveFrom.',
            );
          }
        }
      }
    });

    test('brand market codes use unique uppercase two-letter values', () async {
      final brands = await loadOwnershipJsonArray(
        'assets/data/ownership/brands.json',
      );

      final marketCodePattern = RegExp(r'^[A-Z]{2}$');

      for (final entry in brands) {
        expect(
          entry,
          isA<Map<String, dynamic>>(),
          reason: 'Every brands.json entry must be an object.',
        );

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
                'Brand $brandId has invalid market code "$marketCode". '
                'Expected two uppercase letters.',
          );

          expect(
            seenMarketCodes.add(marketCode),
            isTrue,
            reason:
                'Brand $brandId contains duplicate market code "$marketCode".',
          );
        }
      }
    });
  });
}
