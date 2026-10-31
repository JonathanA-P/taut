/// Global constants for the TAUT platform.
/// Standardized routes for all 20 screens and application parameters.
class AppConstants {
  AppConstants._();

  static const String appName = 'TAUT';
  static const String tagline = 'Terhubung tanpa hambatan.';

  // Route Names - 20 Main Screens & Navigation Flow
  static const String routeHome = '/';
  static const String routeSplash = '/splash';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeHomeDashboard = '/dashboard';

  // Communication Pipelines
  static const String routeCommunication = '/communication';
  static const String routeSpeechToText = '/communication/speech-to-text';
  static const String routeMotionToSound = '/communication/motion-to-sound';

  // Location Hub & Healthcare Finder
  static const String routeLocationHub = '/location-hub';
  static const String routeHealthcare = '/healthcare';
  static const String routeHealthcareDetail = '/healthcare/detail';
  static const String routeShareHealthcare = '/healthcare/share-location';
  static const String routeLocationSharing = '/location-sharing'; // Alias for compatibility

  // Friends & Live Sharing
  static const String routeFriends = '/friends';
  static const String routeAddFriend = '/friends/add';
  static const String routeLiveLocation = '/friends/live-location';
  static const String routeManageLocationSharing = '/friends/manage-sharing';

  // Profile & Settings
  static const String routeProfile = '/profile';
  static const String routeEditProfile = '/profile/edit';
  static const String routeSettings = '/settings';
  static const String routePrivacy = '/privacy';

  // Healthcare Tags (OpenStreetMap Overpass)
  static const List<String> healthcareAmenities = [
    'hospital',
    'clinic',
    'doctors',
    'pharmacy',
  ];

  static const double healthcareRadiusKm = 10;
  static const double defaultSearchRadiusMeters = 10000.0;

  static const Duration initialSharingRemaining = Duration(
    minutes: 14,
    seconds: 32,
  );

  static const String demoUserName = 'Jonathan';
  static const String demoFriendName = 'Budi Santoso';
  static const String demoLastLocation = 'Jl. Contoh No. 1, Malang';
  static const String demoInviteCode = 'TAUT-8K2P';

  // BISINDO Confidence Threshold
  static const double defaultGestureConfidenceThreshold = 0.70;
}
