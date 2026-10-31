import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/features/home/presentation/home_dashboard_screen.dart';

void main() {
  Widget createDashboard() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: const HomeDashboardScreen(),
    );
  }

  group('HomeDashboardScreen UI & Composition Tests', () {
    testWidgets('Renders Personalized Header with greeting and status', (tester) async {
      await tester.pumpWidget(createDashboard());
      await tester.pumpAndSettle();

      expect(find.text('Halo, selamat datang'), findsOneWidget);
      expect(find.text('Adriel'), findsOneWidget);
    });

    testWidgets('Renders Main Hero Card with illustration and CTA', (tester) async {
      await tester.pumpWidget(createDashboard());
      await tester.pumpAndSettle();

      expect(find.text('SETIAP CERITA BERARTI'), findsOneWidget);
      expect(find.text('Mulai Komunikasi'), findsOneWidget);
    });

    testWidgets('Renders 4 Feature Shortcuts with distinct labels', (tester) async {
      await tester.pumpWidget(createDashboard());
      await tester.pumpAndSettle();

      expect(find.text('Ucapan ke Teks'), findsOneWidget);
      expect(find.text('Isyarat ke Suara'), findsOneWidget);
      expect(find.text('Fasilitas Kesehatan'), findsOneWidget);
      expect(find.text('Berbagi Lokasi'), findsOneWidget);
    });

    testWidgets('Renders Connected Friends Preview and Active Location Sharing', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDashboard());
      await tester.pumpAndSettle();

      expect(find.text('Teman terhubung'), findsOneWidget);
      expect(find.text('Nadia'), findsOneWidget);
      expect(find.text('Raka'), findsOneWidget);
      expect(find.text('Dinda'), findsOneWidget);
    });
  });
}
