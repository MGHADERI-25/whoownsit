import 'package:flutter/material.dart';
import '../../scan/presentation/barcode_scanner_screen.dart';
import '../../../app/app_constants.dart';
import '../../ownership/domain/ownership_result.dart';
import '../../ownership/domain/ownership_result_status.dart';
import '../application/lookup_product_ownership_by_barcode_use_case.dart';
import '../../ownership/domain/brand_match_label_formatter.dart';

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
    const matchLabelFormatter = BrandMatchLabelFormatter();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: presentation.color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(presentation.icon, color: presentation.color, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    presentation.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: presentation.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(result.message, style: theme.textTheme.bodyLarge),
                if (result.matchedBrandName != null) ...[
                  const SizedBox(height: 16),
                  _ResultDetailBlock(
                    label: 'Brand',
                    value: result.matchedBrandName!,
                  ),
                ],
                if (result.ownerCompanyName != null) ...[
                  const SizedBox(height: 12),
                  _ResultDetailBlock(
                    label: 'Owner',
                    value: result.ownerCompanyName!,
                  ),
                ],
                if (result.verificationStatus != null) ...[
                  const SizedBox(height: 12),
                  _ResultDetailBlock(
                    label: 'Verification',
                    value: result.verificationStatus!.name,
                  ),
                ],
                if (result.matchConfidence != null) ...[
                  const SizedBox(height: 12),
                  _ResultDetailBlock(
                    label: 'Match quality',
                    value: matchLabelFormatter.confidenceLabel(
                      result.matchConfidence!,
                    ),
                  ),
                ],
                if (result.matchReason != null) ...[
                  const SizedBox(height: 12),
                  _ResultDetailBlock(
                    label: 'Match reason',
                    value: matchLabelFormatter.reasonLabel(result.matchReason!),
                  ),
                ],
              ],
            ),
          ),
        ],
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

class _ResultDetailBlock extends StatelessWidget {
  const _ResultDetailBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.bodyLarge),
      ],
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
