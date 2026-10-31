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

      expect(find.textContaining('taut'), findsOneWidget);
      expect(find.text('Ruang untuk saling memahami'), findsOneWidget);

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

      expect(find.text('SALING MEMAHAMI'), findsOneWidget);
      expect(find.textContaining('Ceritamu layak'), findsOneWidget);
      expect(find.text('Mulai bersama TAUT'), findsOneWidget);
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

      expect(find.text('Selamat datang'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Masuk demo'), findsOneWidget);
      expect(find.text('Jelajahi tanpa akun'), findsOneWidget);
    });

    testWidgets('RegisterScreen renders form fields and submit button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RegisterScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Buat akun'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('Daftar demo'), findsOneWidget);
    });

    testWidgets('EditProfileScreen renders profile inputs and submit button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const EditProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit profil'), findsOneWidget);
      expect(find.text('Nama panggilan'), findsOneWidget);
      expect(find.text('Simpan perubahan'), findsOneWidget);
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
      expect(find.text('Ukuran teks'), findsOneWidget);
      expect(find.text('Putar suara setelah konfirmasi'), findsOneWidget);
      expect(find.text('Mulai ulang onboarding'), findsOneWidget);
      expect(find.text('Reset seluruh demo'), findsOneWidget);
    });
  });
}
