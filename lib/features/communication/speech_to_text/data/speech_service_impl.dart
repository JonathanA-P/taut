import 'dart:async';

import '../domain/speech_service.dart';
import '../domain/speech_state.dart';

/// Foundation implementation of [SpeechService] for Stage 01.
/// Real integration with `speech_to_text` and Android SpeechRecognizer
/// will be implemented by Roganda on `feature/speech-to-text`.
class SpeechServiceImpl implements SpeechService {
  final _stateController = StreamController<SpeechRecognitionState>.broadcast();
  bool _isListening = false;

  SpeechServiceImpl() {
    _stateController.add(
      const SpeechRecognitionState(status: SpeechStatus.uninitialized),
    );
  }

  @override
  Future<bool> initialize() async {
    _stateController.add(
      const SpeechRecognitionState(status: SpeechStatus.ready),
    );
    return true;
  }

  @override
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    String language = 'id-ID',
  }) async {
    _isListening = true;
    _stateController.add(
      const SpeechRecognitionState(status: SpeechStatus.listening),
    );
    // Stage 01: Does not generate fake recognized text.
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    _stateController.add(
      const SpeechRecognitionState(status: SpeechStatus.ready),
    );
  }

  @override
  Future<void> cancelListening() async {
    _isListening = false;
    _stateController.add(
      const SpeechRecognitionState(status: SpeechStatus.ready),
    );
  }

  @override
  bool get isListening => _isListening;

  @override
  Stream<SpeechRecognitionState> get statusStream => _stateController.stream;

  @override
  void dispose() {
    _stateController.close();
  }
}
