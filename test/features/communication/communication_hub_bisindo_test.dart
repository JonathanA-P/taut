import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/features/communication/motion_to_sound/domain/bisindo_labels.dart';
import 'package:taut/features/communication/presentation/communication_hub_screen.dart';
import 'package:taut/shared/models/taut_app_state.dart';

void main() {
  group('CommunicationHubScreen BISINDO Feature Parity Tests', () {
    late TautAppState state;

    setUp(() {
      state = TautAppState();
      state.clearMessages();
    });

    testWidgets('Renders Mode Deteksi Gerakan with Kata, Abjad, and Angka segments', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CommunicationHubScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mode Deteksi Gerakan'), findsOneWidget);
      expect(find.textContaining('Kata'), findsOneWidget);
      expect(find.textContaining('Abjad'), findsOneWidget);
      expect(find.textContaining('Angka'), findsOneWidget);

      // Tap Abjad segment
      await tester.tap(find.textContaining('Abjad'));
      await tester.pumpAndSettle();

      // Tap Angka segment
      await tester.tap(find.textContaining('Angka'));
      await tester.pumpAndSettle();

      // Tap Kata segment back
      await tester.tap(find.textContaining('Kata'));
      await tester.pumpAndSettle();
    });

    testWidgets('Renders Bilah Kalimat & Ejaan with Suara Otomatis, edit controls, presets, and audio CTA', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CommunicationHubScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bilah Kalimat & Ejaan'), findsOneWidget);
      expect(find.text('Suara Otomatis'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);

      expect(find.text('Spasi'), findsOneWidget);
      expect(find.text('Hapus 1'), findsOneWidget);
      expect(find.byTooltip('Bersihkan Kalimat'), findsOneWidget);

      expect(find.textContaining('Suarakan Sekarang'), findsOneWidget);

      // Toggle Suara Otomatis switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Select a preset chip
      final presetFinder = find.text('Terima kasih banyak');
      await tester.ensureVisible(presetFinder);
      await tester.tap(presetFinder);
      await tester.pumpAndSettle();

      expect(find.textContaining('Terima kasih banyak'), findsWidgets);

      // Tap Spasi
      final spasiFinder = find.text('Spasi');
      await tester.ensureVisible(spasiFinder);
      await tester.tap(spasiFinder);
      await tester.pumpAndSettle();

      // Tap Hapus 1
      final hapusFinder = find.text('Hapus 1');
      await tester.ensureVisible(hapusFinder);
      await tester.tap(hapusFinder);
      await tester.pumpAndSettle();

      // Tap Suarakan Sekarang / Putar Suara
      final ctaFinder = find.textContaining('Suarakan Sekarang');
      await tester.ensureVisible(ctaFinder);
      await tester.tap(ctaFinder);
      await tester.pumpAndSettle();

      // Message added to conversation thread
      expect(state.messages.any((m) => m.text.contains('Terima kasih banyak')), isTrue);

      // Clear sentence
      final clearFinder = find.byTooltip('Bersihkan Kalimat');
      await tester.ensureVisible(clearFinder);
      await tester.tap(clearFinder);
      await tester.pumpAndSettle();

      expect(find.text('Rangkaian kata atau ejaan akan tersusun di sini...'), findsOneWidget);
    });
  });
}
