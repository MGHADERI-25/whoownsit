class BrandNameNormalizer {
  const BrandNameNormalizer();

  String normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[®™©]'), '')
        .replaceAll(RegExp(r'[-_/\\|]+'), ' ')
        .replaceAll(RegExp(r'[^\w\s\u00C0-\u024F]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
