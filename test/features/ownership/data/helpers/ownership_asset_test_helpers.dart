import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoownsit/features/ownership/data/ownership_database.dart';
import 'package:whoownsit/features/ownership/data/ownership_database_loader.dart';

Future<OwnershipDatabase> loadOwnershipDatabase() {
  return OwnershipDatabaseLoader(assetBundle: rootBundle).load();
}

Future<List<dynamic>> loadOwnershipJsonArray(String assetPath) async {
  final jsonString = await rootBundle.loadString(assetPath);
  final decoded = jsonDecode(jsonString);

  expect(
    decoded,
    isA<List<dynamic>>(),
    reason: '$assetPath must contain a JSON array.',
  );

  return decoded as List<dynamic>;
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
