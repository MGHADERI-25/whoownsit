import 'package:flutter/material.dart';
import '../../scan/presentation/barcode_scanner_screen.dart';

import '../../ownership/domain/ownership_result.dart';
import '../../ownership/domain/ownership_result_status.dart';
import '../application/lookup_product_ownership_by_barcode_use_case.dart';

class ManualBarcodeLookupScreen extends StatefulWidget {
  const ManualBarcodeLookupScreen({
    required this.lookupProductOwnershipByBarcodeUseCase,
    super.key,
  });

  final LookupProductOwnershipByBarcodeUseCase
      lookupProductOwnershipByBarcodeUseCase;

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

    final result = await widget.lookupProductOwnershipByBarcodeUseCase.execute(
      _barcodeController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _result = result;
    });
  }

  Future<void> _scanBarcode() async {
    final scannedBarcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const BarcodeScannerScreen(),
      ),
    );

    if (scannedBarcode == null || !mounted) {
      return;
    }

    _barcodeController.text = scannedBarcode;
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

  const SizedBox(height: 12),

  OutlinedButton.icon(
    onPressed: _scanBarcode,
    icon: const Icon(Icons.qr_code_scanner),
    label: const Text('Scan barcode'),
  ),

  const SizedBox(height: 16),

  FilledButton(
    onPressed: _isLoading ? null : _lookup,
    child: Text(
      _isLoading ? 'Looking up...' : 'Lookup ownership',
    ),
  ),

  const SizedBox(height: 24),

  if (result != null)
    _OwnershipResultCard(result: result),
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