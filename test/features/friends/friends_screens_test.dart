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

      expect(find.text('Daftar Teman & Undangan'), findsOneWidget);
      expect(find.text('Adriel Christo Lumbantoruan'), findsOneWidget);
      expect(find.text('Roganda Tua Tampubolon'), findsOneWidget);
    });

    testWidgets('AddFriendScreen displays personal invitation code and input field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddFriendScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hubungkan Teman & Pendamping'), findsOneWidget);
      expect(find.textContaining('TAUT-ALFREDO'), findsOneWidget);
      expect(find.text('Hubungkan Teman Sekarang'), findsOneWidget);
    });

    testWidgets('LiveLocationScreen renders live map and friend details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LiveLocationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pantau Lokasi Langsung'), findsOneWidget);
      expect(find.textContaining('Adriel Christo'), findsWidgets);
      expect(find.text('Buka Navigasi ke Teman (Google Maps)'), findsOneWidget);
    });

    testWidgets('ManageLocationSharingScreen displays master and individual switches', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ManageLocationSharingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kelola Berbagi Lokasi'), findsOneWidget);
      expect(find.text('Siaran Lokasi Langsung'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(4));
    });
  });
}
