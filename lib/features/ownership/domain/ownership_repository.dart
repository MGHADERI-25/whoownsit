import 'brand.dart';
import 'company.dart';
import 'ownership_source.dart';

abstract class OwnershipRepository {
  Future<List<Company>> getCompanies();

  Future<List<Brand>> getBrands();

  Future<List<OwnershipSource>> getSources();
}