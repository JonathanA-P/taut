import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/taut_illustrations.dart';

/// Personalized and Friendly Healthcare Dashboard for TAUT.
/// Adopts the visual quality and composition of the central mobile screen in the Dribbble reference:
/// - Clean, spacious layout with soft sage green palette (#D7E3D1, #263D2F, #527B5D, #E5EEE5)
/// - A. Personalized Header with greeting, user name, profile avatar, and system status
/// - B. Main Hero Card with custom communication illustration and "Mulai Komunikasi" CTA
/// - C. Four distinct Feature Shortcut cards with soft pastel tinted surfaces and clean icons
/// - D. Connected Friends Preview with avatars and real location sharing status
/// - E. Active Location Sharing Information Card with direct manage-sharing action
class HomeDashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToCommunication;
  final VoidCallback? onNavigateToHealthcare;
  final VoidCallback? onNavigateToLocationSharing;
  final VoidCallback? onNavigateToProfile;

  const HomeDashboardScreen({
    super.key,
    this.onNavigateToCommunication,
    this.onNavigateToHealthcare,
    this.onNavigateToLocationSharing,
    this.onNavigateToProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          children: [
            // A. HEADER SECTION
            _buildHeader(context),
            const SizedBox(height: 20),

            // B. MAIN HERO CARD
            _buildHeroCard(context),
            const SizedBox(height: 24),

            // C. FEATURE SHORTCUTS SECTION
            _buildSectionTitle(context, 'Layanan Utama'),
            const SizedBox(height: 12),
            _buildFeatureShortcuts(context),
            const SizedBox(height: 24),

            // D. CONNECTED FRIENDS PREVIEW
            _buildFriendsPreview(context),
            const SizedBox(height: 20),

            // E. ACTIVE LOCATION SHARING CARD
            _buildActiveLocationSharingCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // A. HEADER COMPONENT
  // -------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Halo, Alfredo',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 14,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Semua sensor siap • Maluku & Malang GPS Aktif',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            if (onNavigateToProfile != null) {
              onNavigateToProfile!();
            } else {
              Navigator.pushNamed(context, AppConstants.routeProfile);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.sageGreen,
              child: const Text(
                'AJ',
                style: TextStyle(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // B. MAIN HERO CARD
  // -------------------------------------------------------------------------
  Widget _buildHeroCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.sageGreen, width: 1.2),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge.active(label: 'Komunikasi Inklusif'),
              const Spacer(),
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Friendly human communication illustration
          Center(
            child: TautIllustration.communicationHero(height: 120),
          ),
          const SizedBox(height: 14),
          const Text(
            'Mulai Komunikasi Dua Arah',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Jembatani interaksi suara bahasa Indonesia dan gerakan isyarat BISINDO secara instan dan ramah.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Mulai Komunikasi',
            icon: Icons.chat_bubble_rounded,
            backgroundColor: AppColors.darkGreen,
            foregroundColor: AppColors.white,
            onPressed: () {
              if (onNavigateToCommunication != null) {
                onNavigateToCommunication!();
              } else {
                Navigator.pushNamed(context, AppConstants.routeCommunication);
              }
            },
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // C. FEATURE SHORTCUTS (4 Distinct Cards)
  // -------------------------------------------------------------------------
  Widget _buildFeatureShortcuts(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: [
        _buildFeatureCard(
          context: context,
          title: 'Suara ke Teks',
          subtitle: 'Dengar ucapan suara',
          icon: Icons.mic_rounded,
          iconBg: AppColors.accentSttBg,
          iconColor: AppColors.accentStt,
          borderColor: AppColors.accentStt.withValues(alpha: 0.2),
          onTap: () {
            Navigator.pushNamed(context, AppConstants.routeSpeechToText);
          },
        ),
        _buildFeatureCard(
          context: context,
          title: 'Gerakan ke Suara',
          subtitle: 'Isyarat BISINDO',
          icon: Icons.sign_language_rounded,
          iconBg: AppColors.accentMtsBg,
          iconColor: AppColors.accentMts,
          borderColor: AppColors.accentMts.withValues(alpha: 0.2),
          onTap: () {
            Navigator.pushNamed(context, AppConstants.routeMotionToSound);
          },
        ),
        _buildFeatureCard(
          context: context,
          title: 'Pencari Faskes',
          subtitle: 'Radius 10 km',
          icon: Icons.local_hospital_rounded,
          iconBg: AppColors.accentHealthcareBg,
          iconColor: AppColors.accentHealthcare,
          borderColor: AppColors.accentHealthcare.withValues(alpha: 0.2),
          onTap: () {
            if (onNavigateToHealthcare != null) {
              onNavigateToHealthcare!();
            } else {
              Navigator.pushNamed(context, AppConstants.routeHealthcare);
            }
          },
        ),
        _buildFeatureCard(
          context: context,
          title: 'Bagi Lokasi',
          subtitle: 'Teman & Faskes',
          icon: Icons.share_location_rounded,
          iconBg: AppColors.accentLocationBg,
          iconColor: AppColors.accentLocation,
          borderColor: AppColors.accentLocation.withValues(alpha: 0.2),
          onTap: () {
            if (onNavigateToLocationSharing != null) {
              onNavigateToLocationSharing!();
            } else {
              Navigator.pushNamed(context, AppConstants.routeLocationSharing);
            }
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // D. CONNECTED FRIENDS PREVIEW
  // -------------------------------------------------------------------------
  Widget _buildFriendsPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context, 'Teman Terhubung'),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppConstants.routeFriends);
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _buildFriendRow(
                initials: 'AC',
                name: 'Adriel Christo',
                status: 'Berbagi aktif • 1.2 km dari Anda',
                isActive: true,
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.routeLiveLocation);
                },
              ),
              const Divider(color: AppColors.lightGreen, height: 16),
              _buildFriendRow(
                initials: 'RT',
                name: 'Roganda Tua',
                status: 'Terakhir terlihat 5 menit lalu',
                isActive: false,
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.routeFriends);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFriendRow({
    required String initials,
    required String name,
    required String status,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Stack(
              children: [
                TautIllustration.friendAvatar(
                  initials: initials,
                  radius: 20,
                  backgroundColor: isActive ? AppColors.sageGreen : AppColors.lightGreen,
                ),
                if (isActive)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? AppColors.primaryGreen : AppColors.textMuted,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // E. ACTIVE LOCATION SHARING CARD
  // -------------------------------------------------------------------------
  Widget _buildActiveLocationSharingCard(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.zero,
      backgroundColor: AppColors.accentLocationBg,
      borderColor: AppColors.accentLocation.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentLocation,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fmd_good_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sesi Berbagi Lokasi Aktif',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    Text(
                      'Terhubung langsung dengan Adriel Christo',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'GPS perangkat (-7.9526, 112.6144) disiarkan secara aman dengan perlindungan Supabase Row Level Security.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Kelola Berbagi',
                  height: 44,
                  backgroundColor: AppColors.darkGreen,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppConstants.routeManageLocationSharing,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Lihat Peta',
                  height: 44,
                  isOutlined: true,
                  onPressed: () {
                    Navigator.pushNamed(context, AppConstants.routeLiveLocation);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.darkGreen,
        letterSpacing: -0.2,
      ),
    );
  }
}
