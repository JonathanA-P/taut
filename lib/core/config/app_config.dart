import 'env.dart';

/// Centralized configuration provider for TAUT.
class AppConfig {
  AppConfig._();

  static const String appName = 'TAUT';
  static const String appTagline = 'Aksesibilitas & Komunikasi Inklusif';
  static const String appVersion = '1.0.0 (Stage 01 Foundation)';

  static bool get isSupabaseConfigured =>
      Env.supabaseUrl != 'https://placeholder-project.supabase.co' &&
      Env.supabasePublishableKey != 'placeholder-anon-key';

  static String get overpassEndpoint => Env.overpassApiUrl;
  static double get defaultRadiusMeters => Env.defaultHealthcareRadiusMeters;
}
