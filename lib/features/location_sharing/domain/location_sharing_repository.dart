import 'location_share_session.dart';

/// Integration Contract: Friend-to-Friend Location Sharing Repository (Feature 4)
/// Owner: Alfredo Jonathan Purba (Team Lead & Backend Architect)
/// Branch: feature/friend-location-sharing
///
/// Responsibilities:
/// - Creating temporary, authorized location sessions in Supabase PostgreSQL
/// - Writing foreground GPS location updates under RLS owner policies
/// - Subscribing to Supabase Realtime Postgres Changes for live updates
/// - Enforcing explicit revocation and session expiry
abstract class LocationSharingRepository {
  /// Initiates a new location sharing session with an accepted friend.
  Future<LocationShareSession> createShare({
    required String recipientId,
    required Duration duration,
    required double initialLatitude,
    required double initialLongitude,
  });

  /// Updates the owner's current GPS position for an active session.
  Future<void> updateLocation({
    required String sessionId,
    required double latitude,
    required double longitude,
    double? accuracy,
  });

  /// Subscribes to live location updates from a friend via Supabase Realtime.
  Stream<LocationShareSession> subscribeLocation({required String sessionId});

  /// Revokes an active sharing session immediately.
  Future<void> revokeShare({required String sessionId});

  /// Retrieves all currently active sessions (either as owner or recipient).
  Future<List<LocationShareSession>> getActiveShares();
}
