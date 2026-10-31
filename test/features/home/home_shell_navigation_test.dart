import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/features/home/presentation/home_shell_screen.dart';
import 'package:taut/shared/models/taut_app_state.dart';

void main() {
  group('HomeShellScreen Smooth Navigation & Sliding Indicator Tests', () {
    late TautAppState state;

    setUp(() {
      state = TautAppState();
      state.switchToTab(0);
    });

    testWidgets('Renders floating nav bar with 4 tabs and sliding indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeShellScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check all 4 destinations exist
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Komunikasi'), findsOneWidget);
      expect(find.text('Lokasi'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Verify sliding indicator AnimatedPositioned exists
      expect(find.byType(AnimatedPositioned), findsOneWidget);
    });

    testWidgets('Tapping Komunikasi tab updates active nav index immediately without delay', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeShellScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(state.currentNavIndex, 0);

      // Tap Komunikasi
      await tester.tap(find.text('Komunikasi'));
      await tester.pumpAndSettle();

      expect(state.currentNavIndex, 1);
      expect(state.currentPage, 'hub');
      expect(find.text('Ruang komunikasi'), findsOneWidget);
    });

    testWidgets('Tapping Lokasi and Profil transitions smoothly across all tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeShellScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Lokasi
      await tester.tap(find.text('Lokasi'));
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 2);
      expect(state.currentPage, 'location');
      expect(find.text('Ruang lokasi'), findsOneWidget);

      // Switch to Profil
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 3);
      expect(state.currentPage, 'profile');
      expect(find.text('Profil'), findsWidgets);

      // Switch back to Beranda
      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 0);
      expect(state.currentPage, 'home');
      expect(find.text('Halo, selamat datang'), findsOneWidget);
    });
  });
}
