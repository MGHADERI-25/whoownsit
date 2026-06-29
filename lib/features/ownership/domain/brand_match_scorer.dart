import 'brand.dart';
import 'brand_name_normalizer.dart';

class BrandMatchScorer {
  const BrandMatchScorer({this.normalizer = const BrandNameNormalizer()});

  final BrandNameNormalizer normalizer;

  Brand? findBestMatch({
    required List<String> inputBrandNames,
    required List<Brand> knownBrands,
  }) {
    for (final input in inputBrandNames) {
      final normalizedInput = normalizer.normalize(input);

      for (final brand in knownBrands) {
        final candidates = <String>{
          normalizer.normalize(brand.name),
          ...brand.aliases.map(normalizer.normalize),
          ...brand.normalizedNames.map(normalizer.normalize),
        };

        // Exact match
        if (candidates.contains(normalizedInput)) {
          return brand;
        }

        // Whole-word / prefix match
        for (final candidate in candidates) {
          if (normalizedInput.startsWith(candidate)) {
            return brand;
          }

          if (normalizedInput.contains(candidate)) {
            return brand;
          }

          if (candidate.contains(normalizedInput)) {
            return brand;
          }
        }
      }
    }

    return null;
  }
}
