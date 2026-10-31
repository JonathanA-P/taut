import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/features/friends/presentation/manage_location_sharing_screen.dart';
import 'package:taut/features/friends/presentation/widgets/friend_location_detail_sheet.dart';
import 'package:taut/shared/models/taut_app_state.dart';
import 'package:taut/shared/widgets/taut_open_street_map.dart';

void main() {
  group('Location Sharing Consent and Individual Location Viewer Tests', () {
    late TautAppState state;

    setUp(() {
      state = TautAppState();
      state.endRoomSession();
    });

    test('IncomingSharingSession model supports consent statuses', () {
      final session = IncomingSharingSession(
        id: 'test-1',
        friendName: 'Raka',
        subtitle: 'Dekat Stasiun',
        latitude: -7.97,
        longitude: 112.63,
        expiry: DateTime.now().add(const Duration(minutes: 30)),
        status: IncomingSharingStatus.pending,
      );

      expect(session.isPending, isTrue);
      expect(session.isAccepted, isFalse);

      session.status = IncomingSharingStatus.accepted;
      expect(session.isAccepted, isTrue);
      expect(session.isPending, isFalse);

      session.status = IncomingSharingStatus.rejected;
      expect(session.isRejected, isTrue);
    });

    testWidgets('Displays pending incoming request with consent choice (Setuju vs Tolak)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ManageLocationSharingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check pending request section
      expect(find.text('Permintaan berbagi lokasi masuk'), findsOneWidget);
      expect(find.text('Budi Setiawan'), findsOneWidget);
      expect(find.text('Menunggu Persetujuan'), findsOneWidget);
      expect(find.text('Setuju & Terima'), findsOneWidget);
      expect(find.text('Tolak'), findsOneWidget);

      // Check accepted active friend section
      expect(find.text('Daftar orang yang diterima berbagi lokasinya'), findsOneWidget);
      expect(find.text('Nadia'), findsWidgets);
      expect(find.text('Lihat Lokasi Teman'), findsWidgets);
      expect(find.text('Sembunyikan'), findsWidgets);
    });

    testWidgets('Tapping Setuju & Terima approves pending request and enables viewing', (tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ManageLocationSharingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to Setuju & Terima and tap
      final acceptButton = find.text('Setuju & Terima');
      expect(acceptButton, findsOneWidget);
      await tester.ensureVisible(acceptButton);
      await tester.tap(acceptButton);
      await tester.pumpAndSettle();

      // Now Budi Setiawan is accepted, no pending requests remain
      expect(state.pendingIncomingSessions, isEmpty);
      expect(state.acceptedIncomingSessions.length, 2);

      // SnackBar shows confirmation
      expect(find.text('Permintaan berbagi lokasi dari Budi Setiawan diterima.'), findsOneWidget);
    });

    testWidgets('Tapping Lihat Lokasi Teman opens FriendLocationDetailSheet with map and coordinates', (tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ManageLocationSharingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Lihat Lokasi Teman for Nadia
      final viewMapButtons = find.text('Lihat Lokasi Teman');
      expect(viewMapButtons, findsWidgets);
      await tester.ensureVisible(viewMapButtons.first);
      await tester.tap(viewMapButtons.first);
      await tester.pumpAndSettle();

      // Bottom sheet is displayed
      expect(find.byType(FriendLocationDetailSheet), findsOneWidget);
      expect(find.text('Lokasi Nadia'), findsOneWidget);
      expect(find.textContaining('Pelacakan GPS real-time'), findsOneWidget);
      expect(find.byType(TautOpenStreetMap), findsOneWidget);
      expect(find.text('Buka di Peta Bersama'), findsOneWidget);
      expect(find.text('Hentikan'), findsOneWidget);
    });
  });
}
