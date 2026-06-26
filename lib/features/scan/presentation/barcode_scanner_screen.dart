import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _hasScanned = false;

  void _handleDetect(BarcodeCapture capture) {
    if (_hasScanned) {
      return;
    }

    final barcodes = capture.barcodes;

    if (barcodes.isEmpty) {
      return;
    }

    final value = barcodes.first.rawValue;

    if (value == null || value.trim().isEmpty) {
      return;
    }

    _hasScanned = true;
    Navigator.of(context).pop(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan barcode'),
      ),
      body: MobileScanner(
        onDetect: _handleDetect,
      ),
    );
  }
}