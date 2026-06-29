import 'relationship_type.dart';
import 'verification_status.dart';
import 'ownership_result_status.dart';
import 'brand_match.dart';

class OwnershipResult {
  const OwnershipResult({
    required this.status,
    this.matchedBrandId,
    this.matchedBrandName,
    this.matchConfidence,
    this.matchReason,
    this.ownerCompanyId,
    this.ownerCompanyName,
    this.relationshipType,
    this.verificationStatus,
    this.sourceIds = const [],
    required this.message,
  });

  final OwnershipResultStatus status;
  final String? matchedBrandId;
  final String? matchedBrandName;
  final BrandMatchConfidence? matchConfidence;
  final BrandMatchReason? matchReason;
  final String? ownerCompanyId;
  final String? ownerCompanyName;
  final RelationshipType? relationshipType;
  final VerificationStatus? verificationStatus;
  final List<String> sourceIds;
  final String message;
}
