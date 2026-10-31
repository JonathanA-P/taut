import 'friendship_model.dart';

/// Integration Contract: Friends & Invitations Repository
/// Owner: Alfredo Jonathan Purba (Team Lead & Backend Architect)
///
/// Responsibilities:
/// - Creating cryptographic token invitations
/// - Accepting friend requests via QR code or invite link
/// - Managing bi-directional friendship states (pending, accepted, blocked)
/// - Querying verified friends list
abstract class FriendsRepository {
  /// Generates a new invitation token valid for the specified duration.
  Future<String> createInvite({required Duration validity});

  /// Accepts a friend invitation using the shared token.
  Future<FriendshipModel> acceptInvite({required String inviteToken});

  /// Lists all accepted friends for the currently authenticated user.
  Future<List<FriendshipModel>> getFriends();

  /// Gets the current friendship relation status with another user.
  Future<FriendshipStatus> getFriendshipStatus({required String otherUserId});
}
