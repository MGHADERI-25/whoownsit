import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/domain/brand.dart';
import 'package:whoownsit/features/ownership/domain/brand_match_scorer.dart';
import 'package:whoownsit/features/ownership/domain/relationship_type.dart';
import 'package:whoownsit/features/ownership/domain/verification_status.dart';

void main() {
  const scorer = BrandMatchScorer();

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

  test('matches exact brand', () {
    final match = scorer.findBestMatch(
      inputBrandNames: const ['KitKat'],
      knownBrands: [kitKat],
    );

    expect(match?.id, 'kitkat');
  });

  test('matches brand with suffix', () {
    final match = scorer.findBestMatch(
      inputBrandNames: const ['KitKat Chunky'],
      knownBrands: [kitKat],
    );

    expect(match?.id, 'kitkat');
  });

  test('matches brand with prefix', () {
    final match = scorer.findBestMatch(
      inputBrandNames: const ['Nestlé KitKat'],
      knownBrands: [kitKat],
    );

    expect(match?.id, 'kitkat');
  });

  test('returns null when nothing matches', () {
    final match = scorer.findBestMatch(
      inputBrandNames: const ['Completely Unknown'],
      knownBrands: [kitKat],
    );

    expect(match, isNull);
  });
}
