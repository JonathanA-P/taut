import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/app.dart';
import 'package:taut/core/constants/app_constants.dart';
import 'package:taut/core/utils/distance_calculator.dart';

void main() {
  group('TautApp Smoke & Navigation Test', () {
    testWidgets('Renders HomePage by default', (WidgetTester tester) async {
      await tester.pumpWidget(const TautApp());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Renders HomeShellScreen with all 4 primary destinations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const TautApp(initialRoute: AppConstants.routeHome),
      );
      await tester.pumpAndSettle();

      // Verify navigation bar destinations exist
      expect(find.text('Komunikasi'), findsWidgets);
      expect(find.text('Faskes'), findsOneWidget);
      expect(find.text('Bagi Lokasi'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Verify initial tab title
      expect(find.text('Komunikasi Dua Arah'), findsOneWidget);

      // Switch to Healthcare (Faskes) tab
      await tester.tap(find.byIcon(Icons.local_hospital_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Fasilitas Kesehatan Terdekat'), findsOneWidget);

      // Switch to Location Sharing (Bagi Lokasi) tab
      await tester.tap(find.byIcon(Icons.share_location_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Berbagi Lokasi'), findsOneWidget);

      // Switch to Profile (Profil) tab
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      expect(find.text('Profil & Pengaturan'), findsOneWidget);
    });
  });

  group('DistanceCalculator Haversine Test', () {
    test('Calculates distance accurately between two known points', () {
      // UB Malang (-7.9526, 112.6144) to Alun-alun Malang (-7.9826, 112.6308)
      // Actual geodesic distance is approx 3.7 - 3.8 km
      final meters = DistanceCalculator.distanceBetweenMeters(
        startLatitude: -7.9526,
        startLongitude: 112.6144,
        endLatitude: -7.9826,
        endLongitude: 112.6308,
      );

      expect(meters, greaterThan(3500.0));
      expect(meters, lessThan(4000.0));

      final formatted = DistanceCalculator.formatDistance(meters);
      expect(formatted, contains('km'));
    });

    test('Formats short distance in meters', () {
      final formatted = DistanceCalculator.formatDistance(450.0);
      expect(formatted, equals('450 m'));
    });
  });
}
