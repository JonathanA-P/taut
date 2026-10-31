/// Service responsible for constructing OpenStreetMap Overpass QL queries.
/// Designed for reliable querying of hospitals, clinics, and doctors within a radius.
class OsmOverpassService {
  final String endpoint;
  final int timeoutSeconds;

  const OsmOverpassService({
    this.endpoint = 'https://overpass-api.de/api/interpreter',
    this.timeoutSeconds = 15,
  });

  /// Builds a sanitized Overpass QL query string for healthcare amenities.
  String buildHealthcareQuery({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) {
    return '''
[out:json][timeout:$timeoutSeconds];
(
  node["amenity"~"hospital|clinic|doctors|pharmacy"](around:$radiusMeters,$latitude,$longitude);
  way["amenity"~"hospital|clinic|doctors|pharmacy"](around:$radiusMeters,$latitude,$longitude);
  node["healthcare"~"hospital|clinic|doctor|pharmacy"](around:$radiusMeters,$latitude,$longitude);
  way["healthcare"~"hospital|clinic|doctor|pharmacy"](around:$radiusMeters,$latitude,$longitude);
);
out center;
''';
  }
}
