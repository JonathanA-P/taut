import '../domain/healthcare_share_service.dart';

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
    return false;
  }
}

