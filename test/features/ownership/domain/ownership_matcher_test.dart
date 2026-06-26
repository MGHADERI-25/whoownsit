import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/domain/brand.dart';
import 'package:whoownsit/features/ownership/domain/company.dart';
import 'package:whoownsit/features/ownership/domain/ownership_matcher.dart';
import 'package:whoownsit/features/ownership/domain/ownership_result_status.dart';
import 'package:whoownsit/features/ownership/domain/relationship_type.dart';
import 'package:whoownsit/features/ownership/domain/verification_status.dart';

void main() {
  group('OwnershipMatcher', () {
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

    test('returns brandNotFound when input brand list is empty', () {
      const matcher = OwnershipMatcher();

      final result = matcher.match(
        inputBrandNames: const [],
        knownBrands: [kitKat],
        knownCompanies: [nestle],
      );

      expect(result.status, OwnershipResultStatus.brandNotFound);
    });

    test('matches brand by exact normalized name', () {
      const matcher = OwnershipMatcher();

      final result = matcher.match(
        inputBrandNames: const ['kitkat'],
        knownBrands: [kitKat],
        knownCompanies: [nestle],
      );

      expect(result.status, OwnershipResultStatus.ownedByTarget);
      expect(result.matchedBrandName, 'KitKat');
      expect(result.ownerCompanyName, 'Nestlé S.A.');
    });

    test('matches brand by alias', () {
      const matcher = OwnershipMatcher();

      final result = matcher.match(
        inputBrandNames: const ['Kit Kat'],
        knownBrands: [kitKat],
        knownCompanies: [nestle],
      );

      expect(result.status, OwnershipResultStatus.ownedByTarget);
    });

    test('returns unknown when no brand matches', () {
      const matcher = OwnershipMatcher();

      final result = matcher.match(
        inputBrandNames: const ['Unknown Brand'],
        knownBrands: [kitKat],
        knownCompanies: [nestle],
      );

      expect(result.status, OwnershipResultStatus.unknown);
    });

    test('does not make strong claim for unverified ownership record', () {
      const matcher = OwnershipMatcher();

      final unverifiedBrand = Brand(
        id: 'brand_possible',
        name: 'Possible Brand',
        aliases: const [],
        normalizedNames: const ['possible brand'],
        ownerCompanyId: 'company_nestle_sa',
        relationshipType: RelationshipType.ownedBy,
        verificationStatus: VerificationStatus.communitySubmitted,
        sourceIds: const [],
        effectiveFrom: DateTime(2024),
        effectiveTo: null,
        markets: const [],
      );

      final result = matcher.match(
        inputBrandNames: const ['Possible Brand'],
        knownBrands: [unverifiedBrand],
        knownCompanies: [nestle],
      );

      expect(result.status, OwnershipResultStatus.unknown);
    });
  });
}