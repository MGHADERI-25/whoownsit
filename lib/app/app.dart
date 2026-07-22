import 'package:flutter/material.dart';
import 'app_constants.dart';
import '../features/product_lookup/presentation/manual_barcode_lookup_screen.dart';
import 'app_dependencies.dart';
import 'app_theme.dart';
import 'package:flutter/foundation.dart';
import '../features/ownership/presentation/developer_brand_lookup_screen.dart';

class WhoOwnsItApp extends StatefulWidget {
  const WhoOwnsItApp({this.dependencies, super.key});

  final AppDependencies? dependencies;

  @override
  State<WhoOwnsItApp> createState() => _WhoOwnsItAppState();
}

class _WhoOwnsItAppState extends State<WhoOwnsItApp> {
  late final AppDependencies dependencies =
      widget.dependencies ?? AppDependencies();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: ManualBarcodeLookupScreen(
        lookupProductOwnershipByBarcodeUseCase:
            dependencies.lookupProductOwnershipByBarcodeUseCase,
        developerBrandLookupScreenBuilder: kDebugMode
            ? (context) => DeveloperBrandLookupScreen(
                determineOwnershipUseCase:
                    dependencies.determineOwnershipUseCase,
              )
            : null,
      ),
    );
  }
}
