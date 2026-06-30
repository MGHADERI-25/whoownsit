import 'brand_match.dart';

class BrandMatchLabelFormatter {
  const BrandMatchLabelFormatter();

  String confidenceLabel(BrandMatchConfidence confidence) {
    return switch (confidence) {
      BrandMatchConfidence.exact => 'Exact match',
      BrandMatchConfidence.strong => 'Strong match',
      BrandMatchConfidence.possible => 'Possible match',
    };
  }

  String reasonLabel(BrandMatchReason reason) {
    return switch (reason) {
      BrandMatchReason.exactName => 'Exact brand name',
      BrandMatchReason.exactAlias => 'Exact alias',
      BrandMatchReason.exactNormalizedName => 'Exact normalized name',
      BrandMatchReason.wholePhrase => 'Brand found in product name',
      BrandMatchReason.prefix => 'Brand prefix match',
    };
  }
}
