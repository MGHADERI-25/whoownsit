import '../domain/brand.dart';
import '../domain/company.dart';
import '../domain/ownership_repository.dart';
import '../domain/ownership_source.dart';
import 'ownership_database.dart';
import 'ownership_database_loader.dart';

class LocalOwnershipRepository implements OwnershipRepository {
  LocalOwnershipRepository({required this.databaseLoader});

  final OwnershipDatabaseLoader databaseLoader;

  Future<OwnershipDatabase>? _databaseFuture;

  Future<OwnershipDatabase> _getDatabase() {
    final cachedFuture = _databaseFuture;

    if (cachedFuture != null) {
      return cachedFuture;
    }

    final loadFuture = _loadDatabase();
    _databaseFuture = loadFuture;

    return loadFuture;
  }

  Future<OwnershipDatabase> _loadDatabase() async {
    try {
      return await databaseLoader.load();
    } on Object {
      _databaseFuture = null;
      rethrow;
    }
  }

  @override
  Future<List<Company>> getCompanies() async {
    final database = await _getDatabase();
    return database.companies;
  }

  @override
  Future<List<Brand>> getBrands() async {
    final database = await _getDatabase();
    return database.brands;
  }

  @override
  Future<List<OwnershipSource>> getSources() async {
    final database = await _getDatabase();
    return database.sources;
  }
}
