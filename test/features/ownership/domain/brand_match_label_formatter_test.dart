import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/domain/brand_match.dart';
import 'package:whoownsit/features/ownership/domain/brand_match_label_formatter.dart';

void main() {
  group('BrandMatchLabelFormatter', () {
    const formatter = BrandMatchLabelFormatter();

    test('formats confidence labels', () {
      expect(
        formatter.confidenceLabel(BrandMatchConfidence.exact),
        'Exact match',
      );
      expect(
        formatter.confidenceLabel(BrandMatchConfidence.strong),
        'Strong match',
      );
      expect(
        formatter.confidenceLabel(BrandMatchConfidence.possible),
        'Possible match',
      );
    });

    test('formats reason labels', () {
      expect(
        formatter.reasonLabel(BrandMatchReason.exactName),
        'Exact brand name',
      );
      expect(formatter.reasonLabel(BrandMatchReason.exactAlias), 'Exact alias');
      expect(
        formatter.reasonLabel(BrandMatchReason.exactNormalizedName),
        'Exact normalized name',
      );
      expect(
        formatter.reasonLabel(BrandMatchReason.wholePhrase),
        'Brand found in product name',
      );
      expect(
        formatter.reasonLabel(BrandMatchReason.prefix),
        'Brand prefix match',
      );
    });
  });
}
