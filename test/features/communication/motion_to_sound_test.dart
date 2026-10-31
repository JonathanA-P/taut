import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/features/communication/motion_to_sound/bisindo_to_sound_module.dart';
import 'package:taut/core/permissions/permission_service.dart';
import 'package:taut/features/communication/speech_to_text/domain/speech_service.dart';
import 'package:taut/features/communication/speech_to_text/domain/speech_state.dart';

class MockPermissionService implements PermissionService {
  AppPermissionStatus status = AppPermissionStatus.granted;

  @override
  Future<AppPermissionStatus> checkPermission(AppPermissionType type) async {
    return status;
  }

  @override
  Future<AppPermissionStatus> requestPermission(AppPermissionType type) async {
    return status;
  }

  @override
  Future<bool> openAppSettings() async => true;
}

class MockTtsService implements TtsService {
  final List<String> spokenTexts = [];
  bool _isSpeaking = false;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> initialize({String language = 'id-ID'}) async {}

  @override
  Future<void> speakText(String text) async {
    spokenTexts.add(text);
  }

  @override
  Future<void> stopSpeaking() async {
    _isSpeaking = false;
  }

  @override
  void dispose() {
    _isSpeaking = false;
  }
}

class MockDetectorService implements BisindoDetectorService {
  BisindoMode _mode = BisindoMode.kata;
  final StreamController<BisindoDetectionEvent> _controller =
      StreamController<BisindoDetectionEvent>.broadcast();

  @override
  BisindoMode get currentMode => _mode;

  @override
  Stream<BisindoDetectionEvent> get detectionStream => _controller.stream;

  @override
  bool get isModelLoaded => true;

  @override
  Future<void> initializeModel({
    BisindoMode initialMode = BisindoMode.kata,
  }) async {
    _mode = initialMode;
  }

  @override
  Future<void> switchMode(BisindoMode newMode) async {
    _mode = newMode;
  }

  @override
  Future<BisindoDetectionEvent?> processCameraImage(
    CameraImage cameraImage, {
    bool isFrontCamera = false,
  }) async {
    return null;
  }

  @override
  Future<GestureResult> recognizeGesture(dynamic frameOrLandmarks) async {
    return GestureResult.unknown(0.0);
  }

  @override
  List<String> getSupportedVocabulary() {
    return BisindoLabels.getLabelsForMode(_mode);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

class MockSpeechService implements SpeechService {
  final StreamController<SpeechRecognitionState> _statusCtrl =
      StreamController<SpeechRecognitionState>.broadcast();
  bool _isListening = false;
  void Function(String text, bool isFinal)? onResultCallback;

  @override
  bool get isListening => _isListening;

  @override
  Stream<SpeechRecognitionState> get statusStream => _statusCtrl.stream;

  @override
  Future<bool> initialize() async {
    _statusCtrl.add(const SpeechRecognitionState(status: SpeechStatus.ready));
    return true;
  }

  @override
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    String language = 'id-ID',
  }) async {
    _isListening = true;
    onResultCallback = onResult;
    _statusCtrl.add(const SpeechRecognitionState(status: SpeechStatus.listening));
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    _statusCtrl.add(const SpeechRecognitionState(status: SpeechStatus.ready));
  }

  @override
  Future<void> cancelListening() async {
    _isListening = false;
    _statusCtrl.add(const SpeechRecognitionState(status: SpeechStatus.ready));
  }

  @override
  void dispose() {
    _statusCtrl.close();
  }
}

void main() {
  group('BisindoLabels Unit Tests', () {
    test('Kata labels contains exact 23 BISINDO classes', () {
      expect(BisindoLabels.kata.length, 23);
      expect(BisindoLabels.kata.first, 'Kiri');
      expect(BisindoLabels.kata.last, 'Ingin');
      expect(BisindoLabels.kata, contains('Terima Kasih'));
      expect(BisindoLabels.kata, contains('Sama-sama'));
    });

    test('Abjad labels contains 26 alphabets A-Z', () {
      expect(BisindoLabels.abjad.length, 26);
      expect(BisindoLabels.abjad.first, 'A');
      expect(BisindoLabels.abjad.last, 'Z');
    });

    test('Angka labels contains 11 digits 0-10', () {
      expect(BisindoLabels.angka.length, 11);
      expect(BisindoLabels.angka.first, '0');
      expect(BisindoLabels.angka.last, '10');
    });

    test('Resolves label safely with 0-based and 1-based indexing', () {
      expect(BisindoLabels.resolveLabel(0, BisindoMode.kata), 'Kiri');
      expect(BisindoLabels.resolveLabel(22, BisindoMode.kata), 'Ingin');
      expect(BisindoLabels.resolveLabel(0, BisindoMode.abjad), 'A');
      expect(BisindoLabels.resolveLabel(25, BisindoMode.abjad), 'Z');
    });
  });

  group('GestureResult Unit Tests', () {
    test('GestureResult.unknown sets isRecognized to false', () {
      final res = GestureResult.unknown(0.42);
      expect(res.isRecognized, isFalse);
      expect(res.confidence, 0.42);
      expect(res.label, 'Gerakan Tidak Dikenal');
    });

    test('GestureResult.recognized sets isRecognized to true', () {
      final res = GestureResult.recognized(label: 'Halo', confidence: 0.89);
      expect(res.isRecognized, isTrue);
      expect(res.confidence, 0.89);
      expect(res.label, 'Halo');
    });
  });

  group('MotionToSoundScreen Widget Tests', () {
    testWidgets('Renders all controls, segmented tabs, and presets', (
      WidgetTester tester,
    ) async {
      final mockPermission = MockPermissionService();
      final mockTts = MockTtsService();
      final mockDetector = MockDetectorService();

      await tester.pumpWidget(
        MaterialApp(
          home: MotionToSoundScreen(
            permissionService: mockPermission,
            detectorService: mockDetector,
            ttsService: mockTts,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header title and privacy badge
      expect(find.text('Isyarat BISINDO ke Suara'), findsOneWidget);
      expect(find.text('On-Device AI (Privasi Terjamin)'), findsOneWidget);

      // 3 Detection Mode Segments
      expect(find.text('Kata (23)'), findsOneWidget);
      expect(find.text('Abjad A–Z'), findsOneWidget);
      expect(find.text('Angka 0–10'), findsOneWidget);

      // Sentence Builder & Actions
      expect(find.text('Bilah Kalimat & Ejaan'), findsOneWidget);
      expect(find.text('Spasi'), findsOneWidget);
      expect(find.text('Hapus 1'), findsOneWidget);
      expect(find.text('Suarakan Sekarang 🔊'), findsOneWidget);

      // Quick Preset Chips
      final presetFinder = find.text('Halo, saya Tuli');
      expect(presetFinder, findsOneWidget);
      expect(find.text('Tolong bantu saya'), findsOneWidget);
      expect(
        find.text('Saya butuh ke fasilitas kesehatan terdekat'),
        findsOneWidget,
      );
      expect(find.text('Terima kasih'), findsOneWidget);

      // Scroll preset into view and tap it
      await tester.ensureVisible(presetFinder);
      await tester.pumpAndSettle();
      await tester.tap(presetFinder);
      await tester.pumpAndSettle();

      expect(mockTts.spokenTexts, contains('Halo, saya Tuli'));

      // Switch to Abjad mode
      final abjadFinder = find.text('Abjad A–Z');
      await tester.ensureVisible(abjadFinder);
      await tester.tap(abjadFinder);
      await tester.pumpAndSettle();
      expect(find.text('Abjad A–Z'), findsOneWidget);
    });

    testWidgets('Renders Speech-to-Text card and handles microphone listening', (
      WidgetTester tester,
    ) async {
      final mockPermission = MockPermissionService();
      final mockTts = MockTtsService();
      final mockDetector = MockDetectorService();
      final mockSpeech = MockSpeechService();

      await tester.pumpWidget(
        MaterialApp(
          home: MotionToSoundScreen(
            permissionService: mockPermission,
            detectorService: mockDetector,
            ttsService: mockTts,
            speechService: mockSpeech,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sttTitleFinder = find.text('Ucapan Lawan Bicara (STT)');
      expect(sttTitleFinder, findsOneWidget);

      final listenBtn = find.text('Dengarkan Ucapan');
      await tester.ensureVisible(listenBtn);
      await tester.pumpAndSettle();
      await tester.tap(listenBtn);
      await tester.pumpAndSettle();

      expect(mockSpeech.isListening, isTrue);

      // Simulate hearing speech received
      mockSpeech.onResultCallback?.call('Permisi mau tanya jalan', true);
      await tester.pumpAndSettle();

      expect(find.text('Permisi mau tanya jalan'), findsOneWidget);
    });
  });
}
