/// Represents the state of the Android Speech Recognition pipeline.
enum SpeechStatus { uninitialized, ready, listening, processing, error }

class SpeechRecognitionState {
  final SpeechStatus status;
  final String recognizedText;
  final bool isFinal;
  final String? errorMessage;

  const SpeechRecognitionState({
    this.status = SpeechStatus.uninitialized,
    this.recognizedText = '',
    this.isFinal = false,
    this.errorMessage,
  });

  SpeechRecognitionState copyWith({
    SpeechStatus? status,
    String? recognizedText,
    bool? isFinal,
    String? errorMessage,
  }) {
    return SpeechRecognitionState(
      status: status ?? this.status,
      recognizedText: recognizedText ?? this.recognizedText,
      isFinal: isFinal ?? this.isFinal,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
