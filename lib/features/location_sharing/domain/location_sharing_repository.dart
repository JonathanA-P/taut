import 'location_share_session.dart';

abstract class LocationSharingRepository {
  Future<LocationShareSession> createShare({
    required String recipientId,
    required Duration duration,
    required double initialLatitude,
    required double initialLongitude,
  });

  Future<void> updateLocation({
    required String sessionId,
    required double latitude,
    required double longitude,
    double? accuracy,
  });

  Stream<LocationShareSession> subscribeLocation({required String sessionId});

  Future<void> revokeShare({required String sessionId});

  Future<List<LocationShareSession>> getActiveShares();
}

