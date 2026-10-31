import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/features/communication/speech_to_text/data/flutter_text_to_speech_service.dart';
import 'package:taut/features/communication/speech_to_text/domain/text_to_speech_service.dart';

class FakeTextToSpeechService implements TextToSpeechService {
  bool _isSpeaking = false;
  double _speechRate = 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;
  String? lastSpokenText;
  String? initializedLanguage;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Stream<bool> get isSpeakingStream => Stream.value(_isSpeaking);

  @override
  double get speechRate => _speechRate;

  @override
  double get pitch => _pitch;

  @override
  double get volume => _volume;

  @override
  Future<void> initialize({String language = 'id-ID'}) async {
    initializedLanguage = language;
  }

  @override
  Future<void> speakText(String text) async {
    lastSpokenText = text;
    _isSpeaking = true;
  }

  @override
  Future<void> stopSpeaking() async {
    _isSpeaking = false;
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
  }

  @override
  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
  }

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume;
  }

  @override
  void dispose() {
    _isSpeaking = false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          MethodCall methodCall,
        ) async {
          switch (methodCall.method) {
            case 'speak':
              return 1;
            case 'stop':
              return 1;
            case 'setLanguage':
              return 1;
            case 'setSpeechRate':
              return 1;
            case 'setPitch':
              return 1;
            case 'setVolume':
              return 1;
            case 'awaitSpeakCompletion':
              return 1;
            default:
              return null;
          }
        });
  });

  group('TextToSpeechService Contract & Fake Tests', () {
    late FakeTextToSpeechService service;

    setUp(() {
      service = FakeTextToSpeechService();
    });

    test('Initializes with Indonesian language by default', () async {
      await service.initialize();
      expect(service.initializedLanguage, equals('id-ID'));
      expect(service.isSpeaking, isFalse);
    });

    test('Synthesizes and speaks text correctly', () async {
      await service.initialize();
      await service.speakText('Halo, saya menggunakan aplikasi TAUT');
      expect(
        service.lastSpokenText,
        equals('Halo, saya menggunakan aplikasi TAUT'),
      );
      expect(service.isSpeaking, isTrue);

      await service.stopSpeaking();
      expect(service.isSpeaking, isFalse);
    });

    test('Updates speech rate, pitch, and volume properly', () async {
      await service.setSpeechRate(0.8);
      expect(service.speechRate, equals(0.8));

      await service.setPitch(1.2);
      expect(service.pitch, equals(1.2));

      await service.setVolume(0.9);
      expect(service.volume, equals(0.9));
    });
  });

  group('FlutterTextToSpeechService Unit Tests (Headless Fallback)', () {
    test(
      'Default constructor creates instance and initializes gracefully',
      () async {
        final tts = FlutterTextToSpeechService();
        await tts.initialize(language: 'id-ID');
        expect(tts.speechRate, equals(0.5));
        expect(tts.pitch, equals(1.0));
        expect(tts.volume, equals(1.0));

        await tts.speakText('Tes suara Text-to-Speech');
        expect(tts.isSpeaking, isTrue);

        await tts.stopSpeaking();
        expect(tts.isSpeaking, isFalse);

        tts.dispose();
      },
    );
  });
}
