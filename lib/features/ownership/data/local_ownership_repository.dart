import '../domain/brand.dart';
import '../domain/company.dart';
import '../domain/ownership_repository.dart';
import '../domain/ownership_source.dart';
import 'ownership_database_loader.dart';

class LocalOwnershipRepository implements OwnershipRepository {
  const LocalOwnershipRepository({
    required this.databaseLoader,
  });

  final OwnershipDatabaseLoader databaseLoader;

  @override
  Future<List<Company>> getCompanies() async {
    final database = await databaseLoader.load();
    return database.companies;
  }

  @override
  Future<List<Brand>> getBrands() async {
    final database = await databaseLoader.load();
    return database.brands;
  }

  @override
  Future<List<OwnershipSource>> getSources() async {
    final database = await databaseLoader.load();
    return database.sources;
  }
}