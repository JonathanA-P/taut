import '../../../core/errors/app_exception.dart';
import '../domain/friends_repository.dart';
import '../domain/friendship_model.dart';

/// Foundation implementation of [FriendsRepository] for Stage 01.
/// Full implementation with PostgreSQL queries and RLS will be built in Stage 02.
class FriendsRepositoryImpl implements FriendsRepository {
  const FriendsRepositoryImpl();

  @override
  Future<String> createInvite({required Duration validity}) async {
    throw const AppException(
      message:
          'Modul Teman & Undangan belum dihubungkan (Stage 01 Foundation).',
      code: 'FRIENDS_NOT_IMPLEMENTED',
    );
  }

  @override
  Future<FriendshipModel> acceptInvite({required String inviteToken}) async {
    throw const AppException(
      message:
          'Modul Teman & Undangan belum dihubungkan (Stage 01 Foundation).',
      code: 'FRIENDS_NOT_IMPLEMENTED',
    );
  }

  @override
  Future<List<FriendshipModel>> getFriends() async {
    return const [];
  }

  @override
  Future<FriendshipStatus> getFriendshipStatus({
    required String otherUserId,
  }) async {
    return FriendshipStatus.none;
  }
}
