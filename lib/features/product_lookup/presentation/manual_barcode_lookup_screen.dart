import 'package:flutter/material.dart';

import '../../ownership/application/determine_ownership_use_case.dart';
import '../../ownership/data/local_ownership_repository.dart';
import '../../ownership/data/ownership_database_loader.dart';
import '../../ownership/domain/ownership_result.dart';
import '../../ownership/domain/ownership_result_status.dart';
import '../application/lookup_product_by_barcode_use_case.dart';
import '../application/lookup_product_ownership_by_barcode_use_case.dart';
import '../data/api/open_food_facts_client.dart';
import '../data/repository/open_food_facts_product_repository.dart';

class ManualBarcodeLookupScreen extends StatefulWidget {
  const ManualBarcodeLookupScreen({super.key});

  @override
  State<ManualBarcodeLookupScreen> createState() =>
      _ManualBarcodeLookupScreenState();
}

class _ManualBarcodeLookupScreenState extends State<ManualBarcodeLookupScreen> {
  final TextEditingController _barcodeController = TextEditingController(
    text: '3017620422003',
  );

  bool _isLoading = false;
  OwnershipResult? _result;

  late final LookupProductOwnershipByBarcodeUseCase _useCase =
      LookupProductOwnershipByBarcodeUseCase(
    lookupProductByBarcodeUseCase: LookupProductByBarcodeUseCase(
      productRepository: OpenFoodFactsProductRepository(
        client: OpenFoodFactsClient(),
      ),
    ),
    determineOwnershipUseCase: DetermineOwnershipUseCase(
      ownershipRepository: const LocalOwnershipRepository(
        databaseLoader: OwnershipDatabaseLoader(),
      ),
    ),
  );

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    final result = await _useCase.execute(_barcodeController.text);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WhoOwnsIt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _barcodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Barcode',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isLoading ? null : _lookup,
              child: Text(_isLoading ? 'Looking up...' : 'Lookup ownership'),
            ),
            const SizedBox(height: 24),
            if (result != null) _OwnershipResultCard(result: result),
          ],
        ),
      ),
    );
  }
}

class _OwnershipResultCard extends StatelessWidget {
  const _OwnershipResultCard({
    required this.result,
  });

  final OwnershipResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_titleForStatus(result.status)),
            const SizedBox(height: 8),
            Text(result.message),
            if (result.matchedBrandName != null) ...[
              const SizedBox(height: 8),
              Text('Brand: ${result.matchedBrandName}'),
            ],
            if (result.ownerCompanyName != null) ...[
              const SizedBox(height: 8),
              Text('Owner: ${result.ownerCompanyName}'),
            ],
          ],
        ),
      ),
    );
  }

  String _titleForStatus(OwnershipResultStatus status) {
    return switch (status) {
      OwnershipResultStatus.ownedByTarget => 'Owned by Nestlé',
      OwnershipResultStatus.subsidiaryOfTarget => 'Nestlé subsidiary',
      OwnershipResultStatus.relatedToTarget => 'Related to Nestlé',
      OwnershipResultStatus.notTarget => 'Not Nestlé',
      OwnershipResultStatus.unknown => 'Unknown',
      OwnershipResultStatus.productNotFound => 'Product not found',
      OwnershipResultStatus.brandNotFound => 'Brand not found',
    };
  }
}