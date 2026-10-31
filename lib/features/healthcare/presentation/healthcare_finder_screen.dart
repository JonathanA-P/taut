import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';

/// Healthcare Finder Screen: Searches nearby healthcare facilities within 10 km.
/// Feature Owner: Adriel Christo Lumbantoruan (Branch: feature/healthcare-finder).
class HealthcareFinderScreen extends StatefulWidget {
  const HealthcareFinderScreen({super.key});

  @override
  State<HealthcareFinderScreen> createState() => _HealthcareFinderScreenState();
}

class _HealthcareFinderScreenState extends State<HealthcareFinderScreen> {
  bool _isLoading = false;

  void _searchNearby() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pencarian Overpass API OpenStreetMap dijadwalkan pada Tahap 02 oleh Adriel.',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fasilitas Kesehatan Terdekat')),
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
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Radius Pencarian: 10 Kilometer',
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Mencari rumah sakit, klinik, dan puskesmas terdekat menggunakan OpenStreetMap Overpass API berdasarkan titik koordinat GPS pengguna.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Cari Fasilitas Kesehatan Terdekat',
                  icon: Icons.search_rounded,
                  isLoading: _isLoading,
                  onPressed: _searchNearby,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Fasilitas (Radius 10 km)',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Text(
                  '0 Ditemukan',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.local_hospital_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada data fasilitas kesehatan yang dimuat.\nIntegrasi OpenStreetMap Overpass API akan diimplementasikan pada Tahap 02.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
