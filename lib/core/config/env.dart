/// Application environment variables and configurations.
/// Fallback values are provided to ensure the app compiles and runs in development
/// without requiring a live Supabase instance or private environment files.
class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder-project.supabase.co',
  );

  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'placeholder-anon-key',
  );

  static const String overpassApiUrl = String.fromEnvironment(
    'OVERPASS_API_URL',
    defaultValue: 'https://overpass-api.de/api/interpreter',
  );

  static const int overpassTimeoutSeconds = int.fromEnvironment(
    'OVERPASS_TIMEOUT_SECONDS',
    defaultValue: 15,
  );

  static const double defaultHealthcareRadiusMeters = 10000.0; // 10 km
  static const int locationUpdateIntervalSeconds = 10;
}
