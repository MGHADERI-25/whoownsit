import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/data/ownership_json_parser.dart';
import 'package:whoownsit/features/ownership/domain/relationship_type.dart';
import 'package:whoownsit/features/ownership/domain/verification_status.dart';

void main() {
  group('OwnershipJsonParser', () {
    const parser = OwnershipJsonParser();

    test('parses companies', () {
      final companies = parser.parseCompanies([
        {
          'id': 'company_nestle_sa',
          'name': 'Nestlé S.A.',
          'aliases': ['Nestle', 'Nestlé'],
          'countryCode': 'CH',
          'website': 'https://www.nestle.com',
          'notes': 'Swiss multinational food and beverage company.',
        },
      ]);

      expect(companies, hasLength(1));
      expect(companies.first.id, 'company_nestle_sa');
      expect(companies.first.name, 'Nestlé S.A.');
      expect(companies.first.countryCode, 'CH');
    });

    test('parses sources', () {
      final sources = parser.parseSources([
        {
          'id': 'source_nestle_brands_page',
          'title': 'Nestlé brands overview',
          'url': 'https://www.nestle.com/brands',
          'publisher': 'Nestlé',
          'sourceType': 'company_website',
          'publishedAt': null,
          'accessedAt': '2026-06-26',
          'notes': 'Official Nestlé brand reference page.',
        },
      ]);

      expect(sources, hasLength(1));
      expect(sources.first.id, 'source_nestle_brands_page');
      expect(sources.first.accessedAt, DateTime(2026, 6, 26));
    });

    test('parses brands', () {
      final brands = parser.parseBrands([
        {
          'id': 'brand_kitkat',
          'name': 'KitKat',
          'aliases': ['Kit Kat', 'KITKAT'],
          'normalizedNames': ['kitkat', 'kit kat'],
          'ownerCompanyId': 'company_nestle_sa',
          'relationshipType': 'owned_by',
          'verificationStatus': 'maintainer_verified',
          'sourceIds': ['source_nestle_brands_page'],
          'effectiveFrom': '1988-01-01',
          'effectiveTo': null,
          'markets': [],
          'notes': 'Ownership may vary by market due to licensing arrangements.',
        },
      ]);

      expect(brands, hasLength(1));
      expect(brands.first.id, 'brand_kitkat');
      expect(brands.first.relationshipType, RelationshipType.ownedBy);
      expect(
        brands.first.verificationStatus,
        VerificationStatus.maintainerVerified,
      );
      expect(brands.first.effectiveFrom, DateTime(1988));
    });

    test('throws FormatException for unknown relationship type', () {
      expect(
        () => parser.parseBrands([
          {
            'id': 'brand_invalid',
            'name': 'Invalid',
            'aliases': [],
            'normalizedNames': ['invalid'],
            'ownerCompanyId': 'company_nestle_sa',
            'relationshipType': 'invalid_relationship',
            'verificationStatus': 'maintainer_verified',
            'sourceIds': [],
            'effectiveFrom': '2024-01-01',
            'effectiveTo': null,
            'markets': [],
            'notes': null,
          },
        ]),
        throwsFormatException,
      );
    });
  });
}