import 'dart:convert';

import 'package:flutter/services.dart';

import 'ownership_asset_paths.dart';
import 'ownership_database.dart';
import 'ownership_json_parser.dart';

class OwnershipDatabaseLoader {
  const OwnershipDatabaseLoader({
    this.assetBundle,
    OwnershipJsonParser? parser,
  }) : _parser = parser ?? const OwnershipJsonParser();

  final AssetBundle? assetBundle;
  final OwnershipJsonParser _parser;

  Future<OwnershipDatabase> load() async {
    final bundle = assetBundle ?? rootBundle;

    final companiesJson = await _loadJsonList(
      bundle,
      OwnershipAssetPaths.companies,
    );
    final brandsJson = await _loadJsonList(
      bundle,
      OwnershipAssetPaths.brands,
    );
    final sourcesJson = await _loadJsonList(
      bundle,
      OwnershipAssetPaths.sources,
    );

    return OwnershipDatabase(
      companies: _parser.parseCompanies(companiesJson),
      brands: _parser.parseBrands(brandsJson),
      sources: _parser.parseSources(sourcesJson),
    );
  }

  Future<List<dynamic>> _loadJsonList(
    AssetBundle assetBundle,
    String path,
  ) async {
    final jsonString = await assetBundle.loadString(path);
    final decoded = jsonDecode(jsonString);

    if (decoded is List) {
      return decoded;
    }

    throw FormatException('Expected JSON array in asset: $path');
  }
}