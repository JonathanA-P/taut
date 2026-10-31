import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/errors/app_exception.dart';
import '../domain/friends_repository.dart';
import '../domain/friendship_model.dart';

/// Production implementation of [FriendsRepository] with cryptographic token hashing (SHA-256)
/// and PostgreSQL RLS security verification.
/// Feature Owner: Alfredo Jonathan Purba (Team Lead & Backend Architect)
class FriendsRepositoryImpl implements FriendsRepository {
  final sb.SupabaseClient? _customClient;

  FriendsRepositoryImpl({sb.SupabaseClient? client}) : _customClient = client;

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
  Future<String> createInvite({required Duration validity}) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw const AppException(
        message:
            'Pengguna harus masuk akun terlebih dahulu untuk membuat undangan.',
        code: 'UNAUTHENTICATED',
      );
    }

    try {
      // 1. Generate human-readable secure token: "TAUT-" + 6 uppercase chars
      final rawToken = _generateRandomToken();
      final hashedToken = _hashToken(rawToken);
      final expiresAt = DateTime.now().toUtc().add(validity);

      // 2. Persist ONLY the hash in public.friend_invites
      await _client.from('friend_invites').insert({
        'inviter_id': currentUserId,
        'token_hash': hashedToken,
        'expires_at': expiresAt.toIso8601String(),
      });

      // 3. Return plaintext token to inviter (for QR code or sharing link)
      return rawToken;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Gagal membuat kode undangan: $e');
    }
  }

  @override
  Future<FriendshipModel> acceptInvite({required String inviteToken}) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw const AppException(
        message: 'Pengguna harus masuk akun untuk menerima undangan teman.',
        code: 'UNAUTHENTICATED',
      );
    }

    try {
      final hashed = _hashToken(inviteToken);

      // 1. Find active non-expired invite by token hash
      final invite = await _client
          .from('friend_invites')
          .select()
          .eq('token_hash', hashed)
          .maybeSingle();

      if (invite == null) {
        throw const AppException(
          message: 'Kode undangan tidak valid atau tidak ditemukan.',
          code: 'INVITE_NOT_FOUND',
        );
      }

      final inviterId = invite['inviter_id'] as String;
      final expiresAt = DateTime.parse(invite['expires_at'] as String);
      final acceptedAt = invite['accepted_at'];

      if (acceptedAt != null || DateTime.now().toUtc().isAfter(expiresAt)) {
        throw const AppException(
          message: 'Kode undangan ini sudah digunakan atau telah kedaluwarsa.',
          code: 'INVITE_EXPIRED',
        );
      }

      if (inviterId == currentUserId) {
        throw const AppException(
          message: 'Anda tidak dapat menerima kode undangan dari akun sendiri.',
          code: 'SELF_INVITE_FORBIDDEN',
        );
      }

      // 2. Mark invite as accepted
      await _client
          .from('friend_invites')
          .update({
            'accepted_by': currentUserId,
            'accepted_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', invite['id']);

      // 3. Create or update friendship relation to 'accepted'
      // Symmetrical pair constraint handled by PostgreSQL index
      final existing = await _client
          .from('friendships')
          .select()
          .or(
            'and(requester_id.eq.$inviterId,addressee_id.eq.$currentUserId),'
            'and(requester_id.eq.$currentUserId,addressee_id.eq.$inviterId)',
          )
          .maybeSingle();

      Map<String, dynamic> friendshipRow;
      if (existing != null) {
        friendshipRow = await _client
            .from('friendships')
            .update({'status': 'accepted'})
            .eq('id', existing['id'])
            .select()
            .single();
      } else {
        friendshipRow = await _client
            .from('friendships')
            .insert({
              'requester_id': inviterId,
              'addressee_id': currentUserId,
              'status': 'accepted',
            })
            .select()
            .single();
      }

      // 4. Fetch inviter's display name
      final inviterProfile = await _client
          .from('profiles')
          .select('display_name')
          .eq('id', inviterId)
          .maybeSingle();

      return FriendshipModel(
        id: friendshipRow['id'] as String,
        requesterId: friendshipRow['requester_id'] as String,
        addresseeId: friendshipRow['addressee_id'] as String,
        friendDisplayName: inviterProfile?['display_name'] as String?,
        status: FriendshipStatus.accepted,
        createdAt: DateTime.parse(friendshipRow['created_at'] as String),
        updatedAt: DateTime.parse(friendshipRow['updated_at'] as String),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Gagal menerima undangan teman: $e');
    }
  }

  @override
  Future<List<FriendshipModel>> getFriends() async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return [];

    try {
      final rows = await _client
          .from('friendships')
          .select()
          .eq('status', 'accepted')
          .or('requester_id.eq.$currentUserId,addressee_id.eq.$currentUserId');

      if (rows.isEmpty) return [];

      // Collect other user IDs
      final otherUserIds = <String>{};
      for (final row in rows) {
        final req = row['requester_id'] as String;
        final add = row['addressee_id'] as String;
        otherUserIds.add(req == currentUserId ? add : req);
      }

      // Fetch profiles of friends
      final profilesRes = await _client
          .from('profiles')
          .select('id, display_name')
          .filter('id', 'in', otherUserIds.toList());

      final nameMap = <String, String>{};
      for (final p in profilesRes) {
        nameMap[p['id'] as String] = p['display_name'] as String;
      }

      return rows.map<FriendshipModel>((row) {
        final req = row['requester_id'] as String;
        final add = row['addressee_id'] as String;
        final friendId = req == currentUserId ? add : req;

        return FriendshipModel(
          id: row['id'] as String,
          requesterId: req,
          addresseeId: add,
          friendDisplayName: nameMap[friendId] ?? 'Teman TAUT',
          status: FriendshipStatus.accepted,
          createdAt: DateTime.parse(row['created_at'] as String),
          updatedAt: DateTime.parse(row['updated_at'] as String),
        );
      }).toList();
    } catch (e) {
      throw AppException(message: 'Gagal mengambil daftar teman: $e');
    }
  }

  @override
  Future<FriendshipStatus> getFriendshipStatus({
    required String otherUserId,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return FriendshipStatus.none;

    try {
      final row = await _client
          .from('friendships')
          .select('status')
          .or(
            'and(requester_id.eq.$currentUserId,addressee_id.eq.$otherUserId),'
            'and(requester_id.eq.$otherUserId,addressee_id.eq.$currentUserId)',
          )
          .maybeSingle();

      if (row == null) return FriendshipStatus.none;

      final statusStr = row['status'] as String;
      return FriendshipStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => FriendshipStatus.none,
      );
    } catch (e) {
      return FriendshipStatus.none;
    }
  }

  String _generateRandomToken() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    final buffer = StringBuffer('TAUT-');
    for (var i = 0; i < 6; i++) {
      buffer.write(chars[rand.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  String _hashToken(String token) {
    final cleaned = token.replaceAll('-', '').trim().toUpperCase();
    return sha256.convert(utf8.encode(cleaned)).toString();
  }
}
