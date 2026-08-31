import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

typedef WatcherBarcodeHandler = void Function(String? value);

abstract interface class WatcherScannerAdapter {
  Widget buildView({required WatcherBarcodeHandler onDetected});

  Future<void> toggleTorch();

  void switchCamera();

  void dispose();
}

class MobileScannerAdapter implements WatcherScannerAdapter {
  MobileScannerAdapter({MobileScannerController? controller})
    : _controller = controller ?? MobileScannerController();

  final MobileScannerController _controller;

  @override
  Widget buildView({required WatcherBarcodeHandler onDetected}) {
    return MobileScanner(
      controller: _controller,
      onDetect: (capture) {
        onDetected(capture.barcodes.firstOrNull?.rawValue);
      },
    );
  }

  @override
  Future<void> toggleTorch() => _controller.toggleTorch();

  @override
  void switchCamera() => _controller.switchCamera();

  @override
  void dispose() => _controller.dispose();
}
