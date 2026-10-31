abstract class TtsService {
  Future<void> initialize({String language = 'id-ID'});

  Future<void> speakText(String text);

  Future<void> stopSpeaking();

  bool get isSpeaking;

  void dispose();
}

