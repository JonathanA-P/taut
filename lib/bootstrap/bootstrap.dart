import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taut/app.dart';
import 'package:taut/core/config/env.dart';

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
    } catch (_) {}
  }
  runApp(const TautApp());
}

