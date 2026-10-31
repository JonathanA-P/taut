import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/features/healthcare/domain/healthcare_facility.dart';
import 'package:taut/features/healthcare/presentation/healthcare_finder_screen.dart';
import 'package:taut/features/healthcare/presentation/healthcare_detail_screen.dart';
import 'package:taut/features/location_sharing/presentation/share_location_to_healthcare_screen.dart';
import 'package:taut/shared/models/taut_app_state.dart';

void main() {
  group('Healthcare Screens Tests', () {
    setUp(() {
      TautAppState().resetDemo();
    });

    testWidgets('HealthcareFinderScreen initially shows "Lokasi belum diketahui", hides mock data, and loads real facilities on button press with similarity search', (tester) async {
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

      // 1. Initial State: Location not yet known, no mock data, no "Data contoh", no "fiktif" disclaimer
      expect(find.text('Fasilitas kesehatan'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Lokasi belum diketahui'), findsOneWidget);
      expect(find.text('Data contoh'), findsNothing);
      expect(find.textContaining('fiktif'), findsNothing);
      expect(find.text('Klinik Harmoni'), findsNothing);

      // 2. Tap button "Temukan Fasilitas Kesehatan di Sekitar"
      final buttonFinder = find.text('Temukan Fasilitas Kesehatan di Sekitar');
      expect(buttonFinder, findsOneWidget);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // 3. Facilities are now loaded
      expect(find.text('Lokasi belum diketahui'), findsNothing);
      expect(find.text('RSUD Dr. Saiful Anwar (RSSA)'), findsOneWidget);
      expect(find.text('RS Lavalette Malang'), findsOneWidget);
      expect(find.text('Data contoh'), findsNothing);
      expect(find.textContaining('jarak contoh'), findsNothing);

      // 4. Test Maps-like Search with Typo / Similarity (e.g. "saful" for "Saiful")
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'saful');
      await tester.pumpAndSettle();

      expect(find.text('RSUD Dr. Saiful Anwar (RSSA)'), findsOneWidget);
      expect(find.text('RS Lavalette Malang'), findsNothing);

      // 5. Test Acronym search (e.g. "rssa")
      await tester.enterText(searchField, 'rssa');
      await tester.pumpAndSettle();
      expect(find.text('RSUD Dr. Saiful Anwar (RSSA)'), findsOneWidget);
      expect(find.text('RS Lavalette Malang'), findsNothing);

      // 6. Test Address/Area search (e.g. "klojen")
      await tester.enterText(searchField, 'klojen');
      await tester.pumpAndSettle();
      expect(find.text('RSUD Dr. Saiful Anwar (RSSA)'), findsOneWidget);
      expect(find.text('Puskesmas Klojen'), findsOneWidget);

      // 7. Clear search restores full list
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      expect(find.text('RSUD Dr. Saiful Anwar (RSSA)'), findsOneWidget);
      expect(find.text('RS Lavalette Malang'), findsOneWidget);
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
