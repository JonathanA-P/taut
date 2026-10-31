import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../domain/tts_service.dart';

/// Production implementation of [TtsService] utilizing [FlutterTts] for Indonesian speech output.
/// Feature Owner: Roganda Tua Tampubolon (Communication AI Lead).
class TtsServiceImpl implements TtsService {
  final FlutterTts _flutterTts;
  bool _isSpeaking = false;
  bool _isInitialized = false;

  TtsServiceImpl({FlutterTts? flutterTts})
    : _flutterTts = flutterTts ?? FlutterTts();

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> initialize({String language = 'id-ID'}) async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage(language);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('[TtsService] Speech synthesis error: $msg');
        _isSpeaking = false;
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('[TtsService] Initialization failed: $e');
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
      _isSpeaking = false;
    } catch (e) {
      debugPrint('[TtsService] stopSpeaking failed: $e');
    }
  }

  @override
  void dispose() {
    stopSpeaking();
  }
}
