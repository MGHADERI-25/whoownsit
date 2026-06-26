class BrandNameNormalizer {
  const BrandNameNormalizer();

  String normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}