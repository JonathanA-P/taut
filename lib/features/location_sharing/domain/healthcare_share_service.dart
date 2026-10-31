abstract class HealthcareShareService {
  String prepareLocationMessage({
    required String facilityName,
    required double latitude,
    required double longitude,
  });

  Future<bool> shareLocationToHealthcare({
    required String facilityName,
    required double latitude,
    required double longitude,
  });
}

