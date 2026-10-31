/// Integration Contract: Healthcare Location Sharing Service (Feature 3)
/// Owner: Adriel Christo Lumbantoruan (Branch: feature/share-location-faskes)
///
/// Responsibilities:
/// - Prepares a structured Indonesian emergency message with coordinates & Google Maps link
/// - Invokes native Android Share Sheet via `share_plus`
/// - Does NOT require database storage for initial MVP
/// - Prompts user with explicit confirmation dialog before invoking share intent
abstract class HealthcareShareService {
  /// Prepares human-readable message with coordinates and maps link.
  String prepareLocationMessage({
    required String facilityName,
    required double latitude,
    required double longitude,
  });

  /// Opens the Android Share Sheet with the prepared location message.
  Future<bool> shareLocationToHealthcare({
    required String facilityName,
    required double latitude,
    required double longitude,
  });
}
