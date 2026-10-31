import '../domain/healthcare_share_service.dart';

/// Foundation implementation of [HealthcareShareService] for Stage 01.
/// Full integration with `share_plus` will be completed by Adriel.
class HealthcareShareServiceImpl implements HealthcareShareService {
  const HealthcareShareServiceImpl();

  @override
  String prepareLocationMessage({
    required String facilityName,
    required double latitude,
    required double longitude,
  }) {
    final mapsUrl = 'https://maps.google.com/?q=$latitude,$longitude';
    return '''[TAUT - Berbagi Lokasi Darurat]
Saya membagikan lokasi terkini untuk rujukan/tujuan ke: $facilityName.
Titik Koordinat: $latitude, $longitude
Tautan Peta: $mapsUrl

Pesan ini dikirimkan melalui aplikasi aksesibilitas TAUT.''';
  }

  @override
  Future<bool> shareLocationToHealthcare({
    required String facilityName,
    required double latitude,
    required double longitude,
  }) async {
    // Stage 01 foundation: returns false until share_plus invocation
    return false;
  }
}
