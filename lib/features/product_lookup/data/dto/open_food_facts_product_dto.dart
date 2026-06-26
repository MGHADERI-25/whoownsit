import '../../domain/product.dart';

class OpenFoodFactsProductDto {
  const OpenFoodFactsProductDto({
    required this.barcode,
    required this.productName,
    required this.brandNames,
    required this.imageUrl,
  });

  final String barcode;
  final String? productName;
  final List<String> brandNames;
  final String? imageUrl;

  factory OpenFoodFactsProductDto.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;

    if (product == null) {
      throw const FormatException('Missing product object.');
    }

    final brands = (product['brands'] as String? ?? '')
        .split(',')
        .map((brand) => brand.trim())
        .where((brand) => brand.isNotEmpty)
        .toList();

    return OpenFoodFactsProductDto(
      barcode: json['code'] as String? ?? '',
      productName: product['product_name'] as String?,
      brandNames: brands,
      imageUrl: product['image_front_url'] as String?,
    );
  }

  Product toDomain() {
    return Product(
      barcode: barcode,
      name: productName,
      brandNames: brandNames,
      imageUrl: imageUrl,
    );
  }
}