import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/data/ownership_database_loader.dart';
import 'package:whoownsit/features/ownership/domain/relationship_type.dart';

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
              'Brand ${brand.id} references missing company '
              '${brand.ownerCompanyId}.',
        );
      }
    });

    test('companies contain required non-empty fields', () async {
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();

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
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();

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
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();

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
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();

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
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();

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
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();

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
                'Normalized name "$name" is shared by '
                '$existingBrandId and ${brand.id}.',
          );

          ownersByNormalizedName[name] = brand.id;
        }
      }
    });

    test('company country codes use two-letter uppercase format', () async {
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();
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
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();

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
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();

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
      final jsonString = await rootBundle.loadString(
        'assets/data/ownership/sources.json',
      );

      final decoded = jsonDecode(jsonString);

      expect(
        decoded,
        isA<List<dynamic>>(),
        reason: 'sources.json must contain a JSON array.',
      );

      final sources = decoded as List<dynamic>;
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

    test('all brand sourceIds reference existing sources', () async {
      final loader = OwnershipDatabaseLoader(assetBundle: rootBundle);

      final database = await loader.load();
      final sourceIds = database.sources.map((source) => source.id).toSet();

      for (final brand in database.brands) {
        for (final sourceId in brand.sourceIds) {
          expect(
            sourceIds.contains(sourceId),
            isTrue,
            reason: 'Brand ${brand.id} references missing source $sourceId.',
          );
        }
      }
    });
  });
}
