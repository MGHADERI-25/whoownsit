import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/data/ownership_database_loader.dart';
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
  });
}

Future<OwnershipDatabase> _loadDatabase() {
  return OwnershipDatabaseLoader(assetBundle: rootBundle).load();
}
