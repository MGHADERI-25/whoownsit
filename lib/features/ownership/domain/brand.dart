import 'relationship_type.dart';
import 'verification_status.dart';

class Brand {
  const Brand({
    required this.id,
    required this.name,
    required this.aliases,
    required this.normalizedNames,
    required this.ownerCompanyId,
    required this.relationshipType,
    required this.verificationStatus,
    required this.sourceIds,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.markets,
    this.notes,
  });

  final String id;
  final String name;
  final List<String> aliases;
  final List<String> normalizedNames;
  final String ownerCompanyId;
  final RelationshipType relationshipType;
  final VerificationStatus verificationStatus;
  final List<String> sourceIds;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final List<String> markets;
  final String? notes;
}