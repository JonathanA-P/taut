import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';

/// Location Sharing Hub Screen:
/// Explicitly separates:
/// 1. Location Sharing to Healthcare / External Contacts (via Share Sheet, Feature 3)
/// 2. Friend-to-Friend Live Location Sharing (via Supabase Realtime, Feature 4)
class LocationSharingScreen extends StatelessWidget {
  const LocationSharingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Berbagi Lokasi')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StatusBadge.development(),
          ),
          const SizedBox(height: 16),
          // FEATURE 3 SECTION
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.emergency_share_rounded,
                        color: AppColors.secondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alur A: Berbagi ke Faskes / Kontak Luar',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Menggunakan Android Share Sheet (Tanpa database backend)',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Kirimkan tautan Google Maps koordinat Anda ke nomor darurat faskes atau pendamping melalui aplikasi eksternal (WhatsApp, SMS, dll). Konfirmasi data lokasi akan ditampilkan terlebih dahulu.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Uji Pesan Berbagi Lokasi Faskes',
                  icon: Icons.share_location_rounded,
                  isOutlined: true,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Konfirmasi Berbagi Lokasi'),
                        content: const Text(
                          'Lokasi Anda saat ini (-7.9526, 112.6144) akan disiapkan dalam format tautan Google Maps untuk dibagikan melalui Android Share Sheet.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Panggilan share_plus akan diaktifkan pada Tahap 02 oleh Adriel.',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Buka Lembar Berbagi'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // FEATURE 4 SECTION
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.people_alt_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alur B: Berbagi Lokasi Antar Teman Terpercaya',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Menggunakan Supabase Realtime & PostgreSQL RLS',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Berbagi lokasi langsung (foreground live location) dengan teman yang sudah terverifikasi melalui kode undangan. Pemilik lokasi memegang kendali penuh untuk menghentikan sesi kapan saja.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Kelola Teman Terverifikasi',
                  icon: Icons.person_search_rounded,
                  onPressed: () {
                    Navigator.pushNamed(context, AppConstants.routeFriends);
                  },
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Mulai Sesi Berbagi Baru',
                  icon: Icons.broadcast_on_personal_rounded,
                  isOutlined: true,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Sesi Supabase Realtime akan diaktifkan pada Tahap 02 oleh Alfredo.',
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
              'Sesi Berbagi Aktif (0)',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Tidak ada sesi berbagi lokasi yang sedang berjalan.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
