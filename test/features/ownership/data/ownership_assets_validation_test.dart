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
