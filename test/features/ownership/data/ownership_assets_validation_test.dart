import 'package:flutter_test/flutter_test.dart';

import 'helpers/ownership_asset_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ownership asset validation', () {
    test('bundled ownership assets load successfully', () async {
      final database = await loadOwnershipDatabase();

      expect(database.companies, isNotEmpty);
      expect(database.brands, isNotEmpty);
      expect(database.sources, isNotEmpty);
    });
  });
}
