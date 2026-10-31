/// Application environment variables and configurations.
/// Centralized config for Supabase, OSM Overpass API, and service parameters.
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

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-anon-key',
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl != 'https://placeholder-project.supabase.co' &&
      supabaseUrl.isNotEmpty &&
      supabasePublishableKey != 'placeholder-anon-key' &&
      supabasePublishableKey.isNotEmpty;

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

/// Backwards compatibility alias for code referencing [EnvConfig].
typedef EnvConfig = Env;
