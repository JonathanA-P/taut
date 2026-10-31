class HealthcareFacility {
  final String id;
  final String name;
  final String
  category; // e.g. 'Rumah Sakit', 'Klinik', 'Dokter', 'Puskesmas', 'Apotek'
  final String? address;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final bool?
  isWheelchairAccessible; // Only set if explicitly tagged (e.g. wheelchair=yes)

  const HealthcareFacility({
    required this.id,
    required this.name,
    required this.category,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    this.isWheelchairAccessible,
  });

  factory HealthcareFacility.fromOsmJson({
    required Map<String, dynamic> element,
    required double userLat,
    required double userLon,
    required double Function(double, double, double, double) distanceCalculator,
  }) {
    final tags = element['tags'] as Map<String, dynamic>? ?? {};

    final double lat =
        (element['lat'] as num?)?.toDouble() ??
        ((element['center'] as Map<String, dynamic>?)?['lat'] as num?)
            ?.toDouble() ??
        0.0;
    final double lon =
        (element['lon'] as num?)?.toDouble() ??
        ((element['center'] as Map<String, dynamic>?)?['lon'] as num?)
            ?.toDouble() ??
        0.0;

    final amenity = tags['amenity'] as String?;
    final healthcare = tags['healthcare'] as String?;
    String category = 'Fasilitas Kesehatan';

    if (amenity == 'hospital' || healthcare == 'hospital') {
      category = 'Rumah Sakit';
    } else if (amenity == 'clinic' || healthcare == 'clinic') {
      category = 'Klinik';
    } else if (amenity == 'doctors' || healthcare == 'doctor') {
      category = 'Praktik Dokter';
    } else if (amenity == 'pharmacy' || healthcare == 'pharmacy') {
      category = 'Apotek';
    }

    final name =
        tags['name'] as String? ??
        tags['operator'] as String? ??
        '$category (Tanpa Nama Terdaftar)';

    final road = tags['addr:street'] as String?;
    final houseNumber = tags['addr:housenumber'] as String?;
    final city = tags['addr:city'] as String?;
    String? address;
    if (road != null) {
      address = road + (houseNumber != null ? ' No. $houseNumber' : '');
      if (city != null) address += ', $city';
    }

    final wheelchairTag = tags['wheelchair'] as String?;
    final bool? isWheelchair = wheelchairTag == 'yes'
        ? true
        : wheelchairTag == 'no'
        ? false
        : null;

    final distance = distanceCalculator(userLat, userLon, lat, lon);

    return HealthcareFacility(
      id:
          element['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      address: address,
      latitude: lat,
      longitude: lon,
      distanceMeters: distance,
      isWheelchairAccessible: isWheelchair,
    );
  }
}

