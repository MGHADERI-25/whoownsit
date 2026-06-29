import 'brand.dart';
import 'brand_name_normalizer.dart';

class BrandMatchScorer {
  const BrandMatchScorer({this.normalizer = const BrandNameNormalizer()});

  final BrandNameNormalizer normalizer;

  Brand? findBestMatch({
    required List<String> inputBrandNames,
    required List<Brand> knownBrands,
  }) {
    _ScoredBrandMatch? bestMatch;

    for (final input in inputBrandNames) {
      final normalizedInput = normalizer.normalize(input);

      if (normalizedInput.isEmpty) {
        continue;
      }

      for (final brand in knownBrands) {
        final candidates = _candidateNamesForBrand(brand);

        for (final candidate in candidates) {
          final score = _score(
            normalizedInput: normalizedInput,
            candidate: candidate,
          );

          if (score == 0) {
            continue;
          }

          final match = _ScoredBrandMatch(
            brand: brand,
            score: score,
            candidateLength: candidate.length,
            inputPosition: normalizedInput.indexOf(candidate),
          );

          if (bestMatch == null || match.isBetterThan(bestMatch)) {
            bestMatch = match;
          }
        }
      }
    }

    return bestMatch?.brand;
  }

  Set<String> _candidateNamesForBrand(Brand brand) {
    return <String>{
      normalizer.normalize(brand.name),
      ...brand.aliases.map(normalizer.normalize),
      ...brand.normalizedNames.map(normalizer.normalize),
    }..removeWhere((name) => name.isEmpty);
  }

  int _score({required String normalizedInput, required String candidate}) {
    if (normalizedInput == candidate) {
      return 100;
    }

    if (_containsWholePhrase(normalizedInput, candidate)) {
      return 80;
    }

    if (normalizedInput.startsWith(candidate)) {
      return 70;
    }

    if (candidate.startsWith(normalizedInput)) {
      return 60;
    }

    return 0;
  }

  bool _containsWholePhrase(String input, String candidate) {
    return input == candidate ||
        input.startsWith('$candidate ') ||
        input.endsWith(' $candidate') ||
        input.contains(' $candidate ');
  }
}

class _ScoredBrandMatch {
  const _ScoredBrandMatch({
    required this.brand,
    required this.score,
    required this.candidateLength,
    required this.inputPosition,
  });

  final Brand brand;
  final int score;
  final int candidateLength;
  final int inputPosition;

  bool isBetterThan(_ScoredBrandMatch other) {
    if (score != other.score) {
      return score > other.score;
    }

    if (candidateLength != other.candidateLength) {
      return candidateLength > other.candidateLength;
    }

    return inputPosition > other.inputPosition;
  }
}
