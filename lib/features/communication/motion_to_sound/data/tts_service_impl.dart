import '../../speech_to_text/data/flutter_text_to_speech_service.dart';
import '../domain/tts_service.dart';

/// Implementation of [TtsService] utilizing [FlutterTextToSpeechService].
/// Feature Owner: Roganda Tua Tampubolon (Communication AI Lead).
/// Branch: feature/motion-to-sound / feature/speech-to-text.
class TtsServiceImpl implements TtsService {
  final FlutterTextToSpeechService _delegate;

  TtsServiceImpl({FlutterTextToSpeechService? delegate})
    : _delegate = delegate ?? FlutterTextToSpeechService();

  @override
  bool get isSpeaking => _delegate.isSpeaking;

  @override
  Future<void> initialize({String language = 'id-ID'}) async {
    await _delegate.initialize(language: language);
  }

  @override
  Future<void> speakText(String text) async {
    await _delegate.speakText(text);
  }

  @override
  Future<void> stopSpeaking() async {
    await _delegate.stopSpeaking();
  }

  @override
  void dispose() {
    _delegate.dispose();
  }
}
