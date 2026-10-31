class LocationShareSession {
  final String id;
  final String ownerId;
  final String recipientId;
  final String? friendDisplayName;
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final DateTime startedAt;
  final DateTime updatedAt;
  final DateTime expiresAt;
  final DateTime? revokedAt;

  const LocationShareSession({
    required this.id,
    required this.ownerId,
    required this.recipientId,
    this.friendDisplayName,
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    required this.startedAt,
    required this.updatedAt,
    required this.expiresAt,
    this.revokedAt,
  });

  bool get isActive {
    if (revokedAt != null) return false;
    return DateTime.now().isBefore(expiresAt);
  }

  factory LocationShareSession.fromJson(Map<String, dynamic> json) {
    return LocationShareSession(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      recipientId: json['recipient_id'] as String,
      friendDisplayName: json['friend_display_name'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracyMeters: (json['accuracy_m'] as num?)?.toDouble(),
      startedAt: DateTime.parse(json['started_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      revokedAt: json['revoked_at'] != null
          ? DateTime.parse(json['revoked_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'owner_id': ownerId,
    'recipient_id': recipientId,
    'latitude': latitude,
    'longitude': longitude,
    'accuracy_m': accuracyMeters,
    'started_at': startedAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'expires_at': expiresAt.toIso8601String(),
    'revoked_at': revokedAt?.toIso8601String(),
  };
}

