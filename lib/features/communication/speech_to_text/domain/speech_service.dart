import 'speech_state.dart';

/// Integration Contract: Speech-to-Text Service
/// Owner: Roganda Tua Tampubolon (Communication AI Lead)
/// Branch: feature/speech-to-text
///
/// Responsibilities:
/// - Handling Android Speech Recognition lifecycle and microphone permissions
/// - Capturing Indonesian speech (`id-ID`)
/// - Emitting partial and confirmed final transcription results
/// - Graceful handling of timeouts, speech recognition errors, and offline modes
abstract class SpeechService {
  /// Initializes the speech recognition engine and checks availability.
  Future<bool> initialize();

  /// Starts listening for Indonesian speech input.
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    String language = 'id-ID',
  });

  /// Stops listening and finalizes recognized text.
  Future<void> stopListening();

  /// Cancels listening and discards current buffer.
  Future<void> cancelListening();

  /// Whether the microphone is currently active and listening.
  bool get isListening;

  /// Reactive stream of speech states.
  Stream<SpeechRecognitionState> get statusStream;

  /// Releases resources.
  void dispose();
}
