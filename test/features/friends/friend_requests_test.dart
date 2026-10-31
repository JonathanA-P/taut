import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/features/auth/presentation/profile_screen.dart';
import 'package:taut/features/friends/presentation/friends_list_screen.dart';
import 'package:taut/shared/models/taut_app_state.dart';

void main() {
  group('Username and Friend Requests Tests', () {
    late TautAppState state;

    setUp(() {
      state = TautAppState();
      state.setUserName('Adriel');
      state.setUserHandle('adriel');
    });

    testWidgets('ProfileScreen displays unique username handle under user name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Adriel'), findsOneWidget);
      expect(find.text('@adriel'), findsOneWidget);
    });

    testWidgets('FriendsListScreen displays pending requests with Terima and Tolak actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const FriendsListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Permintaan Pertemanan'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('@budi.s'), findsOneWidget);
      expect(find.text('Terima'), findsWidgets);
      expect(find.text('Tolak'), findsWidgets);

      final initialFriendsCount = state.friends.length;

      // Accept first request (Budi Santoso)
      await tester.tap(find.text('Terima').first);
      await tester.pumpAndSettle();

      expect(state.friends.contains('Budi Santoso'), isTrue);
      expect(state.friends.length, equals(initialFriendsCount + 1));
    });
  });
}
