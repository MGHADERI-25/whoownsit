class Product {
  const Product({
    required this.barcode,
    required this.name,
    required this.brandNames,
    this.imageUrl,
  });

  final String barcode;
  final String? name;
  final List<String> brandNames;
  final String? imageUrl;
}