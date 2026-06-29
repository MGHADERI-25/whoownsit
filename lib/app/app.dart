import 'package:flutter/material.dart';
import 'app_constants.dart';
import '../features/product_lookup/presentation/manual_barcode_lookup_screen.dart';
import 'app_dependencies.dart';
import 'app_theme.dart';

class WhoOwnsItApp extends StatefulWidget {
  const WhoOwnsItApp({super.key});

  @override
  State<WhoOwnsItApp> createState() => _WhoOwnsItAppState();
}

class _WhoOwnsItAppState extends State<WhoOwnsItApp> {
  late final AppDependencies dependencies = AppDependencies();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: ManualBarcodeLookupScreen(
        lookupProductOwnershipByBarcodeUseCase:
            dependencies.lookupProductOwnershipByBarcodeUseCase,
      ),
    );
  }
}