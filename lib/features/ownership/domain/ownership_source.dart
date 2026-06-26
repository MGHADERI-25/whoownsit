class OwnershipSource {
  const OwnershipSource({
    required this.id,
    required this.title,
    required this.url,
    required this.publisher,
    required this.sourceType,
    required this.accessedAt,
    this.publishedAt,
    this.notes,
  });

  final String id;
  final String title;
  final String url;
  final String publisher;
  final String sourceType;
  final DateTime accessedAt;
  final DateTime? publishedAt;
  final String? notes;
}