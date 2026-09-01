import 'dart:async';

import 'package:bdo_event/core/util/resource/app_identifier.dart';
import 'package:bdo_event/core/util/resource/app_locals.dart';
import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_cubit.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_state.dart';
import 'package:bdo_event/features/watcher_screen/presentation/widget/scan_history_sheet.dart';
import 'package:bdo_event/features/watcher_screen/presentation/widget/scanner_dashboard.dart';
import 'package:bdo_event/features/watcher_screen/presentation/widget/scanner_icon_button.dart';
import 'package:bdo_event/features/watcher_screen/presentation/widget/scanner_target_overlay.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_state.dart';

import '../adapters.dart';

class WatcherScanScreen extends StatefulWidget {
  const WatcherScanScreen({super.key, this.scanner, this.voice, this.feedback});

  final WatcherScannerAdapter? scanner;
  final WatcherVoiceAdapter? voice;
  final WatcherFeedbackAdapter? feedback;

  @override
  State<WatcherScanScreen> createState() => _WatcherScanScreenState();
}

class _WatcherScanScreenState extends State<WatcherScanScreen> {
  late final WatcherScannerAdapter _scanner =
      widget.scanner ?? MobileScannerAdapter();
  late final WatcherVoiceAdapter _voice = widget.voice ?? FlutterTtsAdapter();
  late final WatcherFeedbackAdapter _feedback =
      widget.feedback ?? const SystemWatcherFeedbackAdapter();
  final _manualEntryController = TextEditingController();
  Timer? _scanCooldown;
  bool _torchEnabled = false;

  @override
  void initState() {
    super.initState();
    _configureSpeech();
  }

  Future<void> _configureSpeech() async {
    try {
      await _voice.configure(
        language: AppLocales.englishIndia,
        volume: context.read<ProfileScreenCubit>().state.watcherSoundVolume,
      );
    } on Object {
      return;
    }
  }

  Future<void> _announce(String message) async {
    if (context.read<ProfileScreenCubit>().state.isWatcherVoiceMuted) return;
    try {
      await _voice.stop();
      await _voice.speak(message);
    } on Object {
      return;
    }
  }

  @override
  void dispose() {
    _scanCooldown?.cancel();
    _manualEntryController.dispose();
    try {
      _scanner.dispose();
      // ignore: empty_catches
    } on Object {}
    unawaited(_disposeVoice());
    super.dispose();
  }

  Future<void> _disposeVoice() async {
    try {
      await _voice.dispose();
    } on Object {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileScreenCubit, ProfileScreenState>(
      listenWhen: (previous, current) =>
          previous.watcherSoundVolume != current.watcherSoundVolume,
      listener: (context, state) {
        unawaited(_setVoiceVolume(state.watcherSoundVolume));
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
              unawaited(_provideFeedback());
            }
          }
          if (state.message != null) {
            _announce(state.message!);
          }
        },
        child: BlocBuilder<WatcherScanCubit, WatcherScanState>(
          builder: (context, state) {
            final currentScan = state.history
                .where((entry) => entry.status == AppIdentifiers.readytocheckIn)
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
                            ? AppText.unmuteScanningVoice
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
                    onHistoryPressed: () => ScanHistorySheet.show(
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
                        _scanner.buildView(
                          onDetected: (value) {
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
                                tooltip: AppText.toggleFlashLight,
                                icon: _torchEnabled
                                    ? Icons.flash_on
                                    : Icons.flash_off,
                                onPressed: _toggleTorch,
                              ),
                              const Gap(AppSpace.space12),
                              ScannerIconButton(
                                tooltip: AppText.switchCamera,
                                icon: Icons.cameraswitch_outlined,
                                onPressed: _switchCamera,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child:
                        state.status == WatcherScanStatus.valid &&
                            currentScan != null
                        ? Column(
                            children: [
                              const Text(
                                AppText.pendingCheckIn,
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const Gap(AppSpace.space4),
                              Text(
                                currentScan.displayName ??
                                    AppText.unknownAttendee,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: AppSize.text18,
                                ),
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
                          tooltip: AppText.validateRegistrationCode,
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: state.status == WatcherScanStatus.idle
                              ? _submitManualEntry
                              : null,
                        ),
                      ),
                      onSubmitted: (_) => _submitManualEntry(),
                    ),
                  ),
                  const Gap(AppSpace.space12),
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
                                : () =>
                                      context.read<WatcherScanCubit>().checkIn(
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
                          const Gap(AppSpace.space8),
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
                  const Gap(AppSpace.space20),
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

  Future<void> _setVoiceVolume(double volume) async {
    try {
      await _voice.setVolume(volume);
    } on Object {
      return;
    }
  }

  Future<void> _provideFeedback() async {
    try {
      await _feedback.mediumImpact();
    } on Object {
      return;
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _scanner.toggleTorch();
      if (mounted) {
        setState(() => _torchEnabled = !_torchEnabled);
      }
    } on Object {
      return;
    }
  }

  void _switchCamera() {
    try {
      _scanner.switchCamera();
    } on Object {
      return;
    }
  }
}
