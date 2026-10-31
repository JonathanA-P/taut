import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/core/routing/app_router.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/features/auth/presentation/splash_screen.dart';
import 'package:taut/features/auth/presentation/onboarding_screen.dart';
import 'package:taut/features/auth/presentation/login_screen.dart';
import 'package:taut/features/auth/presentation/register_screen.dart';
import 'package:taut/features/auth/presentation/edit_profile_screen.dart';
import 'package:taut/features/auth/presentation/settings_accessibility_screen.dart';

void main() {
  group('Auth & Profile Screens Tests', () {
    testWidgets('SplashScreen renders TAUT brand title and tagline', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );
      await tester.pump();

      expect(find.text('TAUT'), findsOneWidget);
      expect(find.text('Aksesibilitas & Komunikasi Inklusif'), findsOneWidget);

      // Advance timer so pending timer resolves
      await tester.pump(const Duration(milliseconds: 1600));
    });

    testWidgets('OnboardingScreen renders title, illustration, and CTA', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Komunikasi Inklusif'), findsOneWidget);
      expect(find.text('Lanjutkan'), findsOneWidget);
      expect(find.text('Lewati'), findsOneWidget);
    });

    testWidgets('LoginScreen renders email and password fields and submit button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Selamat Datang Kembali'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Masuk Akun'), findsOneWidget);
    });

    testWidgets('RegisterScreen renders form fields and role chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RegisterScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bergabung Bersama TAUT'), findsOneWidget);
      expect(find.text('Teman Tuli'), findsOneWidget);
      expect(find.text('Teman Dengar'), findsOneWidget);
      expect(find.text('Buat Akun TAUT'), findsOneWidget);
    });

    testWidgets('EditProfileScreen renders profile inputs and role selector', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const EditProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ubah Profil'), findsOneWidget);
      expect(find.text('Alfredo Jonathan Purba'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);
    });

    testWidgets('SettingsAccessibilityScreen renders accessibility toggles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SettingsAccessibilityScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pengaturan & Aksesibilitas'), findsOneWidget);
      expect(find.text('Skala Ukuran Teks'), findsOneWidget);
      expect(find.text('Mode Kontras Maksimal'), findsOneWidget);
      expect(find.text('Getaran Haptik Konfirmasi'), findsOneWidget);
    });
  });
}
