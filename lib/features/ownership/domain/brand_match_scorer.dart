import 'brand.dart';
import 'brand_match.dart';
import 'brand_name_normalizer.dart';

class BrandMatchScorer {
  const BrandMatchScorer({this.normalizer = const BrandNameNormalizer()});

  final BrandNameNormalizer normalizer;

  BrandMatch? findBestMatch({
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
          final scoredMatch = _score(
            brand: brand,
            normalizedInput: normalizedInput,
            candidate: candidate,
          );

          if (scoredMatch == null) {
            continue;
          }

          if (bestMatch == null || scoredMatch.isBetterThan(bestMatch)) {
            bestMatch = scoredMatch;
          }
        }
      }
    }

    return bestMatch?.toBrandMatch();
  }

  Set<String> _candidateNamesForBrand(Brand brand) {
    return <String>{
      normalizer.normalize(brand.name),
      ...brand.aliases.map(normalizer.normalize),
      ...brand.normalizedNames.map(normalizer.normalize),
    }..removeWhere((name) => name.isEmpty);
  }

  _ScoredBrandMatch? _score({
    required Brand brand,
    required String normalizedInput,
    required String candidate,
  }) {
    if (normalizedInput == candidate) {
      return _ScoredBrandMatch(
        brand: brand,
        score: 100,
        candidateLength: candidate.length,
        inputPosition: normalizedInput.indexOf(candidate),
        confidence: BrandMatchConfidence.exact,
        reason: BrandMatchReason.exactName,
      );
    }

    if (_containsWholePhrase(normalizedInput, candidate)) {
      return _ScoredBrandMatch(
        brand: brand,
        score: 80,
        candidateLength: candidate.length,
        inputPosition: normalizedInput.indexOf(candidate),
        confidence: BrandMatchConfidence.strong,
        reason: BrandMatchReason.wholePhrase,
      );
    }

    if (normalizedInput.startsWith(candidate)) {
      return _ScoredBrandMatch(
        brand: brand,
        score: 70,
        candidateLength: candidate.length,
        inputPosition: normalizedInput.indexOf(candidate),
        confidence: BrandMatchConfidence.strong,
        reason: BrandMatchReason.prefix,
      );
    }

    if (candidate.startsWith(normalizedInput)) {
      return _ScoredBrandMatch(
        brand: brand,
        score: 60,
        candidateLength: candidate.length,
        inputPosition: normalizedInput.indexOf(candidate),
        confidence: BrandMatchConfidence.possible,
        reason: BrandMatchReason.prefix,
      );
    }

    return null;
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
    required this.confidence,
    required this.reason,
  });

  final Brand brand;
  final int score;
  final int candidateLength;
  final int inputPosition;
  final BrandMatchConfidence confidence;
  final BrandMatchReason reason;

  bool isBetterThan(_ScoredBrandMatch other) {
    if (score != other.score) {
      return score > other.score;
    }

    if (candidateLength != other.candidateLength) {
      return candidateLength > other.candidateLength;
    }

    return inputPosition > other.inputPosition;
  }

  BrandMatch toBrandMatch() {
    return BrandMatch(brand: brand, confidence: confidence, reason: reason);
  }
}
