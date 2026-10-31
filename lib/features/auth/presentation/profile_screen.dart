import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared/models/taut_app_state.dart';

/// Profile Screen strictly implementing the TAUT HTML prototype:
/// - Screen title: "Profil"
/// - Profile Hero: Sage green background, large avatar, user name, "Ruangmu untuk terhubung.", "Edit profil" CTA
/// - 3 Menu Listbuttons:
///   1. Pengaturan & aksesibilitas
///   2. Privasi & izin
///   3. Teman terhubung
/// - "Keluar dari demo" ghost button
/// - Footer hint: "TAUT · Prototipe desain 01 / Data akun ini hanya contoh."
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            leading: (Navigator.canPop(context) || state.canPopPage)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.darkGreen,
                    onPressed: () {
                      if (state.canPopPage) {
                        state.popPage();
                      } else if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  )
                : null,
            title: const Text(
              'Profil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Column(
                children: [
                  // Profile Hero (Sage green)
                  _buildProfileHero(context, state),
                  const SizedBox(height: 24),

                  // 3 Menu Options Stack
                  _buildMenuButton(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan & aksesibilitas',
                    onTap: () => state.navigateTo('settings'),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuButton(
                    context: context,
                    icon: Icons.shield_outlined,
                    title: 'Privasi & izin',
                    onTap: () => state.navigateTo('privacy'),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuButton(
                    context: context,
                    icon: Icons.people_outline_rounded,
                    title: 'Teman terhubung',
                    onTap: () => state.navigateTo('friends'),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: Color(0xFFB9C9B6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Keluar dari demo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Footer Hint
                  const Text(
                    'TAUT · Prototipe desain 01\nData akun ini hanya contoh.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
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

  Widget _buildProfileHero(BuildContext context, TautAppState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.sageGreen,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFE9DDCD),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            alignment: Alignment.center,
            child: Text(
              state.userName.isNotEmpty ? state.userName[0] : '?',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFF655747),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            state.userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ruangmu untuk terhubung.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => state.navigateTo('edit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: Color(0xFFB9C9B6)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Edit profil',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String title,
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
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGreen,
                ),
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
