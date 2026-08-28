import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_cubit.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_state.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class WatcherScanScreen extends StatefulWidget {
  const WatcherScanScreen({super.key});

  @override
  State<WatcherScanScreen> createState() => _WatcherScanScreenState();
}

class _WatcherScanScreenState extends State<WatcherScanScreen> {
  final _controller = MobileScannerController();
  final _speech = FlutterTts();

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
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatcherScanCubit, WatcherScanState>(
      listenWhen: (previous, current) =>
          previous.message != current.message && current.message != null,
      listener: (context, state) => _announce(state.message!),
      child: BlocBuilder<WatcherScanCubit, WatcherScanState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text(AppText.scanRegistration)),
          body: Column(
          children: [
            Expanded(
              child: MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  final value = capture.barcodes.firstOrNull?.rawValue;
                  if (value != null && state.status == WatcherScanStatus.idle) {
                    context.read<WatcherScanCubit>().validate(value);
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                state.message ?? AppText.scanRegistrationPrompt,
                textAlign: TextAlign.center,
              ),
            ),
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
}