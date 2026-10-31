import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/features/communication/speech_to_text/domain/speech_service.dart';
import 'package:taut/features/communication/speech_to_text/domain/speech_state.dart';
import 'package:taut/features/communication/speech_to_text/domain/text_to_speech_service.dart';
import 'package:taut/features/communication/speech_to_text/presentation/speech_to_text_screen.dart';

class MockTtsService implements TextToSpeechService {
  final _stateController = StreamController<bool>.broadcast();
  bool _isSpeaking = false;
  double _speechRate = 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;
  String? lastSpokenText;
  int speakCount = 0;
  int stopCount = 0;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Stream<bool> get isSpeakingStream => _stateController.stream;

  @override
  double get speechRate => _speechRate;

  @override
  double get pitch => _pitch;

  @override
  double get volume => _volume;

  @override
  Future<void> initialize({String language = 'id-ID'}) async {}

  @override
  Future<void> speakText(String text) async {
    lastSpokenText = text;
    speakCount++;
    _isSpeaking = true;
    _stateController.add(true);
  }

  @override
  Future<void> stopSpeaking() async {
    stopCount++;
    _isSpeaking = false;
    _stateController.add(false);
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
    _stateController.close();
  }
}

class MockSpeechService implements SpeechService {
  bool _isListening = false;
  final _controller = StreamController<SpeechRecognitionState>.broadcast();

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    String language = 'id-ID',
  }) async {
    _isListening = true;
    onResult('Halo apa kabar', false);
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
  }

  @override
  Future<void> cancelListening() async {
    _isListening = false;
  }

  @override
  bool get isListening => _isListening;

  @override
  Stream<SpeechRecognitionState> get statusStream => _controller.stream;

  @override
  void dispose() {
    _controller.close();
  }
}

void main() {
  group('SpeechToTextScreen Widget Tests', () {
    late MockTtsService mockTts;
    late MockSpeechService mockSpeech;

    setUp(() {
      mockTts = MockTtsService();
      mockSpeech = MockSpeechService();
    });

    Widget createScreen() {
      return MaterialApp(
        home: SpeechToTextScreen(
          ttsService: mockTts,
          speechService: mockSpeech,
        ),
      );
    }

    testWidgets('Renders TTS tab with quick phrases and controls', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Verify app bar title and tab titles
      expect(find.text('Komunikasi Suara & Teks'), findsOneWidget);
      expect(find.text('Teks ke Suara (TTS)'), findsOneWidget);
      expect(find.text('Suara ke Teks (STT)'), findsOneWidget);

      // Verify quick phrases are present
      expect(find.text('Halo, salam kenal!'), findsOneWidget);
      expect(find.text('Saya teman Tuli, mohon bantuannya.'), findsOneWidget);

      // Verify text input field is present
      expect(find.byType(TextField), findsOneWidget);

      // Verify Ucapkan button
      expect(find.text('Ucapkan Suara (TTS)'), findsOneWidget);
    });

    testWidgets('Tapping quick phrase populates text and can be spoken', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Tap on a quick phrase chip
      await tester.tap(find.text('Halo, salam kenal!'));
      await tester.pumpAndSettle();

      // Check text field has the phrase
      expect(find.text('Halo, salam kenal!'), findsWidgets);

      // Ensure button is visible before tapping
      final speakButton = find.text('Ucapkan Suara (TTS)');
      await tester.ensureVisible(speakButton);
      await tester.tap(speakButton);
      await tester.pumpAndSettle();

      expect(mockTts.speakCount, equals(1));
      expect(mockTts.lastSpokenText, equals('Halo, salam kenal!'));
    });

    testWidgets('Switching to STT tab displays microphone controls and handles listening', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Switch to STT tab
      await tester.tap(find.text('Suara ke Teks (STT)'));
      await tester.pumpAndSettle();

      expect(find.text('Panduan Suara ke Teks'), findsOneWidget);
      expect(find.text('Ketuk untuk mulai bicara'), findsOneWidget);

      // Tap the circular mic button in STT tab
      final micButton = find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.byIcon(Icons.mic_rounded),
      );
      await tester.tap(micButton);
      await tester.pumpAndSettle();

      expect(find.text('Ketuk untuk berhenti'), findsOneWidget);
      expect(find.text('Halo apa kabar'), findsOneWidget);

      // Can speak transcription using Putar TTS button
      final putarTtsButton = find.text('Putar TTS');
      await tester.ensureVisible(putarTtsButton);
      await tester.tap(putarTtsButton);
      await tester.pumpAndSettle();

      expect(mockTts.speakCount, equals(1));
      expect(mockTts.lastSpokenText, equals('Halo apa kabar'));
    });
  });
}