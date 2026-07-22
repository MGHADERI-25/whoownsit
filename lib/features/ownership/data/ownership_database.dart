import '../domain/brand.dart';
import '../domain/company.dart';
import '../domain/ownership_source.dart';

class OwnershipDatabase {
  OwnershipDatabase({
    required List<Company> companies,
    required List<Brand> brands,
    required List<OwnershipSource> sources,
  }) : companies = List<Company>.unmodifiable(companies),
       brands = List<Brand>.unmodifiable(brands),
       sources = List<OwnershipSource>.unmodifiable(sources);

  final List<Company> companies;
  final List<Brand> brands;
  final List<OwnershipSource> sources;
}
