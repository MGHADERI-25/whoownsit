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

    test('removes trademark symbols', () {
      expect(normalizer.normalize('Nescafé®'), 'nescafé');
      expect(normalizer.normalize('KitKat™'), 'kitkat');
    });

    test('normalizes separators to spaces', () {
      expect(normalizer.normalize('Nestlé-Nesquik'), 'nestlé nesquik');
      expect(normalizer.normalize('Kit/Kat'), 'kit kat');
    });

    test('normalizes ampersand to and', () {
      expect(normalizer.normalize('Coffee & Milk'), 'coffee and milk');
    });

    test('removes punctuation while preserving accented characters', () {
      expect(normalizer.normalize('Nescafé, Classic!'), 'nescafé classic');
    });
  });
}
