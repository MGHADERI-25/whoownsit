import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/product_lookup/data/dto/open_food_facts_product_dto.dart';

void main() {
  group('OpenFoodFactsProductDto', () {
    test('parses product JSON', () {
      final dto = OpenFoodFactsProductDto.fromJson({
        'code': '7613036242925',
        'product': {
          'product_name': 'KitKat',
          'brands': 'KitKat, Nestlé',
          'image_front_url': 'https://example.com/image.jpg',
        },
      });

      expect(dto.barcode, '7613036242925');
      expect(dto.productName, 'KitKat');
      expect(dto.brandNames, ['KitKat', 'Nestlé']);
      expect(dto.imageUrl, 'https://example.com/image.jpg');
    });

    test('maps DTO to domain model', () {
      final dto = OpenFoodFactsProductDto(
        barcode: '7613036242925',
        productName: 'KitKat',
        brandNames: const ['KitKat', 'Nestlé'],
        imageUrl: 'https://example.com/image.jpg',
      );

      final product = dto.toDomain();

      expect(product.barcode, '7613036242925');
      expect(product.name, 'KitKat');
      expect(product.brandNames, ['KitKat', 'Nestlé']);
      expect(product.imageUrl, 'https://example.com/image.jpg');
    });

    test('throws when product object is missing', () {
      expect(
        () => OpenFoodFactsProductDto.fromJson({}),
        throwsFormatException,
      );
    });
  });
}