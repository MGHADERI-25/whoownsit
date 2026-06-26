import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/application/determine_ownership_use_case.dart';
import 'package:whoownsit/features/ownership/data/local_ownership_repository.dart';
import 'package:whoownsit/features/ownership/data/ownership_database_loader.dart';
import 'package:whoownsit/features/ownership/domain/ownership_result_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DetermineOwnershipUseCase with bundled assets', () {
    test('loads bundled ownership data and matches KitKat', () async {
      final repository = LocalOwnershipRepository(
        databaseLoader: OwnershipDatabaseLoader(
          assetBundle: rootBundle,
        ),
      );

      final useCase = DetermineOwnershipUseCase(
        ownershipRepository: repository,
      );

      final result = await useCase.execute(
        brandNames: const ['KitKat'],
      );

      expect(result.status, OwnershipResultStatus.ownedByTarget);
      expect(result.matchedBrandName, 'KitKat');
      expect(result.ownerCompanyName, 'Nestlé S.A.');
    });

    test('returns unknown for brand not present in bundled assets', () async {
      final repository = LocalOwnershipRepository(
        databaseLoader: OwnershipDatabaseLoader(
          assetBundle: rootBundle,
        ),
      );

      final useCase = DetermineOwnershipUseCase(
        ownershipRepository: repository,
      );

      final result = await useCase.execute(
        brandNames: const ['Unknown Brand'],
      );

      expect(result.status, OwnershipResultStatus.unknown);
    });
  });
}