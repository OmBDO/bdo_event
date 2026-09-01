import 'package:flutter_tts/flutter_tts.dart';

abstract interface class WatcherVoiceAdapter {
  Future<void> configure({
    required String language,
    required double volume,
  });

  Future<void> setVolume(double volume);

  Future<void> stop();

  Future<void> speak(String message);

  Future<void> dispose();
}

class FlutterTtsAdapter implements WatcherVoiceAdapter {
  FlutterTtsAdapter({FlutterTts? speech})
    : _speech = speech ?? FlutterTts();

  final FlutterTts _speech;

  @override
  Future<void> configure({required String language, required double volume}) async {
    await _speech.setLanguage(language);
    await _speech.setSpeechRate(0.5);
    await _speech.setVolume(volume);
    await _speech.setPitch(1.0);
  }

  @override
  Future<void> setVolume(double volume) => _speech.setVolume(volume);

  @override
  Future<void> stop() async {
    await _speech.stop();
  }

  @override
  Future<void> speak(String message) async {
    await _speech.speak(message);
  }

  @override
  Future<void> dispose() async {
    await _speech.stop();
  }
}
