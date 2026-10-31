enum FriendshipStatus { pending, accepted, rejected, blocked, none }

/// Representation of a bi-directional friendship relation.
class FriendshipModel {
  final String id;
  final String requesterId;
  final String addresseeId;
  final String? friendDisplayName;
  final FriendshipStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FriendshipModel({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    this.friendDisplayName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FriendshipModel.fromJson(Map<String, dynamic> json) {
    return FriendshipModel(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      addresseeId: json['addressee_id'] as String,
      friendDisplayName: json['friend_display_name'] as String?,
      status: FriendshipStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String),
        orElse: () => FriendshipStatus.none,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'requester_id': requesterId,
    'addressee_id': addresseeId,
    'status': status.name,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
