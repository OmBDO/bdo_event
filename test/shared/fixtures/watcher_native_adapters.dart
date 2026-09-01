import 'package:bdo_event/features/watcher_screen/presentation/adapters.dart';
import 'package:flutter/material.dart';

class RecordingScannerAdapter implements WatcherScannerAdapter {
  RecordingScannerAdapter({
    this.toggleTorchError,
    this.switchCameraError,
    this.disposeError,
  });

  final Object? toggleTorchError;
  final Object? switchCameraError;
  final Object? disposeError;
  WatcherBarcodeHandler? handler;
  int toggleTorchCalls = 0;
  int switchCameraCalls = 0;
  int disposeCalls = 0;

  @override
  Widget buildView({required WatcherBarcodeHandler onDetected}) {
    handler = onDetected;
    return const ColoredBox(color: Colors.black);
  }

  void detect(String value) => handler?.call(value);

  @override
  Future<void> toggleTorch() async {
    if (toggleTorchError != null) throw toggleTorchError!;
    toggleTorchCalls++;
  }

  @override
  void switchCamera() {
    if (switchCameraError != null) throw switchCameraError!;
    switchCameraCalls++;
  }

  @override
  void dispose() {
    if (disposeError != null) throw disposeError!;
    disposeCalls++;
  }
}

class RecordingVoiceAdapter implements WatcherVoiceAdapter {
  RecordingVoiceAdapter({
    this.configureError,
    this.setVolumeError,
    this.stopError,
    this.speakError,
    this.disposeError,
  });

  final Object? configureError;
  final Object? setVolumeError;
  final Object? stopError;
  final Object? speakError;
  final Object? disposeError;
  final languages = <String>[];
  final volumes = <double>[];
  final spoken = <String>[];
  int disposeCalls = 0;

  @override
  Future<void> configure({required String language, required double volume}) async {
    if (configureError != null) throw configureError!;
    languages.add(language);
  }

  @override
  Future<void> setVolume(double volume) async {
    if (setVolumeError != null) throw setVolumeError!;
    volumes.add(volume);
  }

  @override
  Future<void> stop() async {
    if (stopError != null) throw stopError!;
  }

  @override
  Future<void> speak(String message) async {
    if (speakError != null) throw speakError!;
    spoken.add(message);
  }

  @override
  Future<void> dispose() async {
    if (disposeError != null) throw disposeError!;
    disposeCalls++;
  }
}

class RecordingFeedbackAdapter implements WatcherFeedbackAdapter {
  RecordingFeedbackAdapter({this.error});

  final Object? error;
  int mediumImpactCalls = 0;

  @override
  Future<void> mediumImpact() async {
    if (error != null) throw error!;
    mediumImpactCalls++;
  }
}
