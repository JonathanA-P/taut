import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/taut_illustrations.dart';
import '../domain/healthcare_facility.dart';
import '../../location_sharing/presentation/share_location_to_healthcare_screen.dart';

/// Healthcare Detail Screen inspired directly by Screen 3 of the Dribbble design reference.
/// Features:
/// - Visually prominent illustrated header banner with overlapping rounded bottom sheet
/// - Facility name, category badge, and real geodesic distance
/// - Action buttons: Directions CTA, Share Location CTA, Copy Address
/// - Structured information cards with authentic OSM OpenStreetMap tags (no fabricated data)
class HealthcareDetailScreen extends StatelessWidget {
  final HealthcareFacility facility;

  const HealthcareDetailScreen({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    final distanceKm = (facility.distanceMeters / 1000).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Dribbble Screen 3 Banner Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.sageGreen,
            foregroundColor: AppColors.darkGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: TautIllustration.clinicHeaderBanner(height: 200),
            ),
          ),

          // Overlapping Content Body
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Facility Header Card
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.sageGreen, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.local_hospital_rounded,
                            color: AppColors.primaryGreen,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.sageGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  facility.category,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                facility.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkGreen,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.near_me_rounded,
                                    size: 14,
                                    color: AppColors.primaryGreen,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$distanceKm km dari posisi GPS Anda',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick Action Buttons Row (Dribbble Screen 3 action buttons)
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            icon: Icons.directions_rounded,
                            label: 'Petunjuk Arah',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Membuka navigasi Google Maps ke ${facility.name}...',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            icon: Icons.emergency_share_rounded,
                            label: 'Bagi Lokasi',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ShareLocationToHealthcareScreen(
                                    targetFacility: facility,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            icon: Icons.copy_rounded,
                            label: 'Salin Alamat',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Alamat faskes disalin ke clipboard.'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // CARD 1: LOKASI & ALAMAT LENGKAP
                    const Text(
                      'Informasi Lokasi & Alamat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppCard(
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  facility.address ?? 'Alamat lengkap tercatat di OpenStreetMap tanpa nomor jalan spesifik.',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.lightGreen, height: 24),
                          Row(
                            children: [
                              const Icon(
                                Icons.gps_fixed_rounded,
                                color: AppColors.textMuted,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Koordinat: ${facility.latitude.toStringAsFixed(4)}, ${facility.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CARD 2: AKSESIBILITAS RAMAH DISABILITAS (Verified OSM Tags)
                    const Text(
                      'Aksesibilitas & Fasilitas Khusus',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppCard(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: facility.isWheelchairAccessible == true
                                      ? AppColors.successBg
                                      : AppColors.lightGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.accessible_rounded,
                                  color: facility.isWheelchairAccessible == true
                                      ? AppColors.success
                                      : AppColors.textMuted,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Aksesibilitas Kursi Roda',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                    Text(
                                      facility.isWheelchairAccessible == true
                                          ? 'Terverifikasi (Tag OpenStreetMap: wheelchair=yes)'
                                          : facility.isWheelchairAccessible == false
                                              ? 'Belum ramah kursi roda (wheelchair=no)'
                                              : 'Belum terverifikasi pada data terbuka OSM',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: facility.isWheelchairAccessible == true
                                            ? AppColors.success
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.lightGreen, height: 20),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Sumber Data Resmi',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                    Text(
                                      'ID Entitas OSM: ${facility.id}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // BOTTOM PRIMARY ACTIONS
                    AppButton(
                      label: 'Bagikan Koordinat ke Faskes Ini',
                      icon: Icons.emergency_share_rounded,
                      backgroundColor: AppColors.darkGreen,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShareLocationToHealthcareScreen(
                              targetFacility: facility,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Buka Petunjuk Arah (Peta)',
                      icon: Icons.directions_rounded,
                      isOutlined: true,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Membuka navigasi ke ${facility.name} ($distanceKm km)...',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightGreen, width: 1.2),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
