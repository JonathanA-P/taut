/// Global constants for the TAUT platform.
class AppConstants {
  AppConstants._();

  // Route Names
  static const String routeHome = '/';
  static const String routeCommunication = '/communication';
  static const String routeSpeechToText = '/communication/speech-to-text';
  static const String routeMotionToSound = '/communication/motion-to-sound';
  static const String routeHealthcare = '/healthcare';
  static const String routeLocationSharing = '/location-sharing';
  static const String routeFriends = '/friends';
  static const String routeProfile = '/profile';
  static const String routePrivacy = '/privacy';

  // Healthcare Tags (OpenStreetMap Overpass)
  static const List<String> healthcareAmenities = [
    'hospital',
    'clinic',
    'doctors',
    'pharmacy',
  ];

  // Default Search Radius
  static const double defaultSearchRadiusMeters = 10000.0;

  // BISINDO Confidence Threshold
  static const double defaultGestureConfidenceThreshold = 0.70;
}
