import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:whoownsit/features/ownership/data/ownership_database.dart';
import 'package:whoownsit/features/ownership/data/ownership_database_loader.dart';

Future<OwnershipDatabase> loadOwnershipDatabase() {
  return OwnershipDatabaseLoader(assetBundle: rootBundle).load();
}

Future<List<dynamic>> loadOwnershipJsonArray(String assetPath) async {
  late final String jsonString;

  try {
    jsonString = await rootBundle.loadString(assetPath);
  } on Object catch (error) {
    throw StateError(
      'Failed to load ownership JSON asset "$assetPath": $error',
    );
  }

  late final dynamic decoded;

  try {
    decoded = jsonDecode(jsonString);
  } on FormatException catch (error) {
    throw FormatException(
      'Ownership asset "$assetPath" contains invalid JSON: '
      '${error.message}',
      null,
      error.offset,
    );
  }

  if (decoded is! List<dynamic>) {
    throw FormatException(
      'Ownership asset "$assetPath" must contain a JSON array, '
      'but decoded ${decoded.runtimeType}.',
    );
  }

  return decoded;
}

DateTime? parseStrictDate(String value) {
  final parsed = DateTime.tryParse(value);

  if (parsed == null) {
    return null;
  }

  final expected =
      '${parsed.year.toString().padLeft(4, '0')}-'
      '${parsed.month.toString().padLeft(2, '0')}-'
      '${parsed.day.toString().padLeft(2, '0')}';

  return expected == value ? parsed : null;
}
