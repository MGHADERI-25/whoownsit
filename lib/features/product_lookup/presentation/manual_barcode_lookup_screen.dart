import 'package:flutter/material.dart';
import '../../scan/presentation/barcode_scanner_screen.dart';
import '../../../app/app_constants.dart';
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
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );

    if (scannedBarcode == null || !mounted) {
      return;
    }

    _barcodeController.text = scannedBarcode;
    await _lookup();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Product lookup',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scan a barcode or enter one manually to check product ownership.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _barcodeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Barcode',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _scanBarcode,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan barcode'),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _isLoading ? null : _lookup,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(
                          _isLoading ? 'Looking up...' : 'Lookup ownership',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (result != null) _OwnershipResultCard(result: result),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnershipResultCard extends StatelessWidget {
  const _OwnershipResultCard({required this.result});

  final OwnershipResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presentation = _presentationForStatus(result.status);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(presentation.icon, color: presentation.color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    presentation.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: presentation.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(result.message),
                  if (result.matchedBrandName != null) ...[
                    const SizedBox(height: 12),
                    _ResultDetailRow(
                      label: 'Brand',
                      value: result.matchedBrandName!,
                    ),
                  ],
                  if (result.ownerCompanyName != null) ...[
                    const SizedBox(height: 8),
                    _ResultDetailRow(
                      label: 'Owner',
                      value: result.ownerCompanyName!,
                    ),
                  ],
                  if (result.verificationStatus != null) ...[
                    const SizedBox(height: 8),
                    _ResultDetailRow(
                      label: 'Verification',
                      value: result.verificationStatus!.name,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ResultPresentation _presentationForStatus(OwnershipResultStatus status) {
    return switch (status) {
      OwnershipResultStatus.ownedByTarget => _ResultPresentation(
        title: 'Owned by Nestlé',
        icon: Icons.warning_amber_rounded,
        color: Colors.red,
      ),
      OwnershipResultStatus.subsidiaryOfTarget => _ResultPresentation(
        title: 'Nestlé subsidiary',
        icon: Icons.account_tree_outlined,
        color: Colors.deepOrange,
      ),
      OwnershipResultStatus.relatedToTarget => _ResultPresentation(
        title: 'Related to Nestlé',
        icon: Icons.link,
        color: Colors.orange,
      ),
      OwnershipResultStatus.notTarget => _ResultPresentation(
        title: 'Not Nestlé',
        icon: Icons.check_circle_outline,
        color: Colors.green,
      ),
      OwnershipResultStatus.unknown => _ResultPresentation(
        title: 'Unknown',
        icon: Icons.help_outline,
        color: Colors.blueGrey,
      ),
      OwnershipResultStatus.productNotFound => _ResultPresentation(
        title: 'Product not found',
        icon: Icons.search_off,
        color: Colors.blueGrey,
      ),
      OwnershipResultStatus.brandNotFound => _ResultPresentation(
        title: 'Brand not found',
        icon: Icons.sell_outlined,
        color: Colors.blueGrey,
      ),
    };
  }
}

class _ResultDetailRow extends StatelessWidget {
  const _ResultDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium,
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _ResultPresentation {
  const _ResultPresentation({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;
}
