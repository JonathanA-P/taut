import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/features/communication/speech_to_text/domain/speech_service.dart';
import 'package:taut/features/communication/speech_to_text/domain/speech_state.dart';
import 'package:taut/features/communication/speech_to_text/presentation/speech_to_text_screen.dart';

class MockSpeechService implements SpeechService {
  bool _isListening = false;
  final StreamController<SpeechRecognitionState> _controller =
      StreamController<SpeechRecognitionState>.broadcast();
  void Function(String text, bool isFinal)? onResultCallback;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    String language = 'id_ID',
  }) async {
    _isListening = true;
    onResultCallback = onResult;
    _controller.add(
      const SpeechRecognitionState(status: SpeechStatus.listening),
    );
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    _controller.add(const SpeechRecognitionState(status: SpeechStatus.ready));
  }

  @override
  Future<void> cancelListening() async {
    _isListening = false;
    _controller.add(const SpeechRecognitionState(status: SpeechStatus.ready));
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
  group('Live SpeechToTextScreen Production Tests', () {
    late MockSpeechService mockSpeechService;

    setUp(() {
      mockSpeechService = MockSpeechService();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: SpeechToTextScreen(speechService: mockSpeechService),
      );
    }

    testWidgets(
      'Initial view displays idle status, instructions, and controls',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Live Speech-to-Text'), findsOneWidget);
        expect(find.text('MIKROFON TIDAK AKTIF'), findsOneWidget);
        expect(find.text('Mulai Mendengarkan Suara'), findsOneWidget);
        expect(find.text('Bersihkan Layar'), findsOneWidget);
        expect(find.text('Ketik Manual'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping mic button activates continuous listening and updates status',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap main microphone start button
        await tester.tap(find.text('Mulai Mendengarkan Suara'));
        await tester.pumpAndSettle();

        expect(mockSpeechService.isListening, isTrue);
        expect(find.text('MIKROFON AKTIF (Bahasa Indonesia)'), findsOneWidget);
        expect(find.text('Hentikan Mendengarkan'), findsOneWidget);
      },
    );

    testWidgets(
      'Real-time partial results appear directly on screen without confirmation step',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Start listening
        await tester.tap(find.text('Mulai Mendengarkan Suara'));
        await tester.pumpAndSettle();

        // Simulate partial transcription coming from engine
        mockSpeechService.onResultCallback?.call('Halo selamat', false);
        await tester.pump();

        // Verify text is immediately visible without confirmation
        expect(find.text('Halo selamat'), findsOneWidget);

        // Simulate additional words stream in
        mockSpeechService.onResultCallback?.call(
          'Halo selamat pagi dokter',
          false,
        );
        await tester.pump();

        expect(find.text('Halo selamat pagi dokter'), findsOneWidget);

        // Finalize sentence (speaker pauses / sentence ends)
        mockSpeechService.onResultCallback?.call(
          'Halo selamat pagi dokter',
          true,
        );
        await tester.pump();

        expect(find.text('Halo selamat pagi dokter'), findsOneWidget);
      },
    );

    testWidgets(
      'Continuous listening aggregates sentences across pauses without losing previous text',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Mulai Mendengarkan Suara'));
        await tester.pumpAndSettle();

        // First sentence finalized
        mockSpeechService.onResultCallback?.call('Saya butuh bantuan.', true);
        await tester.pump();

        // Second sentence begins while microphone remains active
        mockSpeechService.onResultCallback?.call(
          'Di mana ruang radiologi?',
          false,
        );
        await tester.pump();

        // Both sentences must be visible together
        expect(
          find.text('Saya butuh bantuan. Di mana ruang radiologi?'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Bersihkan Layar empties caption text with single tap', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mulai Mendengarkan Suara'));
      await tester.pumpAndSettle();

      mockSpeechService.onResultCallback?.call('Teks yang akan dihapus', true);
      await tester.pump();

      expect(find.text('Teks yang akan dihapus'), findsOneWidget);

      // Tap Bersihkan Layar button
      await tester.tap(find.text('Bersihkan Layar'));
      await tester.pumpAndSettle();

      expect(find.text('Teks yang akan dihapus'), findsNothing);
    });

    testWidgets('Manual input fallback appends text to main screen', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Toggle manual input
      await tester.tap(find.text('Ketik Manual'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        'Pesan darurat diketik manual',
      );
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Pesan darurat diketik manual'), findsOneWidget);
    });
  });
}
