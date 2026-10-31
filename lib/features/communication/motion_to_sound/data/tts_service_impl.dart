import '../domain/tts_service.dart';

/// Foundation implementation of [TtsService] for Stage 01.
/// Full integration with TTS engine will be completed on `feature/motion-to-sound`.
class TtsServiceImpl implements TtsService {
  bool _isSpeaking = false;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> initialize({String language = 'id-ID'}) async {}

  @override
  Future<void> speakText(String text) async {
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
