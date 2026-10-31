import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared/models/taut_app_state.dart';
import '../../../shared/widgets/taut_illustrations.dart';

/// Beranda TAUT strictly implementing the prototype HTML design:
/// - Sapaan ramah "Halo, selamat datang / [Nama] ✦" + Avatar
/// - Hero Card Sage Green: "SETIAP CERITA BERARTI / Saling mengerti, tanpa batas." + Ilustrasi + Tombol "Mulai Komunikasi →"
/// - 4 Fitur Utama Grid:
///   1. Ucapan ke Teks ("Dengar lewat tulisan")
///   2. Isyarat ke Suara ("Sampaikan dengan isyarat")
///   3. Fasilitas Kesehatan ("Temukan layanan sekitar")
///   4. Berbagi Lokasi ("Tetap dekat, tetap aman")
/// - Teman terhubung (preview avatar, nama, status) + tombol "Lihat semua ›"
/// - Kartu Sesi Berbagi Aktif (jika ada sesi) atau hint privasi perisai
class HomePage extends StatelessWidget {
  final VoidCallback? onNavigateToCommunication;
  final VoidCallback? onNavigateToHealthcare;
  final VoidCallback? onNavigateToLocation;
  final VoidCallback? onNavigateToProfile;

  const HomePage({
    super.key,
    this.onNavigateToCommunication,
    this.onNavigateToHealthcare,
    this.onNavigateToLocation,
    this.onNavigateToProfile,
  });

  @override
  Widget build(BuildContext context) {
    final state = TautAppState();

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Sapaan & Avatar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Halo, selamat datang',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                state.userName,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkGreen,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '✦',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF84A078),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          if (onNavigateToProfile != null) {
                            onNavigateToProfile!();
                          } else {
                            Navigator.pushNamed(context, AppRoutes.profile);
                          }
                        },
                        child: _buildAvatar(state.userName, 0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Hero Section: Saling Mengerti Tanpa Batas
                  _buildHero(context),
                  const SizedBox(height: 24),

                  // 4 Fitur Utama Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Teman aktivitasmu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                          letterSpacing: -0.4,
                        ),
                      ),
                      Text(
                        '4 fitur utama',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4 Features Grid
                  _buildFeatureGrid(context),
                  const SizedBox(height: 24),

                  // Teman Terhubung Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Teman terhubung',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                          letterSpacing: -0.4,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppConstants.routeFriends);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Lihat semua',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Teman Terhubung Card
                  _buildFriendsCard(context, state),
                  const SizedBox(height: 16),

                  // Active Location Sharing Card or Privacy Shield Hint
                  if (state.sessions.isNotEmpty)
                    _buildActiveSharingCard(context, state)
                  else
                    _buildPrivacyHint(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(context, state),
        );
      },
    );
  }

  Widget _buildAvatar(String name, int index) {
    final colors = [
      const Color(0xFFE9DDCD),
      const Color(0xFFDCE7DC),
      const Color(0xFFE6E2EF),
    ];
    final textColors = [
      const Color(0xFF655747),
      AppColors.primary,
      const Color(0xFF6A6086),
    ];
    final bg = colors[index % colors.length];
    final fg = textColors[index % textColors.length];
    final letter = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      width: 47,
      height: 47,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 3),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.sageGreen,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            bottom: 20,
            child: SizedBox(
              width: 140,
              height: 120,
              child: TautIllustration.communicationHero(height: 120),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SETIAP CERITA BERARTI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Saling mengerti,\ntanpa batas.',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                  height: 1.2,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 180,
                child: Text(
                  'Ucapkan atau isyaratkan.\nKami bantu menyampaikan.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF4C6551),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () {
                  if (onNavigateToCommunication != null) {
                    onNavigateToCommunication!();
                  } else {
                    Navigator.pushNamed(context, AppRoutes.commHub);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text(
                  'Mulai Komunikasi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildFeatureTile(
          icon: Icons.mic_none_rounded,
          title: 'Ucapan ke Teks',
          subtitle: 'Dengar lewat tulisan',
          bgColor: const Color(0xFFE9EEE6),
          onTap: () {
            if (onNavigateToCommunication != null) {
              onNavigateToCommunication!();
            } else {
              Navigator.pushNamed(context, AppRoutes.commHub);
            }
          },
        ),
        _buildFeatureTile(
          icon: Icons.sign_language_rounded,
          title: 'Isyarat ke Suara',
          subtitle: 'Sampaikan dengan isyarat',
          bgColor: const Color(0xFFF1E9DE),
          onTap: () {
            if (onNavigateToCommunication != null) {
              onNavigateToCommunication!();
            } else {
              Navigator.pushNamed(context, AppRoutes.commHub);
            }
          },
        ),
        _buildFeatureTile(
          icon: Icons.local_hospital_outlined,
          title: 'Fasilitas Kesehatan',
          subtitle: 'Temukan layanan sekitar',
          bgColor: const Color(0xFFE6EBF0),
          onTap: () {
            Navigator.pushNamed(context, AppConstants.routeHealthcare);
          },
        ),
        _buildFeatureTile(
          icon: Icons.location_on_outlined,
          title: 'Berbagi Lokasi',
          subtitle: 'Tetap dekat, tetap aman',
          bgColor: const Color(0xFFEDE8F0),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.manageSharing);
          },
        ),
      ],
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 26, color: AppColors.darkGreen),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF627065),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsCard(BuildContext context, TautAppState state) {
    final displayFriends = state.friends.take(3).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDF0E9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08263D2F),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(displayFriends.length, (i) {
          final friendName = displayFriends[i];
          final isSharingWithFriend = state.sessions.any((s) => s.name == friendName);

          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppConstants.routeFriends),
            child: Column(
              children: [
                _buildAvatar(friendName, i),
                const SizedBox(height: 6),
                Text(
                  friendName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGreen,
                  ),
                ),
                Text(
                  isSharingWithFriend ? 'Sesi demo aktif' : 'Terhubung',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF758174),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveSharingCard(BuildContext context, TautAppState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDF0E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Berbagi lokasi aktif',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6ECDA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Demo',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF825D24),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${state.sessions.length} penerima · simulasi lokal',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF4C6551)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.manageSharing);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFD9E2D5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Kelola sesi',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyHint() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 20, color: Color(0xFF758174)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Lokasimu tetap privat.\nKamu yang menentukan kapan berbagi.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF758174),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, TautAppState state) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6EBE3))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0C263D2F),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: 0,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.lightGreen,
        elevation: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              break; // Already at home
            case 1:
              if (onNavigateToCommunication != null) {
                onNavigateToCommunication!();
              } else {
                Navigator.pushNamed(context, AppRoutes.commHub);
              }
              break;
            case 2:
              if (onNavigateToLocation != null) {
                onNavigateToLocation!();
              } else {
                Navigator.pushNamed(context, AppRoutes.location);
              }
              break;
            case 3:
              if (onNavigateToProfile != null) {
                onNavigateToProfile!();
              } else {
                Navigator.pushNamed(context, AppRoutes.profile);
              }
              break;
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          const NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Komunikasi',
          ),
          NavigationDestination(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.location_on_outlined),
                if (state.isSharingLocation)
                  const Positioned(
                    right: -2,
                    top: -2,
                    child: Icon(Icons.circle, size: 8, color: Color(0xFF8B4435)),
                  ),
              ],
            ),
            selectedIcon: const Icon(Icons.location_on_rounded),
            label: 'Lokasi',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
