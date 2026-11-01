import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taut/app.dart';
import 'package:taut/core/config/env.dart';
import 'package:taut/shared/models/taut_app_state.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Env.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabasePublishableKey.isNotEmpty
            ? Env.supabasePublishableKey
            : Env.supabaseAnonKey,
      );

      final client = Supabase.instance.client;
      if (client.auth.currentUser != null) {
        TautAppState().setGuestMode(false);
        TautAppState().syncWithBackend();
      }

      client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          TautAppState().setGuestMode(false);
          TautAppState().syncWithBackend();
        }
      });
    } catch (_) {}
  }
  runApp(const TautApp());
}

