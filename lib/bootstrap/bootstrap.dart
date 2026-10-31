import 'package:flutter/material.dart';
import 'package:taut/app.dart';

/// Bootstrap aplikasi.
///
/// Tahap ini (Stage 01) hanya menyiapkan binding Flutter lalu menjalankan
/// [TautApp]. Saat Supabase dihubungkan nanti, inisialisasinya ditambahkan
/// DI SINI (sebelum runApp), memakai [EnvConfig] dari
/// `core/config/env_config.dart` — jangan pernah hardcode URL/key di kode.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TautApp());
}
