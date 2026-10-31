import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';

/// Location Hub / Sharing Screen:
/// Explicitly separates the two location sharing pipelines according to TAUT architecture:
/// 1. Berbagi Lokasi ke Faskes / Kontak Darurat (via Android Share Sheet - Feature 3)
/// 2. Berbagi Lokasi Langsung Antar Teman (via Supabase Realtime & RLS - Feature 4)
class LocationSharingScreen extends StatelessWidget {
  const LocationSharingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Berbagi Lokasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        children: [
          Row(
            children: [
              StatusBadge.active(label: 'GPS Siap Terhubung'),
              const Spacer(),
              const Text(
                'Akurasi: ±5m',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Layanan Berbagi Lokasi',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih metode pembagian lokasi sesuai kebutuhan mendesak atau pemantauan harian.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // PIPELINE 1: SHARE TO HEALTHCARE / EMERGENCY (Feature 3)
          AppCard(
            margin: EdgeInsets.zero,
            backgroundColor: AppColors.white,
            borderColor: AppColors.accentStt.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accentSttBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.emergency_share_rounded,
                        color: AppColors.accentStt,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Berbagi ke Faskes Terdekat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          Text(
                            'Lembar Berbagi Android (WhatsApp, SMS, dll)',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Kirimkan tautan Google Maps koordinat GPS Anda langsung ke nomor darurat faskes atau pendamping melalui aplikasi eksternal tanpa membebani database.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Buka Lembar Berbagi Faskes',
                  icon: Icons.share_location_rounded,
                  backgroundColor: AppColors.darkGreen,
                  onPressed: () {
                    Navigator.pushNamed(context, AppConstants.routeShareHealthcare);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // PIPELINE 2: FRIEND-TO-FRIEND LIVE SHARING (Feature 4)
          AppCard(
            margin: EdgeInsets.zero,
            backgroundColor: AppColors.white,
            borderColor: AppColors.accentLocation.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accentLocationBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.people_outline_rounded,
                        color: AppColors.accentLocation,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Berbagi Langsung Antar Teman',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          Text(
                            'Supabase Realtime & Row Level Security',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bagikan pergerakan lokasi secara langsung (live location) kepada teman terpercaya yang telah terhubung melalui kode undangan.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Pantau Lokasi',
                        icon: Icons.map_rounded,
                        backgroundColor: AppColors.primary,
                        onPressed: () {
                          Navigator.pushNamed(context, AppConstants.routeLiveLocation);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        label: 'Kelola Sesi',
                        icon: Icons.tune_rounded,
                        isOutlined: true,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppConstants.routeManageLocationSharing,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // SHORTCUT: HEALTHCARE FINDER LINK
          AppCard(
            margin: EdgeInsets.zero,
            backgroundColor: AppColors.lightGreen,
            borderColor: AppColors.sageGreen,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
              ),
              title: const Text(
                'Cari Fasilitas Kesehatan Terdekat',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              subtitle: const Text(
                'Cari rumah sakit & puskesmas dalam radius 10 km',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
              onTap: () {
                Navigator.pushNamed(context, AppConstants.routeHealthcare);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
