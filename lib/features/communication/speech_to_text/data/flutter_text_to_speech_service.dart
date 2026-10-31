import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../domain/text_to_speech_service.dart';

class FlutterTextToSpeechService implements TextToSpeechService {
  final FlutterTts _flutterTts;
  final StreamController<bool> _speakingStateController =
      StreamController<bool>.broadcast();

  bool _isSpeaking = false;
  double _speechRate = 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;
  bool _isInitialized = false;

  FlutterTextToSpeechService({FlutterTts? flutterTts})
    : _flutterTts = flutterTts ?? FlutterTts() {
    _initHandlers();
  }

  void _initHandlers() {
    try {
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _speakingStateController.add(true);
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _speakingStateController.add(false);
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        _speakingStateController.add(false);
      });

      _flutterTts.setPauseHandler(() {
        _isSpeaking = false;
        _speakingStateController.add(false);
      });

      _flutterTts.setContinueHandler(() {
        _isSpeaking = true;
        _speakingStateController.add(true);
      });

      _flutterTts.setErrorHandler((dynamic msg) {
        debugPrint('TTS Error: $msg');
        _isSpeaking = false;
        _speakingStateController.add(false);
      });
    } catch (e) {
      debugPrint('Error attaching TTS handlers: $e');
    }
  }

  @override
  Future<void> initialize({String language = 'id-ID'}) async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage(language).catchError((_) => null);
      await _flutterTts.setSpeechRate(_speechRate).catchError((_) => null);
      await _flutterTts.setPitch(_pitch).catchError((_) => null);
      await _flutterTts.setVolume(_volume).catchError((_) => null);
      await _flutterTts.awaitSpeakCompletion(true).catchError((_) => null);
      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS initialize error (gracefully handled): $e');
      _isInitialized = true;
    }
  }

  @override
  Future<void> speakText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (!_isInitialized) {
      await initialize();
    }

    try {
      _isSpeaking = true;
      _speakingStateController.add(true);
      final result = await _flutterTts.speak(trimmed).catchError((e) {
        debugPrint('TTS speak catchError: $e');
        return 0;
      });
      if (result == 0) {
        _isSpeaking = false;
        _speakingStateController.add(false);
      }
    } catch (e) {
      debugPrint('TTS speak error: $e');
      _isSpeaking = false;
      _speakingStateController.add(false);
    }
  }

  @override
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop().catchError((_) => null);
    } catch (e) {
      debugPrint('TTS stop error: $e');
    } finally {
      _isSpeaking = false;
      _speakingStateController.add(false);
    }
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    try {
      await _flutterTts.setSpeechRate(rate).catchError((_) => null);
    } catch (e) {
      debugPrint('TTS setSpeechRate error: $e');
    }
  }

  @override
  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    try {
      await _flutterTts.setPitch(pitch);
    } catch (e) {
      debugPrint('TTS setPitch error: $e');
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume;
    try {
      await _flutterTts.setVolume(volume).catchError((_) => null);
    } catch (e) {
      debugPrint('TTS setVolume error: $e');
    }
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Stream<bool> get isSpeakingStream => _speakingStateController.stream;

  @override
  double get speechRate => _speechRate;

  @override
  double get pitch => _pitch;

  @override
  double get volume => _volume;

  @override
  void dispose() {
    try {
      _flutterTts.stop().catchError((_) => null);
    } catch (_) {}
    _speakingStateController.close();
  }
}
