import 'package:bdo_event/features/watcher_screen/presentation/adapters.dart';
import 'package:flutter/material.dart';

class TestWatcherScannerAdapter implements WatcherScannerAdapter {
  const TestWatcherScannerAdapter();

  @override
  Widget buildView({required WatcherBarcodeHandler onDetected}) =>
      const ColoredBox(color: Colors.black);

  @override
  Future<void> toggleTorch() async {}

  @override
  void switchCamera() {}

  @override
  void dispose() {}
}

class TestWatcherVoiceAdapter implements WatcherVoiceAdapter {
  const TestWatcherVoiceAdapter();

  @override
  Future<void> configure({
    required String language,
    required double volume,
  }) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> speak(String message) async {}

  @override
  Future<void> dispose() async {}
}

class TestWatcherFeedbackAdapter implements WatcherFeedbackAdapter {
  const TestWatcherFeedbackAdapter();

  @override
  Future<void> mediumImpact() async {}
}
