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

    testWidgets('Swiping left and right switches tabs smoothly between all 4 pages', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeShellScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(state.currentNavIndex, 0);
      expect(state.currentPage, 'home');
      expect(find.byType(PageView), findsOneWidget);

      // Swipe left from Beranda -> Komunikasi
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 1);
      expect(state.currentPage, 'hub');
      expect(find.text('Ruang komunikasi'), findsOneWidget);

      // Swipe left from Komunikasi -> Lokasi
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 2);
      expect(state.currentPage, 'location');
      expect(find.text('Ruang lokasi'), findsOneWidget);

      // Swipe left from Lokasi -> Profil
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 3);
      expect(state.currentPage, 'profile');
      expect(find.text('Profil'), findsWidgets);

      // Swipe right from Profil -> Lokasi
      await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 2);
      expect(state.currentPage, 'location');
      expect(find.text('Ruang lokasi'), findsOneWidget);
    });

    testWidgets('Tapping back button in Communication screen returns to Beranda with indicator synced to Beranda (index 0)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeShellScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to comm
      state.navigateTo('comm');
      await tester.pumpAndSettle();

      expect(state.currentPage, 'comm');
      expect(state.currentNavIndex, 1);
      expect(find.text('Komunikasi langsung'), findsOneWidget);

      // Tap back button at the top
      final backButton = find.byIcon(Icons.arrow_back_rounded);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify returned to Beranda and indicator is synced to Beranda (index 0)
      expect(state.currentPage, 'home');
      expect(state.currentNavIndex, 0);
      expect(find.text('Halo, selamat datang'), findsOneWidget);
    });

    testWidgets('Opening Isyarat ke Suara allows horizontal swipe across tabs and navbar taps switch pages accurately without getting stuck on Beranda', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeShellScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open Isyarat ke Suara from Beranda
      state.navigateTo('motion');
      await tester.pumpAndSettle();

      expect(state.currentPage, 'motion');
      expect(state.currentNavIndex, 0);
      expect(find.text('Isyarat BISINDO ke Suara'), findsOneWidget);

      // 1. Swipe left from Isyarat ke Suara -> Komunikasi
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 1);
      expect(state.currentPage, 'hub');
      expect(find.text('Ruang komunikasi'), findsOneWidget);

      // 2. Swipe left from Komunikasi -> Lokasi
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 2);
      expect(state.currentPage, 'location');
      expect(find.text('Ruang lokasi'), findsOneWidget);

      // 3. Return to motion
      state.navigateTo('motion');
      await tester.pumpAndSettle();
      expect(find.text('Isyarat BISINDO ke Suara'), findsOneWidget);

      // 4. Tap Lokasi tab from navbar -> must show Lokasi page, NOT Beranda!
      await tester.tap(find.text('Lokasi'));
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 2);
      expect(state.currentPage, 'location');
      expect(find.text('Ruang lokasi'), findsOneWidget);
      expect(find.text('Halo, selamat datang'), findsNothing);

      // 5. Tap Profil tab from navbar -> must show Profil page, NOT Beranda!
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 3);
      expect(state.currentPage, 'profile');
      expect(find.text('Profil'), findsWidgets);
      expect(find.text('Halo, selamat datang'), findsNothing);

      // 6. Tap Beranda tab from navbar -> must show HomePage!
      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 0);
      expect(state.currentPage, 'home');
      expect(find.text('Halo, selamat datang'), findsOneWidget);
    });

    testWidgets('Opening Ucapan ke Teks allows horizontal swipe across tabs and navbar taps switch pages accurately without getting stuck on Beranda', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeShellScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open Ucapan ke Teks from Beranda
      state.navigateTo('stt');
      await tester.pumpAndSettle();

      expect(state.currentPage, 'stt');
      expect(state.currentNavIndex, 0);
      expect(find.text('Live Speech-to-Text'), findsOneWidget);

      // 1. Swipe left from Ucapan ke Teks -> Komunikasi
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 1);
      expect(state.currentPage, 'hub');
      expect(find.text('Ruang komunikasi'), findsOneWidget);

      // 2. Swipe left from Komunikasi -> Lokasi
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 2);
      expect(state.currentPage, 'location');
      expect(find.text('Ruang lokasi'), findsOneWidget);

      // 3. Return to stt
      state.navigateTo('stt');
      await tester.pumpAndSettle();
      expect(find.text('Live Speech-to-Text'), findsOneWidget);

      // 4. Tap Lokasi tab from navbar -> must show Lokasi page, NOT Beranda!
      await tester.tap(find.text('Lokasi'));
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 2);
      expect(state.currentPage, 'location');
      expect(find.text('Ruang lokasi'), findsOneWidget);
      expect(find.text('Halo, selamat datang'), findsNothing);

      // 5. Tap Profil tab from navbar -> must show Profil page, NOT Beranda!
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 3);
      expect(state.currentPage, 'profile');
      expect(find.text('Profil'), findsWidgets);
      expect(find.text('Halo, selamat datang'), findsNothing);

      // 6. Tap Beranda tab from navbar -> must show HomePage!
      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 0);
      expect(state.currentPage, 'home');
      expect(find.text('Halo, selamat datang'), findsOneWidget);

      // 7. Tap back button from AppBar in STT returns to Beranda
      state.navigateTo('stt');
      await tester.pumpAndSettle();
      expect(find.text('Live Speech-to-Text'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 0);
      expect(state.currentPage, 'home');
      expect(find.text('Halo, selamat datang'), findsOneWidget);
    });

    testWidgets('Opening Mulai Komunikasi (comm) allows horizontal swipe across tabs and navbar taps switch pages accurately without getting stuck on Beranda', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeShellScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open Mulai Komunikasi (comm)
      state.navigateTo('comm');
      await tester.pumpAndSettle();

      expect(state.currentPage, 'comm');
      expect(state.currentNavIndex, 1);
      expect(find.text('Komunikasi langsung'), findsOneWidget);

      // 1. Swipe left from comm (Tab 1) -> Lokasi (Tab 2)
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 2);
      expect(state.currentPage, 'location');
      expect(find.text('Ruang lokasi'), findsOneWidget);

      // 2. Return to comm
      state.navigateTo('comm');
      await tester.pumpAndSettle();
      expect(find.text('Komunikasi langsung'), findsOneWidget);

      // 3. Swipe right from comm (Tab 1) -> Beranda (Tab 0)
      await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 0);
      expect(state.currentPage, 'home');
      expect(find.text('Halo, selamat datang'), findsOneWidget);

      // 4. Return to comm
      state.navigateTo('comm');
      await tester.pumpAndSettle();
      expect(find.text('Komunikasi langsung'), findsOneWidget);

      // 5. Tap Lokasi tab from navbar -> must show Lokasi page, NOT Beranda!
      await tester.tap(find.text('Lokasi'));
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 2);
      expect(state.currentPage, 'location');
      expect(find.text('Ruang lokasi'), findsOneWidget);
      expect(find.text('Halo, selamat datang'), findsNothing);

      // 6. Return to comm and tap Profil tab from navbar -> must show Profil page, NOT Beranda!
      state.navigateTo('comm');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 3);
      expect(state.currentPage, 'profile');
      expect(find.text('Profil'), findsWidgets);
      expect(find.text('Halo, selamat datang'), findsNothing);

      // 7. Return to comm and tap Beranda tab from navbar -> must show HomePage!
      state.navigateTo('comm');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 0);
      expect(state.currentPage, 'home');
      expect(find.text('Halo, selamat datang'), findsOneWidget);

      // 8. Return to comm and tap Komunikasi tab from navbar -> returns to hub (CommunicationLandingScreen)
      state.navigateTo('comm');
      await tester.pumpAndSettle();
      expect(find.text('Komunikasi langsung'), findsOneWidget);
      await tester.tap(find.text('Komunikasi'));
      await tester.pumpAndSettle();
      expect(state.currentNavIndex, 1);
      expect(state.currentPage, 'hub');
      expect(find.text('Ruang komunikasi'), findsOneWidget);
    });
  });
}
