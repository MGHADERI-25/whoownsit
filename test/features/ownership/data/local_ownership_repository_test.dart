import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/data/local_ownership_repository.dart';
import 'package:whoownsit/features/ownership/data/ownership_database.dart';
import 'package:whoownsit/features/ownership/data/ownership_database_loader.dart';
import 'package:whoownsit/features/ownership/domain/brand.dart';
import 'package:whoownsit/features/ownership/domain/company.dart';
import 'package:whoownsit/features/ownership/domain/ownership_source.dart';
import 'package:whoownsit/features/ownership/domain/relationship_type.dart';
import 'package:whoownsit/features/ownership/domain/verification_status.dart';

class CountingOwnershipDatabaseLoader extends OwnershipDatabaseLoader {
  CountingOwnershipDatabaseLoader({required this.database});

  final OwnershipDatabase database;

  int loadCount = 0;

  @override
  Future<OwnershipDatabase> load() async {
    loadCount++;
    return database;
  }
}

void main() {
  group('LocalOwnershipRepository', () {
    final company = Company(
      id: 'company_test',
      name: 'Test Company',
      aliases: const [],
      countryCode: 'CH',
      website: 'https://example.com',
    );

    final brand = Brand(
      id: 'brand_test',
      name: 'Test Brand',
      aliases: const [],
      normalizedNames: const ['test brand'],
      ownerCompanyId: 'company_test',
      relationshipType: RelationshipType.ownedBy,
      verificationStatus: VerificationStatus.maintainerVerified,
      sourceIds: const [],
      effectiveFrom: DateTime(2026),
      effectiveTo: null,
      markets: const [],
    );

    test('returns companies, brands, and sources from the database', () async {
      final database = OwnershipDatabase(
        companies: [company],
        brands: [brand],
        sources: const <OwnershipSource>[],
      );

      final loader = CountingOwnershipDatabaseLoader(database: database);
      final repository = LocalOwnershipRepository(databaseLoader: loader);

      expect(await repository.getCompanies(), [company]);
      expect(await repository.getBrands(), [brand]);
      expect(await repository.getSources(), isEmpty);
    });

    test('loads the database only once across repository calls', () async {
      final database = OwnershipDatabase(
        companies: [company],
        brands: [brand],
        sources: const <OwnershipSource>[],
      );

      final loader = CountingOwnershipDatabaseLoader(database: database);
      final repository = LocalOwnershipRepository(databaseLoader: loader);

      await repository.getCompanies();
      await repository.getBrands();
      await repository.getSources();
      await repository.getCompanies();

      expect(loader.loadCount, 1);
    });
  });
}
