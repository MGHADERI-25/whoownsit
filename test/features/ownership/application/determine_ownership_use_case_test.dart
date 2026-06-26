import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/application/determine_ownership_use_case.dart';
import 'package:whoownsit/features/ownership/domain/brand.dart';
import 'package:whoownsit/features/ownership/domain/company.dart';
import 'package:whoownsit/features/ownership/domain/ownership_repository.dart';
import 'package:whoownsit/features/ownership/domain/ownership_result_status.dart';
import 'package:whoownsit/features/ownership/domain/ownership_source.dart';
import 'package:whoownsit/features/ownership/domain/relationship_type.dart';
import 'package:whoownsit/features/ownership/domain/verification_status.dart';

class FakeOwnershipRepository implements OwnershipRepository {
  const FakeOwnershipRepository({
    required this.companies,
    required this.brands,
    this.sources = const [],
  });

  final List<Company> companies;
  final List<Brand> brands;
  final List<OwnershipSource> sources;

  @override
  Future<List<Company>> getCompanies() async => companies;

  @override
  Future<List<Brand>> getBrands() async => brands;

  @override
  Future<List<OwnershipSource>> getSources() async => sources;
}

void main() {
  group('DetermineOwnershipUseCase', () {
    final nestle = Company(
      id: 'company_nestle_sa',
      name: 'Nestlé S.A.',
      aliases: const ['Nestle', 'Nestlé'],
      countryCode: 'CH',
      website: 'https://www.nestle.com',
    );

    final kitKat = Brand(
      id: 'brand_kitkat',
      name: 'KitKat',
      aliases: const ['Kit Kat', 'KITKAT'],
      normalizedNames: const ['kitkat', 'kit kat'],
      ownerCompanyId: 'company_nestle_sa',
      relationshipType: RelationshipType.ownedBy,
      verificationStatus: VerificationStatus.maintainerVerified,
      sourceIds: const ['source_nestle_brands_page'],
      effectiveFrom: DateTime(1988),
      effectiveTo: null,
      markets: const [],
    );

    test('returns ownership result for known brand', () async {
      final repository = FakeOwnershipRepository(
        companies: [nestle],
        brands: [kitKat],
      );

      final useCase = DetermineOwnershipUseCase(
        ownershipRepository: repository,
      );

      final result = await useCase.execute(
        brandNames: const ['Kit Kat'],
      );

      expect(result.status, OwnershipResultStatus.ownedByTarget);
      expect(result.matchedBrandName, 'KitKat');
      expect(result.ownerCompanyName, 'Nestlé S.A.');
    });

    test('returns unknown for unknown brand', () async {
      final repository = FakeOwnershipRepository(
        companies: [nestle],
        brands: [kitKat],
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