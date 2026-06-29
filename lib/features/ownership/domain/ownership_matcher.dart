import 'brand.dart';
import 'brand_match.dart';
import 'brand_match_scorer.dart';
import 'brand_name_normalizer.dart';
import 'company.dart';
import 'ownership_result.dart';
import 'ownership_result_status.dart';
import 'relationship_type.dart';
import 'verification_status.dart';

class OwnershipMatcher {
  const OwnershipMatcher({
    this.targetCompanyId = 'company_nestle_sa',
    this.normalizer = const BrandNameNormalizer(),
    this.scorer = const BrandMatchScorer(),
  });

  final String targetCompanyId;
  final BrandNameNormalizer normalizer;
  final BrandMatchScorer scorer;

  OwnershipResult match({
    required List<String> inputBrandNames,
    required List<Brand> knownBrands,
    required List<Company> knownCompanies,
  }) {
    if (inputBrandNames.isEmpty) {
      return const OwnershipResult(
        status: OwnershipResultStatus.brandNotFound,
        message: 'No brand information was found for this product.',
      );
    }

    final normalizedInputs = inputBrandNames
        .map(normalizer.normalize)
        .where((name) => name.isNotEmpty)
        .toSet();

    if (normalizedInputs.isEmpty) {
      return const OwnershipResult(
        status: OwnershipResultStatus.brandNotFound,
        message: 'No usable brand information was found for this product.',
      );
    }

    final brandMatch = scorer.findBestMatch(
      inputBrandNames: normalizedInputs.toList(),
      knownBrands: knownBrands,
    );

    if (brandMatch != null) {
      final matchedBrand = brandMatch.brand;
      final ownerCompany = _findCompanyById(
        knownCompanies,
        matchedBrand.ownerCompanyId,
      );

      return _buildResultForBrand(
        brand: matchedBrand,
        ownerCompany: ownerCompany,
        brandMatch: brandMatch,
      );
    }

    return const OwnershipResult(
      status: OwnershipResultStatus.unknown,
      message: 'No ownership record was found for the detected brand.',
    );
  }

  Company? _findCompanyById(List<Company> companies, String companyId) {
    for (final company in companies) {
      if (company.id == companyId) {
        return company;
      }
    }

    return null;
  }

  OwnershipResult _buildResultForBrand({
    required Brand brand,
    required Company? ownerCompany,
    BrandMatch? brandMatch,
  }) {
    final isTargetCompany = brand.ownerCompanyId == targetCompanyId;
    final isStronglyVerified =
        brand.verificationStatus == VerificationStatus.sourceVerified ||
        brand.verificationStatus == VerificationStatus.maintainerVerified;

    if (!isStronglyVerified) {
      return OwnershipResult(
        status: OwnershipResultStatus.unknown,
        matchedBrandId: brand.id,
        matchedBrandName: brand.name,
        ownerCompanyId: brand.ownerCompanyId,
        ownerCompanyName: ownerCompany?.name,
        matchConfidence: brandMatch?.confidence,
        matchReason: brandMatch?.reason,
        relationshipType: brand.relationshipType,
        verificationStatus: brand.verificationStatus,
        sourceIds: brand.sourceIds,
        message: 'A possible ownership record exists, but it is not verified.',
      );
    }

    if (!isTargetCompany) {
      return OwnershipResult(
        status: OwnershipResultStatus.notTarget,
        matchedBrandId: brand.id,
        matchedBrandName: brand.name,
        ownerCompanyId: brand.ownerCompanyId,
        ownerCompanyName: ownerCompany?.name,
        matchConfidence: brandMatch?.confidence,
        matchReason: brandMatch?.reason,
        relationshipType: brand.relationshipType,
        verificationStatus: brand.verificationStatus,
        sourceIds: brand.sourceIds,
        message: '${brand.name} is not listed as owned by the target company.',
      );
    }

    return switch (brand.relationshipType) {
      RelationshipType.ownedBy => OwnershipResult(
        status: OwnershipResultStatus.ownedByTarget,
        matchedBrandId: brand.id,
        matchedBrandName: brand.name,
        ownerCompanyId: brand.ownerCompanyId,
        ownerCompanyName: ownerCompany?.name,
        matchConfidence: brandMatch?.confidence,
        matchReason: brandMatch?.reason,
        relationshipType: brand.relationshipType,
        verificationStatus: brand.verificationStatus,
        sourceIds: brand.sourceIds,
        message:
            '${brand.name} is listed as owned by ${ownerCompany?.name ?? 'the target company'}.',
      ),
      RelationshipType.subsidiaryOf => OwnershipResult(
        status: OwnershipResultStatus.subsidiaryOfTarget,
        matchedBrandId: brand.id,
        matchedBrandName: brand.name,
        ownerCompanyId: brand.ownerCompanyId,
        ownerCompanyName: ownerCompany?.name,
        matchConfidence: brandMatch?.confidence,
        matchReason: brandMatch?.reason,
        relationshipType: brand.relationshipType,
        verificationStatus: brand.verificationStatus,
        sourceIds: brand.sourceIds,
        message:
            '${brand.name} is listed as a subsidiary of ${ownerCompany?.name ?? 'the target company'}.',
      ),
      RelationshipType.relatedTo ||
      RelationshipType.controlledBy ||
      RelationshipType.licensedBy ||
      RelationshipType.distributedBy ||
      RelationshipType.jointVenture => OwnershipResult(
        status: OwnershipResultStatus.relatedToTarget,
        matchedBrandId: brand.id,
        matchedBrandName: brand.name,
        ownerCompanyId: brand.ownerCompanyId,
        ownerCompanyName: ownerCompany?.name,
        matchConfidence: brandMatch?.confidence,
        matchReason: brandMatch?.reason,
        relationshipType: brand.relationshipType,
        verificationStatus: brand.verificationStatus,
        sourceIds: brand.sourceIds,
        message:
            '${brand.name} is listed as related to ${ownerCompany?.name ?? 'the target company'}.',
      ),
      RelationshipType.notOwnedBy => OwnershipResult(
        status: OwnershipResultStatus.notTarget,
        matchedBrandId: brand.id,
        matchedBrandName: brand.name,
        ownerCompanyId: brand.ownerCompanyId,
        ownerCompanyName: ownerCompany?.name,
        matchConfidence: brandMatch?.confidence,
        matchReason: brandMatch?.reason,
        relationshipType: brand.relationshipType,
        verificationStatus: brand.verificationStatus,
        sourceIds: brand.sourceIds,
        message: '${brand.name} is not listed as owned by the target company.',
      ),
      RelationshipType.unknown => OwnershipResult(
        status: OwnershipResultStatus.unknown,
        matchedBrandId: brand.id,
        matchedBrandName: brand.name,
        ownerCompanyId: brand.ownerCompanyId,
        ownerCompanyName: ownerCompany?.name,
        matchConfidence: brandMatch?.confidence,
        matchReason: brandMatch?.reason,
        relationshipType: brand.relationshipType,
        verificationStatus: brand.verificationStatus,
        sourceIds: brand.sourceIds,
        message: 'Ownership status for ${brand.name} is unknown.',
      ),
    };
  }
}
