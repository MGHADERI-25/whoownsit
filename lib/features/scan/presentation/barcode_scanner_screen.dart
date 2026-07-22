import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:collection/collection.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );

  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_controller.start());
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        unawaited(_controller.stop());
    }
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_hasScanned) {
      return;
    }

    final barcode = capture.barcodes.where((candidate) {
      final value = candidate.rawValue;
      return value != null && value.trim().isNotEmpty;
    }).firstOrNull;

    final value = barcode?.rawValue?.trim();

    if (value == null || value.isEmpty) {
      return;
    }

    _hasScanned = true;

    await _controller.stop();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(value);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetect,
            errorBuilder: (context, error) {
              return _ScannerError(
                error: error,
                onClose: () => Navigator.of(context).pop(),
              );
            },
          ),
          const _ScannerOverlay(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.filled(
                    tooltip: 'Close scanner',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                  Row(
                    children: [
                      ValueListenableBuilder<MobileScannerState>(
                        valueListenable: _controller,
                        builder: (context, state, child) {
                          final torchState = state.torchState;

                          return IconButton.filled(
                            tooltip: torchState == TorchState.on
                                ? 'Turn flashlight off'
                                : 'Turn flashlight on',
                            onPressed: torchState == TorchState.unavailable
                                ? null
                                : () => _controller.toggleTorch(),
                            icon: Icon(
                              torchState == TorchState.on
                                  ? Icons.flash_on
                                  : Icons.flash_off,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      IconButton.filled(
                        tooltip: 'Switch camera',
                        onPressed: () => _controller.switchCamera(),
                        icon: const Icon(Icons.cameraswitch),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 280,
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Place the product barcode inside the frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.error, required this.onClose});

  final MobileScannerException error;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isPermissionDenied =
        error.errorCode == MobileScannerErrorCode.permissionDenied;

    return ColoredBox(
      color: Colors.black,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPermissionDenied
                    ? Icons.no_photography_outlined
                    : Icons.camera_alt_outlined,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                isPermissionDenied
                    ? 'Camera permission is required'
                    : 'Camera unavailable',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isPermissionDenied
                    ? 'Allow camera access in your device settings, then try again.'
                    : 'The barcode scanner could not start. Close the scanner and try again.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                label: const Text('Close scanner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
