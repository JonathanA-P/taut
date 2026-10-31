import 'healthcare_facility.dart';

abstract class HealthcareRepository {
  Future<({double latitude, double longitude})> getCurrentLocation();

  Future<List<HealthcareFacility>> searchNearby({
    required double latitude,
    required double longitude,
    double radiusMeters = 10000.0,
  });

  double calculateDistance({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  });

  Future<bool> openDirections({
    required double destinationLat,
    required double destinationLon,
    String? label,
  });
}

