import 'package:flutter/material.dart';

import '../application/determine_ownership_use_case.dart';
import '../domain/brand_match_label_formatter.dart';
import '../domain/ownership_result.dart';
import '../domain/ownership_result_status.dart';

class DeveloperBrandLookupScreen extends StatefulWidget {
  const DeveloperBrandLookupScreen({
    required this.determineOwnershipUseCase,
    super.key,
  });

  final DetermineOwnershipUseCase determineOwnershipUseCase;

  @override
  State<DeveloperBrandLookupScreen> createState() =>
      _DeveloperBrandLookupScreenState();
}

class _DeveloperBrandLookupScreenState
    extends State<DeveloperBrandLookupScreen> {
  final TextEditingController _brandController = TextEditingController(
    text: 'KitKat Chunky',
  );

  bool _isLoading = false;
  OwnershipResult? _result;

  @override
  void dispose() {
    _brandController.dispose();
    super.dispose();
  }

  Future<void> _lookupBrand() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    final result = await widget.determineOwnershipUseCase.execute(
      brandNames: [_brandController.text],
    );

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
      appBar: AppBar(title: const Text('Developer brand test')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Test ownership matching directly by brand name, without Open Food Facts or barcode lookup.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand name',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _isLoading ? null : _lookupBrand,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(_isLoading ? 'Checking...' : 'Check brand'),
              ),
              const SizedBox(height: 24),
              if (result != null) _DeveloperOwnershipResultCard(result: result),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeveloperOwnershipResultCard extends StatelessWidget {
  const _DeveloperOwnershipResultCard({required this.result});

  final OwnershipResult result;

  @override
  Widget build(BuildContext context) {
    const formatter = BrandMatchLabelFormatter();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_titleForStatus(result.status)),
            const SizedBox(height: 8),
            Text(result.message),
            if (result.matchedBrandName != null) ...[
              const SizedBox(height: 12),
              Text('Brand: ${result.matchedBrandName}'),
            ],
            if (result.ownerCompanyName != null) ...[
              const SizedBox(height: 8),
              Text('Owner: ${result.ownerCompanyName}'),
            ],
            if (result.matchConfidence != null) ...[
              const SizedBox(height: 8),
              Text(
                'Match quality: ${formatter.confidenceLabel(result.matchConfidence!)}',
              ),
            ],
            if (result.matchReason != null) ...[
              const SizedBox(height: 8),
              Text(
                'Match reason: ${formatter.reasonLabel(result.matchReason!)}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _titleForStatus(OwnershipResultStatus status) {
    return switch (status) {
      OwnershipResultStatus.ownedByTarget => 'Owned by target company',
      OwnershipResultStatus.subsidiaryOfTarget =>
        'Subsidiary of target company',
      OwnershipResultStatus.relatedToTarget => 'Related to target company',
      OwnershipResultStatus.notTarget => 'Not target company',
      OwnershipResultStatus.unknown => 'Unknown',
      OwnershipResultStatus.productNotFound => 'Product not found',
      OwnershipResultStatus.brandNotFound => 'Brand not found',
    };
  }
}
