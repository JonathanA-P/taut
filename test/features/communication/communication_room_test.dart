import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/features/communication/presentation/communication_hub_screen.dart';
import 'package:taut/shared/models/taut_app_state.dart';

void main() {
  group('Room Communication (Ruangan Obrolan Jarak Jauh) Tests', () {
    late TautAppState state;

    setUp(() {
      state = TautAppState();
      state.endRoomSession();
    });

    testWidgets('Renders room trigger bar between title and camera viewport', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CommunicationHubScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Buat ruangan obrolan'), findsOneWidget);
      expect(find.text('Untuk kelas/jarak jauh multi-pengguna'), findsOneWidget);
      expect(find.text('Buat Room'), findsOneWidget);
      expect(find.text('Gabung'), findsOneWidget);
    });

    testWidgets('Tapping Buat Room opens room setup sheet with name, join mode, code, and QR', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CommunicationHubScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Buat Room
      await tester.tap(find.text('Buat Room'));
      await tester.pumpAndSettle();

      expect(find.text('Buat Ruangan Obrolan'), findsOneWidget);
      expect(find.text('Nama Ruangan'), findsOneWidget);
      expect(find.text('Izin Bergabung Peserta'), findsOneWidget);
      expect(find.text('Konfirmasi Manual'), findsOneWidget);
      expect(find.text('TAUT-8921'), findsOneWidget);
      expect(find.text('Mulai ruangan obrolan'), findsOneWidget);

      // Host starts room
      await tester.tap(find.text('Mulai ruangan obrolan'));
      await tester.pumpAndSettle();

      expect(state.isRoomActive, isTrue);
      expect(find.textContaining('Kode: TAUT-8921'), findsOneWidget);

      // Pending join requests appear after room starts
      expect(find.text('Nadia (Teman)'), findsOneWidget);
      expect(find.text('Terima'), findsWidgets);
      expect(find.text('Tolak'), findsWidgets);

      // Host accepts Nadia
      await tester.tap(find.text('Terima').first);
      await tester.pumpAndSettle();

      expect(state.roomParticipants.contains('Nadia (Teman)'), isTrue);
    });

    testWidgets('Tapping Gabung opens join dialog with direct room code access', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CommunicationHubScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gabung'));
      await tester.pumpAndSettle();

      expect(find.text('Gabung Ruangan Obrolan'), findsOneWidget);
      expect(find.text('Gabung langsung'), findsOneWidget);

      await tester.tap(find.text('Gabung langsung'));
      await tester.pumpAndSettle();

      expect(state.isRoomActive, isTrue);
    });
  });
}

