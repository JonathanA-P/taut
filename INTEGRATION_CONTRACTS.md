# INTEGRATION_CONTRACTS.md — Service Contracts & Team Ownership

This document defines the strict public interfaces, contracts, and type signatures across all four TAUT features.
All three developers (**Alfredo**, **Adriel**, **Roganda**) must implement and consume these exact signatures to guarantee clean parallel integration without code merge clashes.

---

## 1. Ownership & Module Assignment Matrix

| Module | Interface | Primary Developer | Feature Branch | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Authentication** | `AuthRepository` | Alfredo Jonathan Purba | `feature/supabase-auth-friends` | Contract Defined |
| **Friends & Invites** | `FriendsRepository` | Alfredo Jonathan Purba | `feature/supabase-auth-friends` | Contract Defined |
| **Friend Location Sharing**| `LocationSharingRepository` | Alfredo Jonathan Purba | `feature/friend-location-sharing` | Contract Defined |
| **Healthcare Finder** | `HealthcareRepository` | Adriel Christo Lumbantoruan | `feature/healthcare-finder` | Contract Defined |
| **Healthcare Share Sheet** | `HealthcareShareService` | Adriel Christo Lumbantoruan | `feature/share-location-faskes` | Contract Defined |
| **Speech-to-Text** | `SpeechService` | Roganda Tua Tampubolon | `feature/speech-to-text` | Contract Defined |
| **BISINDO Recognition**| `BisindoRecognitionService`| Roganda Tua Tampubolon | `feature/motion-to-sound` | Contract Defined |
| **Text-to-Speech** | `TtsService` | Roganda Tua Tampubolon | `feature/motion-to-sound` | Contract Defined |

---

## 2. Authentication Contract (`AuthRepository`)
*File Location*: `lib/features/auth/domain/auth_repository.dart`  
*Owner*: Alfredo Jonathan Purba

```dart
abstract class AuthRepository {
  /// Signs up a new user and provisions a row in public.profiles.
  /// Throws [AuthException] on failure.
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Signs in an existing user with email and password.
  /// Throws [AuthException] on invalid credentials.
  Future<UserProfile> signIn({
    required String email,
    required String password,
  });

  /// Signs out the user and clears tokens.
  Future<void> signOut();

  /// Retrieves the currently authenticated profile or null.
  Future<UserProfile?> getCurrentUser();

  /// Reactive stream of authentication changes.
  Stream<UserProfile?> authStateChanges();
}
```

---

## 3. Friends & Invites Contract (`FriendsRepository`)
*File Location*: `lib/features/friends/domain/friends_repository.dart`  
*Owner*: Alfredo Jonathan Purba

```dart
abstract class FriendsRepository {
  /// Generates a temporary invitation token (returned as secret, stored as SHA-256 hash).
  Future<String> createInvite({required Duration validity});

  /// Accepts a friend invitation using the provided token string.
  /// Throws [AppException] if expired, self-invite, or already accepted.
  Future<FriendshipModel> acceptInvite({required String inviteToken});

  /// Retrieves all verified friends (status = 'accepted').
  Future<List<FriendshipModel>> getFriends();

  /// Queries friendship status between current user and [otherUserId].
  Future<FriendshipStatus> getFriendshipStatus({required String otherUserId});
}
```

---

## 4. Friend Location Sharing Contract (`LocationSharingRepository`)
*File Location*: `lib/features/location_sharing/domain/location_sharing_repository.dart`  
*Owner*: Alfredo Jonathan Purba

```dart
abstract class LocationSharingRepository {
  /// Creates an active live location session with a verified friend.
  /// Enforces RLS check: are_friends(owner_id, recipient_id).
  Future<LocationShareSession> createShare({
    required String recipientId,
    required Duration duration,
    required double initialLatitude,
    required double initialLongitude,
  });

  /// Updates current GPS coordinates for an active session.
  /// Only the owner can write coordinates (RLS enforced).
  Future<void> updateLocation({
    required String sessionId,
    required double latitude,
    required double longitude,
    double? accuracy,
  });

  /// Subscribes to live location updates via Supabase Realtime channel.
  Stream<LocationShareSession> subscribeLocation({
    required String sessionId,
  });

  /// Revokes an active sharing session immediately.
  Future<void> revokeShare({
    required String sessionId,
  });

  /// Retrieves all active non-expired sessions.
  Future<List<LocationShareSession>> getActiveShares();
}
```

---

## 5. Healthcare Finder Contract (`HealthcareRepository`)
*File Location*: `lib/features/healthcare/domain/healthcare_repository.dart`  
*Owner*: Adriel Christo Lumbantoruan

```dart
abstract class HealthcareRepository {
  /// Obtains current GPS coordinates of the device via Geolocator.
  Future<({double latitude, double longitude})> getCurrentLocation();

  /// Queries healthcare facilities within [radiusMeters] (default 10,000m / 10km)
  /// using OpenStreetMap Overpass API.
  Future<List<HealthcareFacility>> searchNearby({
    required double latitude,
    required double longitude,
    double radiusMeters = 10000.0,
  });

  /// Calculates geodesic distance between two points using Haversine stdlib.
  double calculateDistance({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  });

  /// Launches an external map provider (Google Maps via geo: URI or web URL).
  Future<bool> openDirections({
    required double destinationLat,
    required double destinationLon,
    String? label,
  });
}
```

---

## 6. Healthcare Share Sheet Contract (`HealthcareShareService`)
*File Location*: `lib/features/location_sharing/domain/healthcare_share_service.dart`  
*Owner*: Adriel Christo Lumbantoruan

```dart
abstract class HealthcareShareService {
  /// Formats an emergency sharing message with coordinates and Google Maps link.
  String prepareLocationMessage({
    required String facilityName,
    required double latitude,
    required double longitude,
  });

  /// Invokes Android native Share Sheet (share_plus) for external messaging.
  /// Requires explicit user confirmation dialog beforehand.
  Future<bool> shareLocationToHealthcare({
    required String facilityName,
    required double latitude,
    required double longitude,
  });
}
```

---

## 7. Speech-to-Text Contract (`SpeechService`)
*File Location*: `lib/features/communication/speech_to_text/domain/speech_service.dart`  
*Owner*: Roganda Tua Tampubolon

```dart
abstract class SpeechService {
  /// Initializes speech recognition engine and checks permissions.
  Future<bool> initialize();

  /// Starts listening for Indonesian speech input.
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    String language = 'id-ID',
  });

  /// Stops audio capture and delivers final text.
  Future<void> stopListening();

  /// Cancels listening and discards buffer.
  Future<void> cancelListening();

  /// Whether audio is actively capturing.
  bool get isListening;

  /// Reactive status stream for UI rendering.
  Stream<SpeechRecognitionState> get statusStream;

  void dispose();
}
```

---

## 8. BISINDO Sign Recognition Contract (`BisindoRecognitionService`)
*File Location*: `lib/features/communication/motion_to_sound/domain/bisindo_recognition_service.dart`  
*Owner*: Roganda Tua Tampubolon

```dart
abstract class BisindoRecognitionService {
  /// Loads TFLite model and label index into memory.
  Future<void> initializeModel();

  /// Runs inference against landmark coordinates.
  /// Returns [GestureResult.unknown] if below confidence threshold (0.70).
  Future<GestureResult> recognizeGesture(dynamic frameOrLandmarks);

  /// Lists supported vocabulary tokens for current model weights.
  List<String> getSupportedVocabulary();

  /// Whether the AI engine is loaded and ready.
  bool get isModelLoaded;

  void dispose();
}
```

---

## 9. Text-to-Speech Contract (`TtsService`)
*File Location*: `lib/features/communication/motion_to_sound/domain/tts_service.dart`  
*Owner*: Roganda Tua Tampubolon

```dart
abstract class TtsService {
  /// Initializes Android TTS with Indonesian locale.
  Future<void> initialize({String language = 'id-ID'});

  /// Synthesizes and plays spoken Indonesian audio.
  Future<void> speakText(String text);

  /// Stops current playback.
  Future<void> stopSpeaking();

  /// Whether audio is actively playing.
  bool get isSpeaking;

  void dispose();
}
```
