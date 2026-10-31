import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/features/friends/presentation/friends_list_screen.dart';
import 'package:taut/features/friends/presentation/add_friend_screen.dart';
import 'package:taut/features/friends/presentation/live_location_screen.dart';
import 'package:taut/features/friends/presentation/manage_location_sharing_screen.dart';

void main() {
  group('Friends & Live Location Screens Tests', () {
    testWidgets('FriendsListScreen renders friends, avatars, and status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const FriendsListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Teman terhubung'), findsOneWidget);
      expect(find.text('Nadia'), findsOneWidget);
      expect(find.text('Raka'), findsOneWidget);
      expect(find.text('Tambah teman'), findsOneWidget);
    });

    testWidgets('AddFriendScreen displays input field and submit button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddFriendScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tambah teman'), findsOneWidget);
      expect(find.text('Perluas ruang terhubung.'), findsOneWidget);
      expect(find.text('Nama teman'), findsOneWidget);
      expect(find.text('Tambah ke demo'), findsOneWidget);
    });

    testWidgets('LiveLocationScreen renders live map and friend details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LiveLocationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lokasi bersama'), findsOneWidget);
      expect(find.text('Sesi berbagi demo'), findsOneWidget);
      expect(find.textContaining('Peta ilustrasi'), findsOneWidget);
    });

    testWidgets('ManageLocationSharingScreen displays form and active sessions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ManageLocationSharingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Berbagi lokasi'), findsOneWidget);
      expect(find.text('Mulai sesi baru'), findsOneWidget);
      expect(find.text('Bagikan kepada'), findsOneWidget);
      expect(find.text('Durasi'), findsOneWidget);
      expect(find.text('Mulai berbagi demo'), findsOneWidget);
    });
  });
}
