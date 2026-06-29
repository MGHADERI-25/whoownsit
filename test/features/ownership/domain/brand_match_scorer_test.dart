import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/domain/brand.dart';
import 'package:whoownsit/features/ownership/domain/brand_match_scorer.dart';
import 'package:whoownsit/features/ownership/domain/relationship_type.dart';
import 'package:whoownsit/features/ownership/domain/verification_status.dart';
import 'package:whoownsit/features/ownership/domain/brand_match.dart';

void main() {
  const scorer = BrandMatchScorer();

  final nestle = Brand(
    id: 'nestle',
    name: 'Nestlé',
    aliases: const ['Nestle'],
    normalizedNames: const ['nestle', 'nestlé'],
    ownerCompanyId: 'company_nestle_sa',
    relationshipType: RelationshipType.ownedBy,
    verificationStatus: VerificationStatus.maintainerVerified,
    sourceIds: const [],
    effectiveFrom: DateTime(1866),
    effectiveTo: null,
    markets: const [],
  );

  final kitKat = Brand(
    id: 'kitkat',
    name: 'KitKat',
    aliases: const ['Kit Kat'],
    normalizedNames: const ['kitkat'],
    ownerCompanyId: 'company_nestle_sa',
    relationshipType: RelationshipType.ownedBy,
    verificationStatus: VerificationStatus.maintainerVerified,
    sourceIds: const [],
    effectiveFrom: DateTime(1988),
    effectiveTo: null,
    markets: const [],
  );

  test('returns exact confidence for exact brand match', () {
    final match = scorer.findBestMatch(
      inputBrandNames: const ['KitKat'],
      knownBrands: [kitKat],
    );

    expect(match?.confidence, BrandMatchConfidence.exact);
    expect(match?.reason, BrandMatchReason.exactName);
  });

  test('returns strong confidence for whole phrase match', () {
    final match = scorer.findBestMatch(
      inputBrandNames: const ['KitKat Chunky'],
      knownBrands: [kitKat],
    );

    expect(match?.confidence, BrandMatchConfidence.strong);
    expect(match?.reason, BrandMatchReason.wholePhrase);
  });

  test('returns possible confidence when known brand starts with input', () {
    final match = scorer.findBestMatch(
      inputBrandNames: const ['Kit'],
      knownBrands: [kitKat],
    );

    expect(match?.confidence, BrandMatchConfidence.possible);
    expect(match?.reason, BrandMatchReason.prefix);
  });
  test('matches exact brand', () {
    final match = scorer.findBestMatch(
      inputBrandNames: const ['KitKat'],
      knownBrands: [kitKat],
    );

    expect(match?.brand.id, 'kitkat');
  });

  test('prefers more specific brand when multiple brands match', () {
    final match = scorer.findBestMatch(
      inputBrandNames: const ['Nestlé KitKat'],
      knownBrands: [nestle, kitKat],
    );

    expect(match?.brand.id, 'kitkat');
  });

  test('matches brand with suffix', () {
    final match = scorer.findBestMatch(
      inputBrandNames: const ['KitKat Chunky'],
      knownBrands: [kitKat],
    );

    expect(match?.brand.id, 'kitkat');
  });

  test('matches brand with prefix', () {
    final match = scorer.findBestMatch(
      inputBrandNames: const ['Nestlé KitKat'],
      knownBrands: [kitKat],
    );

    expect(match?.brand.id, 'kitkat');
  });

  test('returns null when nothing matches', () {
    final match = scorer.findBestMatch(
      inputBrandNames: const ['Completely Unknown'],
      knownBrands: [kitKat],
    );

    expect(match, isNull);
  });
}
