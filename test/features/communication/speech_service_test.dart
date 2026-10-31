import 'package:flutter_test/flutter_test.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:taut/features/communication/speech_to_text/data/speech_service_impl.dart';
import 'package:taut/features/communication/speech_to_text/domain/speech_state.dart';

class FakeSpeechToText extends Fake implements SpeechToText {
  bool initSuccess = true;
  bool isListeningValue = false;
  SpeechErrorListener? onErrorCallback;
  SpeechStatusListener? onStatusCallback;

  @override
  bool get isListening => isListeningValue;

  @override
  Future<bool> initialize({
    SpeechErrorListener? onError,
    SpeechStatusListener? onStatus,
    debugLogging = false,
    Duration? finalTimeout,
    List<SpeechConfigOption>? options,
  }) async {
    onErrorCallback = onError;
    onStatusCallback = onStatus;
    return initSuccess;
  }

  @override
  Future<void> stop() async {
    isListeningValue = false;
    onStatusCallback?.call('notListening');
  }

  @override
  Future<void> cancel() async {
    isListeningValue = false;
    onStatusCallback?.call('done');
  }
}

void main() {
  group('SpeechServiceImpl Unit Tests', () {
    late FakeSpeechToText fakeSpeechToText;
    late SpeechServiceImpl service;

    setUp(() {
      fakeSpeechToText = FakeSpeechToText();
      service = SpeechServiceImpl(speechToText: fakeSpeechToText);
    });

    tearDown(() {
      service.dispose();
    });

    test('Initializes successfully and emits ready state', () async {
      final stateFuture = service.statusStream.first;
      final initResult = await service.initialize();
      expect(initResult, isTrue);

      final state = await stateFuture;
      expect(state.status, equals(SpeechStatus.ready));
      expect(state.errorMessage, isNull);
    });

    test('Emits error when speech engine fails to initialize', () async {
      fakeSpeechToText.initSuccess = false;
      final stateFuture = service.statusStream.first;
      final initResult = await service.initialize();
      expect(initResult, isFalse);

      final state = await stateFuture;
      expect(state.status, equals(SpeechStatus.error));
      expect(state.errorMessage, isNotNull);
    });

    test('Handles stop and cancel gracefully', () async {
      await service.initialize();
      await service.stopListening();
      expect(service.isListening, isFalse);

      await service.cancelListening();
      expect(service.isListening, isFalse);
    });

    test('Handles error notifications from recognizer', () async {
      await service.initialize();
      final stateFuture = service.statusStream.first;
      fakeSpeechToText.onErrorCallback?.call(
        SpeechRecognitionError('error_network', true),
      );

      final state = await stateFuture;
      expect(state.status, equals(SpeechStatus.error));
      expect(state.errorMessage, equals('error_network'));
    });
  });
}
