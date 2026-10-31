import '../../../core/utils/distance_calculator.dart';
import '../domain/healthcare_facility.dart';
import '../domain/healthcare_repository.dart';

/// Foundation implementation of [HealthcareRepository] for Stage 01.
/// Full HTTP requests and Geolocator GPS integration will be completed
/// by Adriel on `feature/healthcare-finder`.
class HealthcareRepositoryImpl implements HealthcareRepository {
  const HealthcareRepositoryImpl();

  @override
  Future<({double latitude, double longitude})> getCurrentLocation() async {
    // Stage 01: Fallback coordinates (Malang / Universitas Brawijaya)
    // -7.9526, 112.6144
    return (latitude: -7.9526, longitude: 112.6144);
  }

  @override
  Future<List<HealthcareFacility>> searchNearby({
    required double latitude,
    required double longitude,
    double radiusMeters = 10000.0,
  }) async {
    // Stage 01 foundation: returns empty list until HTTP Overpass integration
    return const [];
  }

  @override
  double calculateDistance({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) {
    return DistanceCalculator.distanceBetweenMeters(
      startLatitude: startLat,
      startLongitude: startLon,
      endLatitude: endLat,
      endLongitude: endLon,
    );
  }

  @override
  Future<bool> openDirections({
    required double destinationLat,
    required double destinationLon,
    String? label,
  }) async {
    // Will be wired via url_launcher in feature branch
    return false;
  }
}
