import '../domain/brand.dart';
import '../domain/company.dart';
import '../domain/ownership_source.dart';
import '../domain/relationship_type.dart';
import '../domain/verification_status.dart';

class OwnershipJsonParser {
  const OwnershipJsonParser();

  List<Company> parseCompanies(List<dynamic> json) {
    return json.map((item) {
      final map = _asMap(item);

      return Company(
        id: _requiredString(map, 'id'),
        name: _requiredString(map, 'name'),
        aliases: _stringList(map, 'aliases'),
        countryCode: _requiredString(map, 'countryCode'),
        website: _requiredString(map, 'website'),
        notes: _optionalString(map, 'notes'),
      );
    }).toList();
  }

  List<OwnershipSource> parseSources(List<dynamic> json) {
    return json.map((item) {
      final map = _asMap(item);

      return OwnershipSource(
        id: _requiredString(map, 'id'),
        title: _requiredString(map, 'title'),
        url: _requiredString(map, 'url'),
        publisher: _requiredString(map, 'publisher'),
        sourceType: _requiredString(map, 'sourceType'),
        accessedAt: DateTime.parse(_requiredString(map, 'accessedAt')),
        publishedAt: _optionalDateTime(map, 'publishedAt'),
        notes: _optionalString(map, 'notes'),
      );
    }).toList();
  }

  List<Brand> parseBrands(List<dynamic> json) {
    return json.map((item) {
      final map = _asMap(item);

      return Brand(
        id: _requiredString(map, 'id'),
        name: _requiredString(map, 'name'),
        aliases: _stringList(map, 'aliases'),
        normalizedNames: _stringList(map, 'normalizedNames'),
        ownerCompanyId: _requiredString(map, 'ownerCompanyId'),
        relationshipType: _relationshipType(
          _requiredString(map, 'relationshipType'),
        ),
        verificationStatus: _verificationStatus(
          _requiredString(map, 'verificationStatus'),
        ),
        sourceIds: _stringList(map, 'sourceIds'),
        effectiveFrom: DateTime.parse(_requiredString(map, 'effectiveFrom')),
        effectiveTo: _optionalDateTime(map, 'effectiveTo'),
        markets: _stringList(map, 'markets'),
        notes: _optionalString(map, 'notes'),
      );
    }).toList();
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw const FormatException('Expected JSON object.');
  }

  String _requiredString(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    throw FormatException('Missing or invalid required string: $key');
  }

  String? _optionalString(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value == null) {
      return null;
    }

    if (value is String) {
      return value;
    }

    throw FormatException('Invalid optional string: $key');
  }

  DateTime? _optionalDateTime(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value == null) {
      return null;
    }

    if (value is String && value.trim().isNotEmpty) {
      return DateTime.parse(value);
    }

    throw FormatException('Invalid optional date: $key');
  }

  List<String> _stringList(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value is List) {
      return value.map((item) {
        if (item is String) {
          return item;
        }

        throw FormatException('Invalid string list item in: $key');
      }).toList();
    }

    throw FormatException('Missing or invalid string list: $key');
  }

  RelationshipType _relationshipType(String value) {
    return switch (value) {
      'owned_by' => RelationshipType.ownedBy,
      'subsidiary_of' => RelationshipType.subsidiaryOf,
      'controlled_by' => RelationshipType.controlledBy,
      'licensed_by' => RelationshipType.licensedBy,
      'distributed_by' => RelationshipType.distributedBy,
      'joint_venture' => RelationshipType.jointVenture,
      'related_to' => RelationshipType.relatedTo,
      'not_owned_by' => RelationshipType.notOwnedBy,
      'unknown' => RelationshipType.unknown,
      _ => throw FormatException('Unknown relationship type: $value'),
    };
  }

  VerificationStatus _verificationStatus(String value) {
    return switch (value) {
      'unverified' => VerificationStatus.unverified,
      'community_submitted' => VerificationStatus.communitySubmitted,
      'source_verified' => VerificationStatus.sourceVerified,
      'maintainer_verified' => VerificationStatus.maintainerVerified,
      'disputed' => VerificationStatus.disputed,
      _ => throw FormatException('Unknown verification status: $value'),
    };
  }
}