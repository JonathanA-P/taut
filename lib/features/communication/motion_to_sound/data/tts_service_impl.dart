import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../domain/tts_service.dart';

class TtsServiceImpl implements TtsService {
  final FlutterTts _flutterTts;
  bool _isSpeaking = false;
  bool _isInitialized = false;

  TtsServiceImpl({FlutterTts? flutterTts})
    : _flutterTts = flutterTts ?? FlutterTts() {
    _flutterTts.setStartHandler(() => _isSpeaking = true);
    _flutterTts.setCompletionHandler(() => _isSpeaking = false);
    _flutterTts.setCancelHandler(() => _isSpeaking = false);
    _flutterTts.setErrorHandler((msg) {
      debugPrint('[TtsService] Speech synthesis error: $msg');
      _isSpeaking = false;
    });
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> initialize({String language = 'id-ID'}) async {
    if (_isInitialized) return;

    try {
      var langSet = false;
      try {
        final available = await _flutterTts.isLanguageAvailable(language);
        if (available == true || available == 1) {
          await _flutterTts.setLanguage(language);
          langSet = true;
        }
      } catch (_) {}

      if (!langSet) {
        try {
          await _flutterTts.setLanguage('id-ID');
          langSet = true;
        } catch (_) {
          try {
            await _flutterTts.setLanguage('id');
            langSet = true;
          } catch (_) {}
        }
      }

      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      // awaitSpeakCompletion(false) ensures audio output does not block
      // the Flutter UI thread or stall if the TTS engine omits callbacks.
      await _flutterTts.awaitSpeakCompletion(false);
      _isInitialized = true;
    } catch (e) {
      debugPrint('[TtsService] Initialization failed: $e');
      _isInitialized = false;
    }
  }

  @override
  Future<void> speakText(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    if (!_isInitialized) {
      await initialize();
    }

    try {
      _isSpeaking = true;
      // Stop previous utterance immediately so new gesture audio is heard without queuing lag
      await _flutterTts.stop();
      await _flutterTts.speak(cleanText);
    } catch (e) {
      debugPrint('[TtsService] speakText failed: $e');
      _isSpeaking = false;
    }
  }

  @override
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
    _isSpeaking = false;
  }

  @override
  void dispose() {
    stopSpeaking();
  }
}
