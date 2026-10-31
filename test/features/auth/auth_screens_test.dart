import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/core/routing/app_router.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/features/auth/presentation/splash_screen.dart';
import 'package:taut/features/auth/presentation/onboarding_screen.dart';
import 'package:taut/features/auth/presentation/welcome_screen.dart';
import 'package:taut/features/auth/presentation/login_screen.dart';
import 'package:taut/features/auth/presentation/register_screen.dart';
import 'package:taut/features/auth/presentation/edit_profile_screen.dart';
import 'package:taut/features/auth/presentation/settings_accessibility_screen.dart';

void main() {
  group('Auth & Profile Screens Tests', () {
    testWidgets('SplashScreen renders TAUT Welcome screen and navigates to Onboarding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );
      await tester.pump();

      expect(find.text('taut.', findRichText: true), findsOneWidget);
      expect(find.text('Ruang untuk saling memahami'), findsOneWidget);
      expect(find.text('Mulai Eksplorasi'), findsOneWidget);

      await tester.tap(find.text('Mulai Eksplorasi'));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('Complete startup flow: Welcome -> Intro Splash (1..3) -> Register <-> Login', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.welcome,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );
      await tester.pump();

      // 1. TAUT Welcome (Gambar 1)
      expect(find.text('Mulai Eksplorasi'), findsOneWidget);
      await tester.tap(find.text('Mulai Eksplorasi'));
      await tester.pumpAndSettle();

      // 2. Intro Splash 1
      expect(find.textContaining('SALING MEMAHAMI'), findsOneWidget);
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      // 3. Intro Splash 2
      expect(find.textContaining('KOMUNIKASI DUA ARAH'), findsOneWidget);
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      // 4. Intro Splash 3
      expect(find.textContaining('AMAN & DEKAT'), findsOneWidget);
      await tester.tap(find.text('Selesai & Daftar'));
      await tester.pumpAndSettle();

      // 5. Menu Register
      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.text('Daftar Akun Baru'), findsOneWidget);

      // 6. Switch from Register to Login
      final loginBtnFinder = find.text('Masuk di sini');
      await tester.ensureVisible(loginBtnFinder);
      await tester.tap(loginBtnFinder);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Masuk ke TAUT'), findsOneWidget);

      // 7. Switch from Login back to Register
      final registerBtnFinder = find.text('Daftar Sekarang');
      await tester.ensureVisible(registerBtnFinder);
      await tester.tap(registerBtnFinder);
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('OnboardingScreen renders 3-step intro slides, illustration, and CTA', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('SALING MEMAHAMI'), findsOneWidget);
      expect(find.textContaining('Ceritamu layak'), findsOneWidget);
      expect(find.text('Lanjut'), findsOneWidget);
      expect(find.text('Lewati'), findsOneWidget);
    });

    testWidgets('WelcomeScreen renders brand, resonance waves, and Mulai Eksplorasi CTA', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const WelcomeScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('taut.', findRichText: true), findsOneWidget);
      expect(find.text('Ruang untuk saling memahami'), findsOneWidget);
      expect(find.text('Mulai Eksplorasi'), findsOneWidget);
    });

    testWidgets('LoginScreen renders email and password fields, SSO, and submit button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Senang bertemu lagi'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Masuk ke TAUT'), findsOneWidget);
      expect(find.textContaining('Jelajahi tanpa Akun'), findsOneWidget);
    });

    testWidgets('RegisterScreen renders form fields, terms, and submit button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RegisterScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Mulai perjalananmu'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('Daftar Akun Baru'), findsOneWidget);
      expect(find.textContaining('Jelajahi tanpa Akun'), findsOneWidget);
    });

    testWidgets('EditProfileScreen renders profile inputs, avatar photo picker, and submit button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const EditProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit profil'), findsOneWidget);
      expect(find.text('Nama panggilan'), findsOneWidget);
      expect(find.text('Ubah foto profil'), findsOneWidget);
      expect(find.text('Simpan perubahan'), findsOneWidget);

      // Tap photo picker to open sheet
      await tester.tap(find.text('Ubah foto profil'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Foto Profil'), findsOneWidget);
      expect(find.textContaining('Pilih foto atau avatar'), findsOneWidget);
    });

    testWidgets('SettingsAccessibilityScreen renders accessibility toggles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SettingsAccessibilityScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Putar suara setelah konfirmasi'), findsOneWidget);
      expect(find.text('Mulai ulang onboarding'), findsOneWidget);
      expect(find.text('Reset seluruh demo'), findsOneWidget);
    });
  });
}
