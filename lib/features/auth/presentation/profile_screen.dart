import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';

/// Profile & Settings screen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StatusBadge.development(),
          ),
          const SizedBox(height: 16),
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryContainer,
              child: const Icon(
                Icons.person_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pengguna Tamu (Guest)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          const Text(
            'Belum masuk ke akun Supabase',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AppButton(
              label: 'Masuk / Daftar Akun',
              icon: Icons.login_rounded,
              onPressed: () {
                Navigator.pushNamed(context, AppConstants.routeProfile);
              },
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Kebijakan Privasi & Izin'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, AppConstants.routePrivacy);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.group_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Daftar Teman & Undangan'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, AppConstants.routeFriends);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),
                  title: const Text('Tentang TAUT'),
                  subtitle: Text(AppConfig.appVersion),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: AppConfig.appName,
                      applicationVersion: AppConfig.appVersion,
                      applicationLegalese: 'INCEPTION 2026 Hackathon\nTim Mardua Holong — Universitas Brawijaya',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
