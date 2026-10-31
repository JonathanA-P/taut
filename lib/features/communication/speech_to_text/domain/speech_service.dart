import 'speech_state.dart';

abstract class SpeechService {
  Future<bool> initialize();

  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    String language = 'id-ID',
  });

  Future<void> stopListening();

  Future<void> cancelListening();

  bool get isListening;

  Stream<SpeechRecognitionState> get statusStream;

  void dispose();
}

