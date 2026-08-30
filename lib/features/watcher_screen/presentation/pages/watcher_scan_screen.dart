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
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_state.dart';
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
    await _speech.setVolume(
      context.read<ProfileScreenCubit>().state.watcherSoundVolume,
    );
    await _speech.setPitch(1.0);
  }

  Future<void> _announce(String message) async {
    if (context.read<ProfileScreenCubit>().state.isWatcherVoiceMuted) return;
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
    return BlocListener<ProfileScreenCubit, ProfileScreenState>(
      listenWhen: (previous, current) =>
          previous.watcherSoundVolume != current.watcherSoundVolume,
      listener: (context, state) {
        _speech.setVolume(state.watcherSoundVolume);
      },
      child: BlocListener<WatcherScanCubit, WatcherScanState>(
        listenWhen: (previous, current) =>
            (previous.message != current.message && current.message != null) ||
            (previous.status != current.status &&
                current.status == WatcherScanStatus.valid),
        listener: (context, state) {
          if (state.status == WatcherScanStatus.valid) {
            _manualEntryController.clear();
            if (context
                .read<ProfileScreenCubit>()
                .state
                .isWatcherVibrationEnabled) {
              HapticFeedback.mediumImpact();
            }
          }
          if (state.message != null) {
            _announce(state.message!);
          }
        },
        child: BlocBuilder<WatcherScanCubit, WatcherScanState>(
          builder: (context, state) {
          final currentScan = state.history
              .where((entry) => entry.status == 'Ready to check in')
              .firstOrNull;

          return Scaffold(
            appBar: AppBar(
              title: const Text(AppText.scanRegistration),
              actions: [
                BlocBuilder<ProfileScreenCubit, ProfileScreenState>(
                  builder: (context, profileState) {
                    final isMuted = profileState.isWatcherVoiceMuted;
                    return IconButton(
                      tooltip: isMuted
                          ? 'Unmute scanning voice'
                          : AppText.muteScanningVoice,
                      icon: Icon(
                        isMuted
                            ? Icons.volume_off_outlined
                            : Icons.volume_up_outlined,
                      ),
                      onPressed: () => context
                          .read<ProfileScreenCubit>()
                          .toggleWatcherVoiceMuted(!isMuted),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                ScannerDashboard(
                  checkedInCount: state.checkedInCount,
                  expectedCount: state.expectedCount,
                  historyCount: state.history.length,
                  onHistoryPressed: () =>
                      ScanHistorySheet.show(
                      context,
                      state.history,
                      autoOpenNext: context
                        .read<ProfileScreenCubit>()
                        .state
                        .isWatcherAutoOpenNextEnabled,
                      keepHistoryVisibleAfterCheckIn: context
                          .read<ProfileScreenCubit>()
                          .state
                          .isWatcherKeepHistoryVisibleAfterCheckIn,
                      ),
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
                  child: state.status == WatcherScanStatus.valid &&
                          currentScan != null
                      ? Column(
                          children: [
                            const Text(
                              'Pending check-in',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentScan.displayName ?? 'Unknown attendee',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        )
                      : Text(
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
                      labelText: AppText.enterRegistrationCode,
                      hintText: AppText.pasteRegistrationCode,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                if (state.status == WatcherScanStatus.valid)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton(
                          onPressed:
                              state.status == WatcherScanStatus.checkingIn
                                  ? null
                                  : () => context
                                        .read<WatcherScanCubit>()
                                        .checkIn(
                                          autoOpenNext: context
                                              .read<ProfileScreenCubit>()
                                              .state
                                              .isWatcherAutoOpenNextEnabled,
                                        ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(AppText.checkIn),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () =>
                              context.read<WatcherScanCubit>().reset(),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(AppText.scanAgain),
                        ),
                      ],
                    ),
                  )
                else if (state.status != WatcherScanStatus.idle)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: context.read<WatcherScanCubit>().reset,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(AppText.scanAgain),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          );
          },
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
