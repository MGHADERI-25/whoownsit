// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:whoownsit/features/ownership/application/determine_ownership_use_case.dart';
import 'package:whoownsit/features/ownership/data/ownership_json_parser.dart';
import 'package:whoownsit/features/ownership/domain/brand.dart';
import 'package:whoownsit/features/ownership/domain/company.dart';
import 'package:whoownsit/features/ownership/domain/ownership_repository.dart';
import 'package:whoownsit/features/ownership/domain/ownership_source.dart';
import 'package:whoownsit/features/product_lookup/application/lookup_product_by_barcode_use_case.dart';
import 'package:whoownsit/features/product_lookup/application/lookup_product_ownership_by_barcode_use_case.dart';
import 'package:whoownsit/features/product_lookup/data/api/open_food_facts_client.dart';
import 'package:whoownsit/features/product_lookup/data/repository/open_food_facts_product_repository.dart';

Future<void> main(List<String> args) async {
  final barcode = args.isNotEmpty ? args.first : '3017620422003';

  final parser = OwnershipJsonParser();

  final companiesJson = jsonDecode(
    File('assets/data/ownership/companies.json').readAsStringSync(),
  ) as List<dynamic>;

  final brandsJson = jsonDecode(
    File('assets/data/ownership/brands.json').readAsStringSync(),
  ) as List<dynamic>;

  final sourcesJson = jsonDecode(
    File('assets/data/ownership/sources.json').readAsStringSync(),
  ) as List<dynamic>;

  final ownershipRepository = SmokeOwnershipRepository(
    companies: parser.parseCompanies(companiesJson),
    brands: parser.parseBrands(brandsJson),
    sources: parser.parseSources(sourcesJson),
  );

  final productRepository = OpenFoodFactsProductRepository(
    client: OpenFoodFactsClient(),
  );

  final useCase = LookupProductOwnershipByBarcodeUseCase(
    lookupProductByBarcodeUseCase: LookupProductByBarcodeUseCase(
      productRepository: productRepository,
    ),
    determineOwnershipUseCase: DetermineOwnershipUseCase(
      ownershipRepository: ownershipRepository,
    ),
  );

  final result = await useCase.execute(barcode);

  final ownership = result.ownership;

  print(ownership.status);
  print(ownership.matchedBrandName);
  print(ownership.ownerCompanyName);
  print(ownership.relationshipType);
  print(ownership.verificationStatus);
  print(ownership.sourceIds);
  print(ownership.message);
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