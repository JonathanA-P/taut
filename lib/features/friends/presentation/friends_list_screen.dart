import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/taut_illustrations.dart';

/// Screen 13: Friends List Screen.
/// Displays connected trusted friends, invitation status, and live tracking shortcuts.
class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  final List<Map<String, dynamic>> _friends = [
    {
      'initials': 'AC',
      'name': 'Adriel Christo Lumbantoruan',
      'role': 'Frontend & Healthcare Lead',
      'status': 'Sedang Berbagi Lokasi',
      'distance': '1.2 km',
      'isActive': true,
      'lastSeen': 'Baru saja',
    },
    {
      'initials': 'RT',
      'name': 'Roganda Tua Tampubolon',
      'role': 'Communication AI Lead',
      'status': 'Offline',
      'distance': null,
      'isActive': false,
      'lastSeen': '10 menit yang lalu',
    },
    {
      'initials': 'DR',
      'name': 'dr. Stella Kane (Dokter Pendamping)',
      'role': 'Spesialis Medis THT',
      'status': 'Terhubung',
      'distance': '3.5 km',
      'isActive': false,
      'lastSeen': '1 jam yang lalu',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Teman & Undangan'),
        actions: [
          IconButton(
            tooltip: 'Tambah Teman',
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () {
              Navigator.pushNamed(context, AppConstants.routeAddFriend);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        children: [
          Row(
            children: [
              StatusBadge.active(label: 'PostgreSQL RLS Terproteksi'),
              const Spacer(),
              Text(
                '${_friends.length} Teman Terdaftar',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ADD FRIEND HERO CARD
          AppCard(
            margin: EdgeInsets.zero,
            backgroundColor: AppColors.lightGreen,
            borderColor: AppColors.sageGreen,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tambah Teman Terpercaya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Gunakan kode undangan SHA-256 untuk saling berbagi lokasi.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Tambah Teman Baru',
                        height: 42,
                        icon: Icons.qr_code_rounded,
                        backgroundColor: AppColors.darkGreen,
                        onPressed: () {
                          Navigator.pushNamed(context, AppConstants.routeAddFriend);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // FRIENDS LIST TITLE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Teman Aktif & Terhubung',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppConstants.routeManageLocationSharing);
                },
                child: const Text('Kelola Izin'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ..._friends.map((friend) => _buildFriendCard(context, friend)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFriendCard(BuildContext context, Map<String, dynamic> friend) {
    final isActive = friend['isActive'] as bool;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        if (isActive) {
          Navigator.pushNamed(context, AppConstants.routeLiveLocation);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${friend['name']} sedang tidak membagikan lokasi aktif.'),
            ),
          );
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              TautIllustration.friendAvatar(
                initials: friend['initials'] as String,
                radius: 24,
                backgroundColor: isActive ? AppColors.sageGreen : AppColors.lightGreen,
              ),
              if (isActive)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        friend['name'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (friend['distance'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          friend['distance'] as String,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  friend['role'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.success : AppColors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'Berbagi Aktif • Tap untuk pantau' : 'Terakhir aktif ${friend['lastSeen']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive ? AppColors.success : AppColors.textMuted,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
