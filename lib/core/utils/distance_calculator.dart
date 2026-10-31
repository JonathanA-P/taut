import 'dart:math' as math;

/// Utility for geospatial distance calculation.
/// Uses the Haversine formula (Earth radius ~6371 km).
/// Standard library implementation: zero external dependencies.
class DistanceCalculator {
  DistanceCalculator._();

  static const double _earthRadiusMeters = 6371000.0;

  /// Calculates the great-circle distance between two GPS coordinates in meters.
  static double distanceBetweenMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    final dLat = _toRadians(endLatitude - startLatitude);
    final dLon = _toRadians(endLongitude - startLongitude);

    final lat1 = _toRadians(startLatitude);
    final lat2 = _toRadians(endLatitude);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(lat1) *
            math.cos(lat2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return _earthRadiusMeters * c;
  }

  /// Calculates the distance in kilometers.
  static double distanceBetweenKm({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return distanceBetweenMeters(
          startLatitude: startLatitude,
          startLongitude: startLongitude,
          endLatitude: endLatitude,
          endLongitude: endLongitude,
        ) /
        1000.0;
  }

  /// Formats distance in an Indonesian human-readable string (e.g., "450 m" or "2.4 km").
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(1)} km';
  }

  static double _toRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }
}
