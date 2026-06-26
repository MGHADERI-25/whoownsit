import '../domain/ownership_matcher.dart';
import '../domain/ownership_repository.dart';
import '../domain/ownership_result.dart';

class DetermineOwnershipUseCase {
  const DetermineOwnershipUseCase({
    required this.ownershipRepository,
    OwnershipMatcher? ownershipMatcher,
  }) : ownershipMatcher = ownershipMatcher ?? const OwnershipMatcher();

  final OwnershipRepository ownershipRepository;
  final OwnershipMatcher ownershipMatcher;

  Future<OwnershipResult> execute({
    required List<String> brandNames,
  }) async {
    final companies = await ownershipRepository.getCompanies();
    final brands = await ownershipRepository.getBrands();

    return ownershipMatcher.match(
      inputBrandNames: brandNames,
      knownBrands: brands,
      knownCompanies: companies,
    );
  }
}