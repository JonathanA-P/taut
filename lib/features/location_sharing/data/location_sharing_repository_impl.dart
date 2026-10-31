import 'dart:async';

import '../../../core/errors/app_exception.dart';
import '../domain/location_share_session.dart';
import '../domain/location_sharing_repository.dart';

/// Foundation implementation of [LocationSharingRepository] for Stage 01.
/// Full Supabase Realtime & PostgreSQL RLS client will be implemented by Alfredo.
class LocationSharingRepositoryImpl implements LocationSharingRepository {
  LocationSharingRepositoryImpl();

  @override
  Future<LocationShareSession> createShare({
    required String recipientId,
    required Duration duration,
    required double initialLatitude,
    required double initialLongitude,
  }) async {
    throw const AppException(
      message: 'Modul Berbagi Lokasi Teman belum dihubungkan ke Supabase (Stage 01 Foundation).',
      code: 'LOCATION_SHARING_NOT_IMPLEMENTED',
    );
  }

  @override
  Future<void> updateLocation({
    required String sessionId,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    // Stage 01 placeholder
  }

  @override
  Stream<LocationShareSession> subscribeLocation({required String sessionId}) {
    // Returns empty stream for Stage 01
    return const Stream.empty();
  }

  @override
  Future<void> revokeShare({required String sessionId}) async {
    // Stage 01 placeholder
  }

  @override
  Future<List<LocationShareSession>> getActiveShares() async {
    return const [];
  }
}
