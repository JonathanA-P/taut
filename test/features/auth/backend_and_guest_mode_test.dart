import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/features/auth/presentation/profile_screen.dart';
import 'package:taut/features/home/presentation/home_page.dart';
import 'package:taut/features/location_sharing/presentation/location_sharing_screen.dart';
import 'package:taut/shared/models/taut_app_state.dart';
import 'package:taut/shared/widgets/taut_avatar.dart';

void main() {
  group('Backend Governance, Room Capacity & Guest Mode Tests', () {
    late TautAppState state;

    setUp(() {
      state = TautAppState();
      state.endRoomSession();
      state.setGuestMode(false);
      state.setUserName('Adriel');
    });

    test('Room Capacity limit of 10 participants enforced', () {
      expect(TautAppState.maxRoomCapacity, equals(10));
      state.createRoom(name: 'Ruang Kelas Hackathon', autoAccept: true);
      state.startRoomSession();

      // With autoAccept=true, room has host + 2 candidates = 3 participants
      expect(state.roomParticipants.length, equals(3));
      expect(state.isRoomFull, isFalse);

      // Add participants up to 10
      for (int i = 4; i <= 10; i++) {
        state.acceptRoomParticipant('Peserta_$i');
      }
      expect(state.roomParticipants.length, equals(10));
      expect(state.isRoomFull, isTrue);

      // Try adding 11th participant -> must be rejected
      state.acceptRoomParticipant('Peserta_11');
      expect(state.roomParticipants.length, equals(10));
      expect(state.roomParticipants.contains('Peserta_11'), isFalse);
    });

    test('Single active room constraint: user cannot create or join multiple rooms', () {
      final created = state.createRoom(name: 'Ruang A');
      expect(created, isTrue);
      state.startRoomSession();
      expect(state.isRoomActive, isTrue);

      // Attempt to join another room while room is active -> rejected
      final joinAnother = state.joinRoomByCode('TAUT-9999');
      expect(joinAnother, isFalse);

      // Attempt to create another room while active -> rejected
      final createAnother = state.createRoom(name: 'Ruang B');
      expect(createAnother, isFalse);
    });

    test('Guest Mode allows communication & faskes, but restricts others', () {
      state.setGuestMode(true);
      expect(state.isGuestMode, isTrue);
      expect(state.userName, equals('Tamu TAUT'));

      // Allowed features for guest
      expect(state.isFeatureAllowedForGuest('home'), isTrue);
      expect(state.isFeatureAllowedForGuest('comm'), isTrue);
      expect(state.isFeatureAllowedForGuest('hub'), isTrue);
      expect(state.isFeatureAllowedForGuest('stt'), isTrue);
      expect(state.isFeatureAllowedForGuest('motion'), isTrue);
      expect(state.isFeatureAllowedForGuest('finder'), isTrue);
      expect(state.isFeatureAllowedForGuest('faskes'), isTrue);

      // Restricted features for guest
      expect(state.isFeatureAllowedForGuest('sharing'), isFalse);
      expect(state.isFeatureAllowedForGuest('friends'), isFalse);
      expect(state.isFeatureAllowedForGuest('live'), isFalse);
      expect(state.isFeatureAllowedForGuest('edit'), isFalse);
    });

    testWidgets('Guest tapping restricted feature on HomePage triggers auth gate prompt', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      state.setGuestMode(true);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomePage(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Berbagi Lokasi' tile
      final sharingTile = find.text('Berbagi Lokasi');
      expect(sharingTile, findsOneWidget);
      await tester.tap(sharingTile);
      await tester.pumpAndSettle();

      // Auth Gate dialog must appear
      expect(find.text('Perlu Masuk Akun'), findsOneWidget);
      expect(find.textContaining('Fitur Berbagi Lokasi'), findsOneWidget);
      expect(find.text('Masuk atau Buat Akun'), findsOneWidget);
    });

    testWidgets('Guest tapping restricted feature on LocationSharingScreen triggers auth gate prompt', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      state.setGuestMode(true);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LocationSharingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Teman terhubung' button
      final friendsButton = find.text('Teman terhubung');
      expect(friendsButton, findsOneWidget);
      await tester.tap(friendsButton);
      await tester.pumpAndSettle();

      // Auth Gate dialog must appear
      expect(find.text('Perlu Masuk Akun'), findsOneWidget);
      expect(find.textContaining('Teman Terhubung'), findsOneWidget);
    });

    testWidgets('ProfileScreen shows Mode Tamu banner when guest is active', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      state.setGuestMode(true);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mode Tamu Aktif'), findsOneWidget);
      expect(find.textContaining('menjelajahi TAUT tanpa akun'), findsOneWidget);

      // Tapping Edit Profil opens auth prompt
      await tester.tap(find.text('Edit profil'));
      await tester.pumpAndSettle();

      expect(find.text('Perlu Masuk Akun'), findsOneWidget);
    });

    testWidgets('TautAvatar renders local file path smoothly without throwing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TautAvatar(
              name: 'Adriel',
              avatarUrl: '/data/user/0/io.supabase.taut/avatar.jpg',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Renders CircleAvatar or fallback initial smoothly without crash
      expect(find.byType(TautAvatar), findsOneWidget);
    });
  });
}
