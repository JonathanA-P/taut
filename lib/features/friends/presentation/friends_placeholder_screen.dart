import 'package:flutter/material.dart';

import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';

class FriendsPlaceholderScreen extends StatelessWidget {
  const FriendsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Teman & Undangan')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StatusBadge.development(),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Teman Terpercaya',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Undang teman menggunakan kode undangan unik atau QR Code. Hanya teman yang disetujui yang dapat saling berbagi lokasi secara langsung.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Buat Kode Undangan Baru',
                  icon: Icons.qr_code_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Pembuatan token undangan SHA-256 akan diaktifkan pada Stage 02.',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Pindai / Masukkan Kode Teman',
                  icon: Icons.person_add_alt_1_rounded,
                  isOutlined: true,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Penerimaan undangan teman akan diaktifkan pada Stage 02.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Daftar Teman Aktif (0)',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Belum ada teman terhubung.\nKoneksi Supabase akan diintegrasikan oleh Alfredo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

