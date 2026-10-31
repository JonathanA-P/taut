import '../domain/tts_service.dart';

/// Foundation implementation of [TtsService] for Stage 01.
/// Full integration with `flutter_tts` package will be completed by Roganda.
class TtsServiceImpl implements TtsService {
  bool _isSpeaking = false;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> initialize({String language = 'id-ID'}) async {
    // Stage 01: Engine placeholder
  }

  @override
  Future<void> speakText(String text) async {
    // Stage 01: Ready for flutter_tts integration
    _isSpeaking = true;
    await Future.delayed(const Duration(milliseconds: 300));
    _isSpeaking = false;
  }

  @override
  Future<void> stopSpeaking() async {
    _isSpeaking = false;
  }

  @override
  void dispose() {
    _isSpeaking = false;
  }
}
