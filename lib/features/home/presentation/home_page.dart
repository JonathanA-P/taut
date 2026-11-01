import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/taut_app_state.dart';
import '../../../shared/widgets/taut_auth_gate_dialog.dart';
import '../../../shared/widgets/taut_avatar.dart';
import '../../../shared/widgets/taut_illustrations.dart';

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
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          Text(
                            (state.userName.trim().isNotEmpty && state.userName != 'Tamu TAUT')
                                ? state.userName
                                : 'Adriel',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          if (onNavigateToProfile != null) {
                            onNavigateToProfile!();
                          } else {
                            state.navigateTo('profile');
                          }
                        },
                        child: _buildAvatar(
                          (state.userName.trim().isNotEmpty && state.userName != 'Tamu TAUT')
                              ? state.userName
                              : 'Adriel',
                          0,
                          avatarUrl: state.userAvatarUrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildHero(context, state),
                  const SizedBox(height: 24),

                  const Text(
                    'Teman aktivitasmu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureGrid(context, state),
                  const SizedBox(height: 24),

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
                          if (state.isGuestMode) {
                            showAuthGateDialog(context, featureTitle: 'Teman Terhubung');
                            return;
                          }
                          state.navigateTo('friends');
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

                  _buildFriendsCard(context, state),
                  const SizedBox(height: 16),

                  if (state.sessions.isNotEmpty)
                    _buildActiveSharingCard(context, state)
                  else
                    _buildPrivacyHint(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String name, int index, {String? avatarUrl}) {
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

    return TautAvatar(
      name: name,
      avatarUrl: avatarUrl,
      radius: 23.5,
      border: Border.all(color: AppColors.background, width: 3),
      backgroundColor: bg,
      textColor: fg,
    );
  }

  Widget _buildHero(BuildContext context, TautAppState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFDCE7DC).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.2),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            bottom: 4,
            child: SizedBox(
              width: 155,
              height: 155,
              child: TautIllustration.communicationHero(height: 155),
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
                  HapticFeedback.lightImpact();
                  if (onNavigateToCommunication != null) {
                    onNavigateToCommunication!();
                  } else {
                    state.navigateTo('hub');
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

  Widget _buildFeatureGrid(BuildContext context, TautAppState state) {
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
            state.navigateTo('stt');
          },
        ),
        _buildFeatureTile(
          icon: Icons.sign_language_rounded,
          title: 'Isyarat ke Suara',
          subtitle: 'Sampaikan dengan isyarat',
          bgColor: const Color(0xFFF1E9DE),
          onTap: () {
            state.navigateTo('motion');
          },
        ),
        _buildFeatureTile(
          icon: Icons.local_hospital_outlined,
          title: 'Fasilitas Kesehatan',
          subtitle: 'Temukan layanan sekitar',
          bgColor: const Color(0xFFE6EBF0),
          onTap: () {
            state.navigateTo('finder');
          },
        ),
        _buildFeatureTile(
          icon: Icons.location_on_outlined,
          title: 'Berbagi Lokasi',
          subtitle: 'Tetap dekat, tetap aman',
          bgColor: const Color(0xFFEDE8F0),
          onTap: () {
            if (state.isGuestMode) {
              showAuthGateDialog(context, featureTitle: 'Berbagi Lokasi');
              return;
            }
            state.navigateTo('sharing');
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
    return Container(
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
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
    ),
  );
}

  Widget _buildFriendsCard(BuildContext context, TautAppState state) {
    final displayFriends = state.friends.take(3).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
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
            onTap: () {
              if (state.isGuestMode) {
                showAuthGateDialog(context, featureTitle: 'Teman Terhubung');
                return;
              }
              state.navigateTo('friends');
            },
            child: Column(
              children: [
                _buildAvatar(
                  friendName,
                  i,
                  avatarUrl: state.getFriendAvatar(friendName),
                ),
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
                  isSharingWithFriend ? 'Saling berbagi' : 'Terhubung',
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
            '${state.sessions.length} sahabat • Saling terhubung hangat',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF4C6551)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                if (state.isGuestMode) {
                  showAuthGateDialog(context, featureTitle: 'Berbagi Lokasi');
                  return;
                }
                state.navigateTo('sharing');
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFD9E2D5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Kelola Berbagi Lokasi',
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
              'Ruang privat & aman.\nKamu memegang kendali penuh kapan pun berbagi.',
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
}

