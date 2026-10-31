import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';
import '../core/config/env.dart';

/// Bootstrap orchestrator for TAUT.
/// Ensures system bindings, error zones, and critical services are initialized
/// before the first frame is rendered.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Flutter error catching
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // In production, forward to monitoring service (e.g. Sentry)
  };

  // Initialize Supabase if project URL & anon key are configured
  if (AppConfig.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabasePublishableKey,
      );
      debugPrint('Supabase successfully initialized with: ${Env.supabaseUrl}');
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
    }
  } else {
    debugPrint(
      'TAUT: Menjalankan dalam mode lokal tanpa Supabase. '
      'Isi SUPABASE_URL dan SUPABASE_PUBLISHABLE_KEY di .env untuk menghubungkan.',
    );
  }

  runApp(await builder());
}
