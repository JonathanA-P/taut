import 'friendship_model.dart';

abstract class FriendsRepository {
  Future<String> createInvite({required Duration validity});

  Future<FriendshipModel> acceptInvite({required String inviteToken});

  Future<List<FriendshipModel>> getFriends();

  Future<FriendshipStatus> getFriendshipStatus({required String otherUserId});
}

