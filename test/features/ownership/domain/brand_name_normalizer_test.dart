import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/domain/brand_name_normalizer.dart';

void main() {
  group('BrandNameNormalizer', () {
    const normalizer = BrandNameNormalizer();

    test('trims whitespace', () {
      expect(normalizer.normalize('  KitKat  '), 'kitkat');
    });

    test('lowercases text', () {
      expect(normalizer.normalize('KITKAT'), 'kitkat');
    });

    test('collapses multiple spaces', () {
      expect(normalizer.normalize('Kit   Kat'), 'kit kat');
    });
  });
}