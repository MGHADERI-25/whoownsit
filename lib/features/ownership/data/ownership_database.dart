import '../domain/brand.dart';
import '../domain/company.dart';
import '../domain/ownership_source.dart';

class OwnershipDatabase {
  const OwnershipDatabase({
    required this.companies,
    required this.brands,
    required this.sources,
  });

  final List<Company> companies;
  final List<Brand> brands;
  final List<OwnershipSource> sources;
}