import 'dart:developer';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  TextToSpeechService._();
  static final TextToSpeechService _instance = TextToSpeechService._();

  late final FlutterTts _tts;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;

  /// Initialize the TTS engine. Call once at app startup.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _tts = FlutterTts();

      await _tts.setLanguage('en-US');
      //await _tts.setVoice();
      await _tts.setVoice({"name": "Karen", "locale": "en-US"});
      await _tts.setSpeechRate(0.4);
      await _tts.setVolume(1.0);
      await _tts.setPitch(0.9);

      _tts.setStartHandler(() {
        _isSpeaking = true;
        log(name: 'TextToSpeechService', 'Speech started');
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        log(name: 'TextToSpeechService', 'Speech completed');
      });

      _tts.setCancelHandler(() {
        _isSpeaking = false;
        log(name: 'TextToSpeechService', 'Speech cancelled');
      });

      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        log(name: 'TextToSpeechService', 'Speech error: $msg');
      });

      _isInitialized = true;
      log(name: 'TextToSpeechService', 'Initialized successfully');
    } catch (e, s) {
      log(
        name: 'TextToSpeechService',
        'Initialization failed: $e',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Speak the given text. Stops any current speech first.
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      log(name: 'TextToSpeechService', 'Service not initialized');
      return;
    }

    if (text.trim().isEmpty) {
      log(name: 'TextToSpeechService', 'Skipped empty text');
      return;
    }

    try {
      if (_isSpeaking) {
        await _tts.stop();
      }
      await _tts.speak(text);
    } catch (e, s) {
      log(
        name: 'TextToSpeechService',
        'Speak failed: $e',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Stop any ongoing speech.
  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _tts.stop();
      _isSpeaking = false;
    } catch (e, s) {
      log(
        name: 'TextToSpeechService',
        'Stop failed: $e',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Pause ongoing speech (iOS only — Android falls back to stop).
  Future<void> pause() async {
    if (!_isInitialized) return;

    try {
      await _tts.pause();
    } catch (e, s) {
      log(
        name: 'TextToSpeechService',
        'Pause failed: $e',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> setLanguage(String language) async {
    if (!_isInitialized) return;
    await _tts.setLanguage(language);
  }

  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) return;
    await _tts.setSpeechRate(rate);
  }

  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;
    await _tts.setVolume(volume);
  }

  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) return;
    await _tts.setPitch(pitch);
  }

  /// Release resources. Call when the service is no longer needed (e.g. app dispose).
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      await _tts.stop();
      _isInitialized = false;
    } catch (e, s) {
      log(
        name: 'TextToSpeechService',
        'Dispose failed: $e',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<dynamic> getAvailableVoices() async {
    if (!_isInitialized) return;
    return await _tts.getVoices;
  }
  factory TextToSpeechService() => _instance;
}