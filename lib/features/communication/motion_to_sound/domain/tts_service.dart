/// Integration Contract: Text-to-Speech (TTS) Service
/// Owner: Roganda Tua Tampubolon (Communication AI Lead)
/// Branch: feature/motion-to-sound
///
/// Responsibilities:
/// - Initializing Android TTS engine with Indonesian voice locale (`id-ID`)
/// - Synthesizing spoken audio from recognized BISINDO words or user messages
/// - Managing audio playback state and cancellation
abstract class TtsService {
  /// Initializes the local Android TTS engine.
  Future<void> initialize({String language = 'id-ID'});

  /// Speaks the given Indonesian text aloud.
  Future<void> speakText(String text);

  /// Stops current speech output immediately.
  Future<void> stopSpeaking();

  /// Whether TTS is currently playing audio.
  bool get isSpeaking;

  /// Releases TTS engine native handlers.
  void dispose();
}
