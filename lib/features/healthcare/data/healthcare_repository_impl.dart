import '../../../core/utils/distance_calculator.dart';
import '../domain/healthcare_facility.dart';
import '../domain/healthcare_repository.dart';

class HealthcareRepositoryImpl implements HealthcareRepository {
  const HealthcareRepositoryImpl();

  @override
  Future<({double latitude, double longitude})> getCurrentLocation() async {
    return (latitude: -7.9526, longitude: 112.6144);
  }

  @override
  Future<List<HealthcareFacility>> searchNearby({
    required double latitude,
    required double longitude,
    double radiusMeters = 10000.0,
  }) async {
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
    return false;
  }
}

