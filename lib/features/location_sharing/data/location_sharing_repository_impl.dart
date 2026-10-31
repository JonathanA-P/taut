import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/errors/app_exception.dart';
import '../domain/location_share_session.dart';
import '../domain/location_sharing_repository.dart';

/// Production implementation of [LocationSharingRepository] powered by
/// Supabase PostgreSQL (RLS) and Supabase Realtime WebSocket streaming.
/// Feature Owner: Alfredo Jonathan Purba (Team Lead & Backend Architect)
class LocationSharingRepositoryImpl implements LocationSharingRepository {
  final sb.SupabaseClient? _customClient;

  LocationSharingRepositoryImpl({sb.SupabaseClient? client})
    : _customClient = client;

  sb.SupabaseClient get _client {
    final custom = _customClient;
    if (custom != null) return custom;
    try {
      return sb.Supabase.instance.client;
    } catch (_) {
      throw const AppException(
        message: 'Koneksi Supabase belum diinisialisasi.',
        code: 'UNINITIALIZED_CLIENT',
      );
    }
  }

  @override
  Future<LocationShareSession> createShare({
    required String recipientId,
    required Duration duration,
    required double initialLatitude,
    required double initialLongitude,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw const AppException(
        message: 'Pengguna harus masuk akun untuk membagikan lokasi.',
        code: 'UNAUTHENTICATED',
      );
    }

    if (currentUserId == recipientId) {
      throw const AppException(
        message: 'Anda tidak dapat membagikan lokasi dengan akun sendiri.',
        code: 'SELF_SHARING_FORBIDDEN',
      );
    }

    try {
      final now = DateTime.now().toUtc();
      final expiresAt = now.add(duration);

      final row = await _client
          .from('location_shares')
          .insert({
            'owner_id': currentUserId,
            'recipient_id': recipientId,
            'latitude': initialLatitude,
            'longitude': initialLongitude,
            'started_at': now.toIso8601String(),
            'expires_at': expiresAt.toIso8601String(),
          })
          .select()
          .single();

      // Fetch recipient display name
      final profile = await _client
          .from('profiles')
          .select('display_name')
          .eq('id', recipientId)
          .maybeSingle();

      return LocationShareSession(
        id: row['id'] as String,
        ownerId: row['owner_id'] as String,
        recipientId: row['recipient_id'] as String,
        friendDisplayName: profile?['display_name'] as String?,
        latitude: (row['latitude'] as num).toDouble(),
        longitude: (row['longitude'] as num).toDouble(),
        accuracyMeters: (row['accuracy_m'] as num?)?.toDouble(),
        startedAt: DateTime.parse(row['started_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
        expiresAt: DateTime.parse(row['expires_at'] as String),
        revokedAt: row['revoked_at'] != null
            ? DateTime.parse(row['revoked_at'] as String)
            : null,
      );
    } on sb.PostgrestException catch (e) {
      if (e.message.contains('violates row-level security policy') ||
          e.message.contains('are_friends')) {
        throw const AppException(
          message: 'Gagal membagikan lokasi: Hanya dapat membagikan ke teman yang sudah terverifikasi.',
          code: 'FRIENDSHIP_NOT_VERIFIED',
        );
      }
      throw AppException(
        message: 'Gagal membuat sesi berbagi lokasi: ${e.message}',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Terjadi kendala saat membagikan lokasi: $e');
    }
  }

  @override
  Future<void> updateLocation({
    required String sessionId,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return;

    try {
      final updateData = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      if (accuracy != null) {
        updateData['accuracy_m'] = accuracy;
      }

      // RLS policy strictly guarantees only the owner can update coordinates
      await _client
          .from('location_shares')
          .update(updateData)
          .eq('id', sessionId)
          .eq('owner_id', currentUserId);
    } catch (e) {
      throw AppException(message: 'Gagal memperbarui titik lokasi: $e');
    }
  }

  @override
  Stream<LocationShareSession> subscribeLocation({required String sessionId}) {
    try {
      // Idiomatic Supabase Realtime Postgres Changes stream
      return _client
          .from('location_shares')
          .stream(primaryKey: ['id'])
          .eq('id', sessionId)
          .map((rows) {
            if (rows.isEmpty) {
              throw const AppException(
                message: 'Sesi berbagi lokasi telah berakhir atau dicabut.',
                code: 'SESSION_TERMINATED',
              );
            }
            final row = rows.first;
            return LocationShareSession.fromJson(row);
          });
    } catch (e) {
      throw AppException(
        message: 'Gagal terhubung ke stream lokasi realtime: $e',
      );
    }
  }

  @override
  Future<void> revokeShare({required String sessionId}) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return;

    try {
      await _client
          .from('location_shares')
          .update({'revoked_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', sessionId)
          .eq('owner_id', currentUserId);
    } catch (e) {
      throw AppException(message: 'Gagal mencabut izin berbagi lokasi: $e');
    }
  }

  @override
  Future<List<LocationShareSession>> getActiveShares() async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return [];

    try {
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final rows = await _client
          .from('location_shares')
          .select()
          .isFilter('revoked_at', null)
          .gt('expires_at', nowIso)
          .or('owner_id.eq.$currentUserId,recipient_id.eq.$currentUserId');

      if (rows.isEmpty) return [];

      // Collect other user IDs for display name enrichment
      final otherUserIds = <String>{};
      for (final row in rows) {
        final owner = row['owner_id'] as String;
        final recipient = row['recipient_id'] as String;
        otherUserIds.add(owner == currentUserId ? recipient : owner);
      }

      final profilesRes = await _client
          .from('profiles')
          .select('id, display_name')
          .filter('id', 'in', otherUserIds.toList());

      final nameMap = <String, String>{};
      for (final p in profilesRes) {
        nameMap[p['id'] as String] = p['display_name'] as String;
      }

      return rows.map<LocationShareSession>((row) {
        final owner = row['owner_id'] as String;
        final recipient = row['recipient_id'] as String;
        final friendId = owner == currentUserId ? recipient : owner;

        return LocationShareSession(
          id: row['id'] as String,
          ownerId: owner,
          recipientId: recipient,
          friendDisplayName: nameMap[friendId] ?? 'Teman TAUT',
          latitude: (row['latitude'] as num).toDouble(),
          longitude: (row['longitude'] as num).toDouble(),
          accuracyMeters: (row['accuracy_m'] as num?)?.toDouble(),
          startedAt: DateTime.parse(row['started_at'] as String),
          updatedAt: DateTime.parse(row['updated_at'] as String),
          expiresAt: DateTime.parse(row['expires_at'] as String),
          revokedAt: row['revoked_at'] != null
              ? DateTime.parse(row['revoked_at'] as String)
              : null,
        );
      }).toList();
    } catch (e) {
      throw AppException(message: 'Gagal memuat sesi berbagi lokasi: $e');
    }
  }
}
