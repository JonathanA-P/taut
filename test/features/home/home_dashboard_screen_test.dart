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

      expect(find.text('Halo, Alfredo'), findsOneWidget);
      expect(find.textContaining('Semua sensor siap'), findsOneWidget);
      expect(find.text('AJ'), findsOneWidget);
    });

    testWidgets('Renders Main Hero Card with illustration and CTA', (tester) async {
      await tester.pumpWidget(createDashboard());
      await tester.pumpAndSettle();

      expect(find.text('Mulai Komunikasi Dua Arah'), findsOneWidget);
      expect(find.text('Mulai Komunikasi'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_rounded), findsOneWidget);
    });

    testWidgets('Renders 4 Feature Shortcuts with distinct labels', (tester) async {
      await tester.pumpWidget(createDashboard());
      await tester.pumpAndSettle();

      expect(find.text('Suara ke Teks'), findsOneWidget);
      expect(find.text('Gerakan ke Suara'), findsOneWidget);
      expect(find.text('Pencari Faskes'), findsOneWidget);
      expect(find.text('Bagi Lokasi'), findsOneWidget);
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

      expect(find.text('Teman Terhubung'), findsOneWidget);
      expect(find.text('Adriel Christo'), findsOneWidget);
      expect(find.text('Roganda Tua'), findsOneWidget);

      expect(find.text('Sesi Berbagi Lokasi Aktif'), findsOneWidget);
      expect(find.text('Kelola Berbagi'), findsOneWidget);
    });
  });
}
