import 'brand.dart';

class BrandMatch {
  const BrandMatch({
    required this.brand,
    required this.confidence,
    required this.reason,
  });

  final Brand brand;
  final BrandMatchConfidence confidence;
  final BrandMatchReason reason;
}

enum BrandMatchConfidence { exact, strong, possible }

enum BrandMatchReason {
  exactName,
  exactAlias,
  exactNormalizedName,
  wholePhrase,
  prefix,
}
