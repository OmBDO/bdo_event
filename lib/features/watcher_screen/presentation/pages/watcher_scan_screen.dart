import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_cubit.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_state.dart';
import 'package:bdo_event/features/watcher_screen/presentation/widget/scan_history_sheet.dart';
import 'package:bdo_event/features/watcher_screen/presentation/widget/scanner_dashboard.dart';
import 'package:bdo_event/features/watcher_screen/presentation/widget/scanner_icon_button.dart';
import 'package:bdo_event/features/watcher_screen/presentation/widget/scanner_target_overlay.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class WatcherScanScreen extends StatefulWidget {
  const WatcherScanScreen({super.key});

  @override
  State<WatcherScanScreen> createState() => _WatcherScanScreenState();
}

class _WatcherScanScreenState extends State<WatcherScanScreen> {
  final _controller = MobileScannerController();
  final _manualEntryController = TextEditingController();
  final _speech = FlutterTts();
  Timer? _scanCooldown;
  bool _torchEnabled = false;

  @override
  void initState() {
    super.initState();
    _configureSpeech();
  }

  Future<void> _configureSpeech() async {
    await _speech.setLanguage('en-IN');
    await _speech.setSpeechRate(0.5);
    await _speech.setVolume(1.0);
    await _speech.setPitch(1.0);
  }

  Future<void> _announce(String message) async {
    await _speech.stop();
    await _speech.speak(message);
  }

  @override
  void dispose() {
    _scanCooldown?.cancel();
    _controller.dispose();
    _manualEntryController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatcherScanCubit, WatcherScanState>(
      listenWhen: (previous, current) =>
          (previous.message != current.message && current.message != null) ||
          (previous.status != current.status &&
              current.status == WatcherScanStatus.valid),
      listener: (context, state) {
        if (state.status == WatcherScanStatus.valid) {
          HapticFeedback.mediumImpact();
        }
        if (state.message != null) {
          _announce(state.message!);
        }
      },
      child: BlocBuilder<WatcherScanCubit, WatcherScanState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text(AppText.scanRegistration)),
          body: Column(
            children: [
              ScannerDashboard(
                checkedInCount: state.checkedInCount,
                expectedCount: state.expectedCount,
                historyCount: state.history.length,
                onHistoryPressed: () =>
                  ScanHistorySheet.show(context, state.history),
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: (capture) {
                        final value = capture.barcodes.firstOrNull?.rawValue;
                        if (value != null &&
                            state.status == WatcherScanStatus.idle &&
                            _scanCooldown == null) {
                          _scanCooldown = Timer(
                            const Duration(milliseconds: 1500),
                            () => _scanCooldown = null,
                          );
                          context.read<WatcherScanCubit>().validate(value);
                        }
                      },
                    ),
                    const ScannerTargetOverlay(),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Column(
                        children: [
                          ScannerIconButton(
                            tooltip: 'Toggle flashlight',
                            icon: _torchEnabled
                                ? Icons.flash_on
                                : Icons.flash_off,
                            onPressed: () async {
                              await _controller.toggleTorch();
                              if (mounted) {
                                setState(() => _torchEnabled = !_torchEnabled);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          ScannerIconButton(
                            tooltip: 'Switch camera',
                            icon: Icons.cameraswitch_outlined,
                            onPressed: _controller.switchCamera,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  state.message ?? AppText.scanRegistrationPrompt,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _manualEntryController,
                  enabled: state.status == WatcherScanStatus.idle,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Enter registration code',
                    hintText: 'Paste the QR text here',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: 'Validate registration code',
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: state.status == WatcherScanStatus.idle
                          ? _submitManualEntry
                          : null,
                    ),
                  ),
                  onSubmitted: (_) => _submitManualEntry(),
                ),
              ),
              const SizedBox(height: 12),
              if (state.status != WatcherScanStatus.idle)
                FilledButton.icon(
                  onPressed: state.status == WatcherScanStatus.checkingIn
                      ? null
                      : state.status == WatcherScanStatus.valid
                      ? () => context.read<WatcherScanCubit>().checkIn()
                      : context.read<WatcherScanCubit>().reset,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(
                    state.status == WatcherScanStatus.valid
                        ? AppText.checkIn
                        : AppText.scanAgain,
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _submitManualEntry() {
    final value = _manualEntryController.text.trim();
    if (value.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<WatcherScanCubit>().validate(value);
  }
}
