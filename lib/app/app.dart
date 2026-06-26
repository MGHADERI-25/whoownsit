import 'package:flutter/material.dart';

import '../features/product_lookup/presentation/manual_barcode_lookup_screen.dart';
import 'app_dependencies.dart';

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
      title: 'WhoOwnsIt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: ManualBarcodeLookupScreen(
        lookupProductOwnershipByBarcodeUseCase:
            dependencies.lookupProductOwnershipByBarcodeUseCase,
      ),
    );
  }
}