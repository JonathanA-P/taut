class AppConstants {
  AppConstants._();

  static const String appName = 'TAUT';
  static const String tagline = 'Terhubung tanpa hambatan.';

  static const String routeHome = '/home';
  static const String routeSplash = '/splash';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeWelcome = '/welcome';
  static const String routeRegister = '/register';
  static const String routeHomeDashboard = '/dashboard';

  static const String routeCommunication = '/communication';
  static const String routeSpeechToText = '/communication/speech-to-text';
  static const String routeMotionToSound = '/communication/motion-to-sound';

  static const String routeLocationHub = '/location-hub';
  static const String routeHealthcare = '/healthcare';
  static const String routeHealthcareDetail = '/healthcare/detail';
  static const String routeShareHealthcare = '/healthcare/share-location';
  static const String routeLocationSharing = '/location-sharing'; // Alias for compatibility

  static const String routeFriends = '/friends';
  static const String routeAddFriend = '/friends/add';
  static const String routeLiveLocation = '/friends/live-location';
  static const String routeManageLocationSharing = '/friends/manage-sharing';

  static const String routeProfile = '/profile';
  static const String routeEditProfile = '/profile/edit';
  static const String routeSettings = '/settings';
  static const String routePrivacy = '/privacy';

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

  static const double defaultGestureConfidenceThreshold = 0.70;
}

