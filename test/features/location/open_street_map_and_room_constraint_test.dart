import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/features/friends/presentation/live_location_screen.dart';
import 'package:taut/features/friends/presentation/manage_location_sharing_screen.dart';
import 'package:taut/shared/models/taut_app_state.dart';
import 'package:taut/shared/widgets/taut_open_street_map.dart';

void main() {
  group('OpenStreetMap & Location Sharing Tests', () {
    late TautAppState state;

    setUp(() {
      state = TautAppState();
      state.endRoomSession();
    });

    testWidgets('TautOpenStreetMap renders correctly with custom markers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: TautOpenStreetMap(
              initialCenter: const LatLng(-7.9723, 112.6318),
              markers: const [
                TautMapMarker(
                  point: LatLng(-7.9723, 112.6318),
                  label: 'Posisi Saya',
                  isUser: true,
                ),
                TautMapMarker(
                  point: LatLng(-7.9826, 112.6308),
                  label: 'Nadia',
                  avatarText: 'N',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TautOpenStreetMap), findsOneWidget);
      expect(find.text('OpenStreetMap'), findsOneWidget);
    });

    testWidgets('ManageLocationSharingScreen displays incoming friend locations card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ManageLocationSharingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lokasi teman yang dibagikan'), findsOneWidget);
      expect(find.text('Nadia'), findsWidgets);
      expect(find.text('Budi Setiawan'), findsOneWidget);
      expect(find.text('Lihat di Peta'), findsWidgets);
    });

    testWidgets('LiveLocationScreen displays OpenStreetMap and incoming friend locations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LiveLocationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TautOpenStreetMap), findsOneWidget);
      expect(find.text('Lokasi bersama'), findsOneWidget);
      expect(find.text('Lokasi teman yang diterima'), findsOneWidget);
      expect(find.text('Nadia'), findsWidgets);
      expect(find.text('Budi Setiawan'), findsOneWidget);
    });
  });

  group('Communication Room 1-User 1-Room Constraint Tests', () {
    late TautAppState state;

    setUp(() {
      state = TautAppState();
      state.endRoomSession();
    });

    test('User can create room when no room is active, but cannot create a second room while active', () {
      expect(state.isRoomActive, isFalse);

      // Create first room
      final created = state.createRoom(name: 'Kelas 1');
      expect(created, isTrue);
      expect(state.isHost, isTrue);

      // Start the room session
      state.startRoomSession();
      expect(state.isRoomActive, isTrue);

      // Try creating another room while active
      final secondCreate = state.createRoom(name: 'Kelas 2');
      expect(secondCreate, isFalse); // Blocked!

      // Try joining while active
      final joinAttempt = state.joinRoomByCode('TAUT-9999');
      expect(joinAttempt, isFalse); // Blocked!

      // End active session
      state.endRoomSession();
      expect(state.isRoomActive, isFalse);
      expect(state.isHost, isFalse);

      // Now user can create room again
      final canCreateAgain = state.createRoom(name: 'Kelas Baru');
      expect(canCreateAgain, isTrue);
    });

    test('User can join room when no room is active, but cannot join another room while active', () {
      expect(state.isRoomActive, isFalse);

      // Join room
      final joined = state.joinRoomByCode('TAUT-7777');
      expect(joined, isTrue);
      expect(state.isRoomActive, isTrue);
      expect(state.isHost, isFalse);

      // Try creating room while in active joined session
      final createAttempt = state.createRoom(name: 'Kelas Saya');
      expect(createAttempt, isFalse); // Blocked!

      // Try joining another room while active
      final secondJoin = state.joinRoomByCode('TAUT-8888');
      expect(secondJoin, isFalse); // Blocked!

      // Leave / End session
      state.endRoomSession();
      expect(state.isRoomActive, isFalse);

      // User can now join another room
      final joinAgain = state.joinRoomByCode('TAUT-8888');
      expect(joinAgain, isTrue);
    });
  });
}
