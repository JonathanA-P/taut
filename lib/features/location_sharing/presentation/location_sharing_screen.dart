import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/taut_app_state.dart';
import '../../friends/presentation/friends_list_screen.dart';
import '../../friends/presentation/manage_location_sharing_screen.dart';
import '../../healthcare/presentation/healthcare_finder_screen.dart';

/// Location Sharing / Ruang Lokasi Screen strictly implementing the TAUT HTML prototype:
/// - Screen title: "Ruang lokasi"
/// - Hero card: "DEKAT DENGAN YANG BERARTI / Ke mana pun, tetap terhubung."
/// - 3 Feature Destinations:
///   1. Fasilitas kesehatan ("Cari klinik dan rumah sakit")
///   2. Teman terhubung ("X teman contoh")
///   3. Berbagi lokasi ("X sesi demo aktif")
/// - Notice: "Tidak ada pelacakan latar belakang. Berbagi selalu dimulai dan dihentikan olehmu."
class LocationSharingScreen extends StatelessWidget {
  const LocationSharingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = TautAppState();

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.darkGreen,
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            title: const Text(
              'Ruang lokasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Card (Sage Green)
                  _buildHeroCard(),
                  const SizedBox(height: 24),

                  // 3 Feature Buttons Stack
                  _buildListButton(
                    context: context,
                    icon: Icons.local_hospital_rounded,
                    title: 'Fasilitas kesehatan',
                    subtitle: 'Cari klinik dan rumah sakit',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HealthcareFinderScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildListButton(
                    context: context,
                    icon: Icons.people_outline_rounded,
                    title: 'Teman terhubung',
                    subtitle: '${state.friends.length} teman contoh',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FriendsListScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildListButton(
                    context: context,
                    icon: Icons.location_on_outlined,
                    title: 'Berbagi lokasi',
                    subtitle: '${state.sessions.length} sesi demo aktif',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageLocationSharingScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Notice Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3EB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Tidak ada pelacakan latar belakang. Berbagi selalu dimulai dan dihentikan olehmu.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5B6E55),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.sageGreen,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DEKAT DENGAN YANG BERARTI',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Ke mana pun,\ntetap terhubung.',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
              height: 1.2,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Temukan fasilitas dan atur berbagi lokasi dengan tenang.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4C6551),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE4E9E1)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05263D2F),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9EAFA3),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
