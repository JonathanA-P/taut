import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';

/// Screen 17: Profile & Account Screen.
/// Clean, healthcare-oriented profile presentation with settings, accessibility, and account management.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Konfirmasi Keluar Akun',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Apakah Anda yakin ingin keluar dari akun TAUT? Sesi berbagi lokasi akan otomatis dihentikan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Batal',
                    isOutlined: true,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Keluar',
                    backgroundColor: AppColors.error,
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppConstants.routeLogin,
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil & Pengaturan'),
        actions: [
          IconButton(
            tooltip: 'Keluar Akun',
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () => _showLogoutDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        children: [
          Row(
            children: [
              StatusBadge.active(label: 'Akun Terverifikasi'),
              const Spacer(),
              const Text(
                'Tim Mardua Holong',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // PROFILE AVATAR & NAME CARD
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2.5),
                      ),
                      child: const CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.sageGreen,
                        child: Text(
                          'AJ',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.darkGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Alfredo Jonathan Purba',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'alfredo@ub.ac.id • Teman Dengar & Lead Architect',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // EDIT PROFILE SHORTCUT
          AppButton(
            label: 'Ubah Data Profil',
            icon: Icons.edit_outlined,
            isOutlined: true,
            onPressed: () {
              Navigator.pushNamed(context, AppConstants.routeEditProfile);
            },
          ),
          const SizedBox(height: 20),

          // SETTINGS & ACCESS CONTROL SECTION
          AppCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.accessibility_new_rounded, color: AppColors.primary),
                  title: const Text(
                    'Pengaturan & Aksesibilitas',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                  ),
                  subtitle: const Text(
                    'Ukuran teks, kontras tinggi, haptik, TTS & BISINDO',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
                  onTap: () {
                    Navigator.pushNamed(context, AppConstants.routeSettings);
                  },
                ),
                const Divider(color: AppColors.lightGreen, height: 1),
                ListTile(
                  leading: const Icon(Icons.people_outline_rounded, color: AppColors.primary),
                  title: const Text(
                    'Daftar Teman & Kode Undangan',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                  ),
                  subtitle: const Text(
                    'Kelola teman terpercaya dan perizinan berbagi lokasi',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
                  onTap: () {
                    Navigator.pushNamed(context, AppConstants.routeFriends);
                  },
                ),
                const Divider(color: AppColors.lightGreen, height: 1),
                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: AppColors.primary),
                  title: const Text(
                    'Kebijakan Privasi & Keamanan',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                  ),
                  subtitle: const Text(
                    'Pemrosesan lokal & PostgreSQL Row Level Security',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
                  onTap: () {
                    Navigator.pushNamed(context, AppConstants.routePrivacy);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // APP VERSION & INFO CARD
          AppCard(
            margin: EdgeInsets.zero,
            backgroundColor: AppColors.lightGreen,
            borderColor: AppColors.sageGreen,
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.primaryGreen, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConfig.appName,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      Text(
                        'Versi ${AppConfig.appVersion} • INCEPTION 2026 Hackathon',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // LOGOUT BUTTON
          AppButton(
            label: 'Keluar dari Akun',
            icon: Icons.logout_rounded,
            backgroundColor: AppColors.errorBg,
            foregroundColor: AppColors.error,
            onPressed: () => _showLogoutDialog(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
