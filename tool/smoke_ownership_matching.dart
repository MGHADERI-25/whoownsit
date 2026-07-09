import 'dart:convert';
import 'dart:io';

import 'package:whoownsit/features/ownership/application/determine_ownership_use_case.dart';
import 'package:whoownsit/features/ownership/data/ownership_json_parser.dart';
import 'package:whoownsit/features/ownership/domain/brand.dart';
import 'package:whoownsit/features/ownership/domain/company.dart';
import 'package:whoownsit/features/ownership/domain/ownership_repository.dart';
import 'package:whoownsit/features/ownership/domain/ownership_source.dart';

Future<void> main() async {
  final parser = OwnershipJsonParser();

  final companiesJson =
      jsonDecode(
            File('assets/data/ownership/companies.json').readAsStringSync(),
          )
          as List<dynamic>;

  final brandsJson =
      jsonDecode(File('assets/data/ownership/brands.json').readAsStringSync())
          as List<dynamic>;

  final sourcesJson =
      jsonDecode(File('assets/data/ownership/sources.json').readAsStringSync())
          as List<dynamic>;

  final useCase = DetermineOwnershipUseCase(
    ownershipRepository: SmokeOwnershipRepository(
      companies: parser.parseCompanies(companiesJson),
      brands: parser.parseBrands(brandsJson),
      sources: parser.parseSources(sourcesJson),
    ),
  );

  final testCases = <List<String>>[
    ['KitKat Chunky'],
    ['Nestlé KitKat'],
    ['Nescafé Classic'],
    ['Maggi Malaysia'],
    ['Purina ONE'],
    ['Nutella'],
    ['Snickers'],
    ['Twix'],
    ['M&M\'s'],
    ['Skittles'],
    ['Mars Bar'],
    ['Unknown Brand'],
  ];

  for (final brandNames in testCases) {
    final result = await useCase.execute(brandNames: brandNames);

    stdout.writeln('Input: ${brandNames.join(', ')}');
    stdout.writeln('Status: ${result.status}');
    stdout.writeln('Matched brand: ${result.matchedBrandName}');
    stdout.writeln('Owner: ${result.ownerCompanyName}');
    stdout.writeln('Confidence: ${result.matchConfidence}');
    stdout.writeln('Reason: ${result.matchReason}');
    stdout.writeln('Message: ${result.message}');
    stdout.writeln('---');
  }
}

class SmokeOwnershipRepository implements OwnershipRepository {
  const SmokeOwnershipRepository({
    required this.companies,
    required this.brands,
    required this.sources,
  });

  final List<Company> companies;
  final List<Brand> brands;
  final List<OwnershipSource> sources;

  @override
  Future<List<Company>> getCompanies() async => companies;

  @override
  Future<List<Brand>> getBrands() async => brands;

  @override
  Future<List<OwnershipSource>> getSources() async => sources;
}
