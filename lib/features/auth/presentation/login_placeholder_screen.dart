import 'package:flutter/material.dart';

import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/status_badge.dart';

class LoginPlaceholderScreen extends StatelessWidget {
  const LoginPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masuk / Daftar Akun')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Center(child: StatusBadge.development()),
            const SizedBox(height: 24),
            Text(
              'Otentikasi Akun TAUT',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Fitur otentikasi menggunakan Supabase Auth dengan Row Level Security (RLS) PostgreSQL untuk mengamankan data pengguna dan sesi berbagi lokasi.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Alamat Email',
                hintText: 'nama@email.com',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Kata Sandi',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              enabled: false,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Masuk (Tahap 02)',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Modul Supabase Auth dijadwalkan pada Sprint 2 oleh Alfredo.',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Daftar Akun Baru',
              isOutlined: true,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Registrasi akun akan tersedia setelah migrasi Supabase aktif.',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

