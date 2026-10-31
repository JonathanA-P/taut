import 'healthcare_facility.dart';

/// Integration Contract: Healthcare Repository
/// Owner: Adriel Christo Lumbantoruan (Flutter Frontend & Healthcare Lead)
/// Branch: feature/healthcare-finder
///
/// Responsibilities:
/// - Requesting user GPS location via Geolocator
/// - Querying OpenStreetMap Overpass API within 10 km radius
/// - Normalizing OSM nodes and ways into [HealthcareFacility]
/// - Filtering and sorting facilities by calculated distance
/// - Launching external navigation apps (Google Maps / geo: URI)
abstract class HealthcareRepository {
  /// Fetches current GPS coordinates of the device.
  Future<({double latitude, double longitude})> getCurrentLocation();

  /// Queries healthcare facilities within [radiusMeters] (default: 10,000m / 10km).
  Future<List<HealthcareFacility>> searchNearby({
    required double latitude,
    required double longitude,
    double radiusMeters = 10000.0,
  });

  /// Calculates geodesic distance between two points in meters.
  double calculateDistance({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  });

  /// Opens an external navigation app to the selected coordinates.
  Future<bool> openDirections({
    required double destinationLat,
    required double destinationLon,
    String? label,
  });
}
