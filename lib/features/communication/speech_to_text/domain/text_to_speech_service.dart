import '../../motion_to_sound/domain/tts_service.dart';

/// Integration Contract: Text-to-Speech (TTS) Service for Communication Feature.
/// Feature Owner: Roganda Tua Tampubolon (Communication AI Lead).
/// Branch: feature/speech-to-text.
///
/// Extends foundational [TtsService] contract with rich controls
/// for speed rate, pitch, volume, and reactive playback status streams.
abstract class TextToSpeechService implements TtsService {
  /// Reactive stream indicating whether audio is currently speaking.
  Stream<bool> get isSpeakingStream;

  /// Sets speech rate (e.g. 0.3 to 1.5, default 0.5 for flutter_tts).
  Future<void> setSpeechRate(double rate);

  /// Sets voice pitch (e.g. 0.5 to 1.5, default 1.0).
  Future<void> setPitch(double pitch);

  /// Sets playback volume (0.0 to 1.0, default 1.0).
  Future<void> setVolume(double volume);

  /// Current speech rate.
  double get speechRate;

  /// Current voice pitch.
  double get pitch;

  /// Current volume.
  double get volume;
}
