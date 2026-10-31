import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/features/healthcare/domain/healthcare_facility.dart';
import 'package:taut/features/healthcare/presentation/healthcare_finder_screen.dart';
import 'package:taut/features/healthcare/presentation/healthcare_detail_screen.dart';
import 'package:taut/features/location_sharing/presentation/share_location_to_healthcare_screen.dart';

void main() {
  group('Healthcare Screens Tests', () {
    testWidgets('HealthcareFinderScreen renders search, categories, and facility cards', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HealthcareFinderScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fasilitas kesehatan'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Klinik'), findsWidgets);
      expect(find.text('Klinik Harmoni'), findsOneWidget);
      expect(find.text('RS Taman Sehat'), findsOneWidget);
    });

    testWidgets('HealthcareDetailScreen renders facility info and action buttons', (tester) async {
      const facility = HealthcareFacility(
        id: 'osm-test',
        name: 'RSUD Dr. Saiful Anwar',
        category: 'Rumah sakit',
        address: 'Jl. Jaksa Agung Suprapto No. 2, Klojen, Malang',
        latitude: -7.9723,
        longitude: 112.6318,
        distanceMeters: 1250,
        isWheelchairAccessible: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HealthcareDetailScreen(facility: facility),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('RSUD Dr. Saiful Anwar'), findsOneWidget);
      expect(find.text('Petunjuk Arah'), findsWidgets);
      expect(find.text('Bagikan lokasi fasilitas'), findsOneWidget);
    });

    testWidgets('ShareLocationToHealthcareScreen displays GPS coordinates and share CTA', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ShareLocationToHealthcareScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bagi Lokasi ke Faskes'), findsOneWidget);
      expect(find.textContaining('Latitude: -7.952600'), findsOneWidget);
      expect(find.text('Buka Lembar Berbagi Android'), findsOneWidget);
    });
  });
}
