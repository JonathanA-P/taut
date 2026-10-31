import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../healthcare/domain/healthcare_facility.dart';

class ShareLocationToHealthcareScreen extends StatelessWidget {
  final HealthcareFacility? targetFacility;

  const ShareLocationToHealthcareScreen({super.key, this.targetFacility});

  @override
  Widget build(BuildContext context) {
    const userLat = -7.9526;
    const userLon = 112.6144;
    final mapsUrl = 'https://maps.google.com/?q=$userLat,$userLon';
    final facilityName = targetFacility?.name ?? 'Fasilitas Kesehatan Terdekat';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Bagi Lokasi ke Faskes'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: StatusBadge.active(label: 'Android Share Sheet - Siap Kirim'),
            ),
            const SizedBox(height: 20),
            Text(
              'Konfirmasi Berbagi Lokasi',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tautan Google Maps koordinat GPS Anda akan disiapkan untuk dikirim melalui aplikasi eksternal (WhatsApp, SMS, atau kontak darurat).',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),

            AppCard(
              margin: EdgeInsets.zero,
              backgroundColor: AppColors.lightGreen,
              borderColor: AppColors.sageGreen,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      color: AppColors.primaryGreen,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tujuan Pembagian Lokasi',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          facilityName,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            AppCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Koordinat GPS Anda',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.lightGreen),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.gps_fixed_rounded, color: AppColors.primary, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Titik Koordinat Geospasial',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Latitude: -7.952600\nLongitude: 112.614400',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            color: AppColors.darkGreen,
                            height: 1.4,
                          ),
                        ),
                        const Divider(color: AppColors.lightGreen, height: 16),
                        const Text(
                          'Tautan Google Maps Publik:',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          mapsUrl,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.privacy_tip_outlined, color: AppColors.primaryGreen, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Privasi Terjaga: Lokasi ini tidak disimpan di server Supabase, murni dikirim via Android Share Sheet.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            AppButton(
              label: 'Buka Lembar Berbagi Android',
              icon: Icons.share_rounded,
              backgroundColor: AppColors.darkGreen,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Membuka Android Share Sheet dengan tautan lokasi Google Maps...',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Kembali',
              isOutlined: true,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

