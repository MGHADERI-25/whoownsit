class Company {
  const Company({
    required this.id,
    required this.name,
    required this.aliases,
    required this.countryCode,
    required this.website,
    this.notes,
  });

  final String id;
  final String name;
  final List<String> aliases;
  final String countryCode;
  final String website;
  final String? notes;
}