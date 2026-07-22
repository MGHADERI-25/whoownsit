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

class FailingOnceOwnershipDatabaseLoader extends OwnershipDatabaseLoader {
  FailingOnceOwnershipDatabaseLoader({required this.database});

  final OwnershipDatabase database;

  int loadCount = 0;

  @override
  Future<OwnershipDatabase> load() async {
    loadCount++;

    if (loadCount == 1) {
      throw StateError('Database load failed.');
    }

    return database;
  }
}

class DelayedOwnershipDatabaseLoader extends OwnershipDatabaseLoader {
  DelayedOwnershipDatabaseLoader({required this.database});

  final OwnershipDatabase database;

  int loadCount = 0;

  @override
  Future<OwnershipDatabase> load() async {
    loadCount++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
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

    test('shares one database load across concurrent calls', () async {
      final database = OwnershipDatabase(
        companies: [company],
        brands: [brand],
        sources: const <OwnershipSource>[],
      );

      final loader = DelayedOwnershipDatabaseLoader(database: database);
      final repository = LocalOwnershipRepository(databaseLoader: loader);

      final results = await Future.wait([
        repository.getCompanies(),
        repository.getBrands(),
        repository.getSources(),
      ]);

      expect(results[0], [company]);
      expect(results[1], [brand]);
      expect(results[2], isEmpty);
      expect(loader.loadCount, 1);
    });

    test('retries loading after an initial failure', () async {
      final database = OwnershipDatabase(
        companies: [company],
        brands: [brand],
        sources: const <OwnershipSource>[],
      );

      final loader = FailingOnceOwnershipDatabaseLoader(database: database);
      final repository = LocalOwnershipRepository(databaseLoader: loader);

      await expectLater(repository.getCompanies(), throwsA(isA<StateError>()));

      expect(await repository.getCompanies(), [company]);
      expect(loader.loadCount, 2);
    });

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
