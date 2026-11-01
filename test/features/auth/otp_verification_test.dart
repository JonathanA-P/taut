import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/core/routing/app_router.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/features/auth/presentation/otp_verification_screen.dart';
import 'package:taut/features/auth/presentation/register_screen.dart';
import 'package:taut/shared/models/taut_app_state.dart';
import 'package:taut/shared/widgets/taut_modular_background.dart';

void main() {
  group('OTP Verification Screen & Flow Tests', () {
    late TautAppState state;

    setUp(() {
      state = TautAppState();
      state.setGuestMode(true);
      state.setUserName('Tamu');
    });

    testWidgets('OtpVerificationScreen renders header, modular background, 6 pin boxes, and CTA', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OtpVerificationScreen(
            email: 'adriel@email.com',
            displayName: 'Adriel',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TautModularBackground), findsOneWidget);
      expect(find.text('VERIFIKASI AKUN'), findsOneWidget);
      expect(find.text('Masukkan Kode OTP'), findsOneWidget);
      expect(find.textContaining('adriel@email.com'), findsOneWidget);
      expect(find.text('Verifikasi & Masuk'), findsOneWidget);
      expect(find.textContaining('Kirim ulang kode dalam'), findsOneWidget);
    });

    testWidgets('Entering invalid OTP shows error feedback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OtpVerificationScreen(
            email: 'adriel@email.com',
            displayName: 'Adriel',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap submit without typing 6 digits
      await tester.tap(find.text('Verifikasi & Masuk'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Masukkan 6 digit'), findsOneWidget);
    });

    testWidgets('Entering 6 digit OTP verifies successfully and updates state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            AppRoutes.home: (ctx) => const Scaffold(body: Text('Beranda TAUT')),
          },
          home: const OtpVerificationScreen(
            email: 'adriel@email.com',
            displayName: 'Adriel',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter 6 digit code into textfield
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.text('Verifikasi & Masuk'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(state.isGuestMode, isFalse);
      expect(state.userName, equals('Adriel'));
    });

    testWidgets('RegisterScreen submission routes to OTP verification screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const RegisterScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap submit registration
      await tester.tap(find.text('Daftar Akun Baru'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.byType(OtpVerificationScreen), findsOneWidget);
      expect(find.text('Masukkan Kode OTP'), findsOneWidget);
    });
  });
}
