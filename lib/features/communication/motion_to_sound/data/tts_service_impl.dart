import 'package:flutter_tts/flutter_tts.dart';
import '../domain/tts_service.dart';

class TtsServiceImpl implements TtsService {
  final FlutterTts _flutterTts;
  bool _isSpeaking = false;
  bool _isInitialized = false;

  TtsServiceImpl({FlutterTts? flutterTts}) : _flutterTts = flutterTts ?? FlutterTts() {
    _flutterTts.setStartHandler(() => _isSpeaking = true);
    _flutterTts.setCompletionHandler(() => _isSpeaking = false);
    _flutterTts.setErrorHandler((_) => _isSpeaking = false);
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> initialize({String language = 'id-ID'}) async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage(language);
      await _flutterTts.setSpeechRate(0.46); // Natural conversational rate
      await _flutterTts.setPitch(0.98); // Natural human pitch
      await _flutterTts.setVolume(1.0);
      _isInitialized = true;
    } catch (_) {
      _isInitialized = false;
    }
  }

  @override
  Future<void> speakText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (!_isInitialized) {
      await initialize();
    }

    _isSpeaking = true;
    try {
      await _flutterTts.speak(trimmed);
    } catch (_) {
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
    try {
      _flutterTts.stop();
    } catch (_) {}
    _isSpeaking = false;
  }
}

