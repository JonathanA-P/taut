import 'dart:math' as math;

/// Koordinat geografis sederhana (lintang & bujur dalam derajat).
///
/// Sengaja TIDAK memakai tipe dari package peta/geolocator di sini,
/// supaya model domain TAUT tidak bergantung pada satu package.
/// Konversi ke tipe package dilakukan di layer data nanti.
class LatLng {
  const LatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  /// Jarak garis lurus ke titik lain, dalam kilometer (rumus haversine).
  ///
  /// Dipakai untuk mengurutkan faskes dari yang terdekat, dan untuk
  /// memeriksa radius 10 km. Ini jarak garis lurus, bukan jarak rute
  /// jalan — petunjuk arah tetap dibuka lewat aplikasi peta.
  double distanceKmTo(LatLng other) {
    const earthRadiusKm = 6371.0;
    final lat1 = latitude * math.pi / 180;
    final lat2 = other.latitude * math.pi / 180;
    final dLat = lat2 - lat1;
    final dLng = (other.longitude - longitude) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return 2 * earthRadiusKm * math.asin(math.sqrt(a));
  }

  @override
  bool operator ==(Object other) =>
      other is LatLng &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}
