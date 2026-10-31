import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taut/core/constants/app_constants.dart';
import 'package:taut/core/routing/app_router.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/shared/widgets/status_badge.dart';
import 'package:taut/shared/widgets/taut_action_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSharing = true;
  Duration _remaining = AppConstants.initialSharingRemaining;
  DateTime? _lastStopTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isSharing) return;
      if (_remaining.inSeconds <= 1) {
        // Sesi habis sendiri: perlakukan seperti berhenti.
        _stopSharing();
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  void _stopSharing() {
    _timer?.cancel();
    setState(() {
      _isSharing = false;
      _lastStopTime = DateTime.now();
    });
  }

  void _restartSharing() {
    setState(() {
      _isSharing = true;
      _remaining = AppConstants.initialSharingRemaining;
      _lastStopTime = null;
    });
    _startTimer();
  }

  String get _remainingText {
    final minutes = _remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get _lastStopText {
    final t = _lastStopTime;
    if (t == null) return '-';
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        break; // Sudah di Beranda.
      case 1:
        Navigator.pushNamed(context, AppRoutes.commHub);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.location);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Selamat datang kembali,',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Halo, ${AppConstants.demoUserName}!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Apa yang ingin kamu lakukan hari ini?',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              _buildHero(context),
              const SizedBox(height: 16),
              _buildShortcutGrid(context),
              const SizedBox(height: 24),
              _buildFriendsCard(context),
              const SizedBox(height: 16),
              _buildSharingCard(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: _onNavTap,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Komunikasi',
          ),
          BottomNavigationBarItem(
            // Titik merah = sesi berbagi aktif (darurat: harus terlihat).
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.location_on_outlined),
                if (_isSharing)
                  const Positioned(
                    right: -2,
                    top: -2,
                    child: Icon(
                      Icons.circle,
                      size: 10,
                      color: AppTheme.danger,
                    ),
                  ),
              ],
            ),
            activeIcon: const Icon(Icons.location_on),
            label: 'Lokasi',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.commHub),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.heroGradient,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mulai Komunikasi',
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryDeep,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Berkomunikasi tanpa hambatan - ketuk untuk '
                    'memilih mode.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: AppTheme.primary,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.05,
      children: [
        _ShortcutTile(
          color: AppTheme.peach,
          icon: Icons.mic_none,
          title: 'Speech-to-Text',
          subtitle: 'Suara menjadi teks',
          onTap: () => Navigator.pushNamed(context, AppRoutes.speechToText),
        ),
        _ShortcutTile(
          color: AppTheme.lavender,
          icon: Icons.back_hand_outlined,
          title: 'Motion-to-Sound',
          subtitle: 'Isyarat menjadi suara',
          onTap: () => Navigator.pushNamed(context, AppRoutes.motionToSound),
        ),
        _ShortcutTile(
          color: AppTheme.butter,
          icon: Icons.local_hospital_outlined,
          title: 'Cari Faskes',
          subtitle: 'Fasilitas kesehatan terdekat',
          onTap: () => Navigator.pushNamed(context, AppRoutes.location),
        ),
        _ShortcutTile(
          color: AppTheme.primaryLight,
          icon: Icons.location_on_outlined,
          title: 'Bagikan Lokasi',
          subtitle: 'Terhubung dengan teman',
          onTap: () => Navigator.pushNamed(context, AppRoutes.manageSharing),
        ),
      ],
    );
  }

  Widget _buildFriendsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Teman Terhubung',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.location),
                  child: const Text('Lihat semua'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    'B',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.demoFriendName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Berbagi lokasi aktif',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusBadge.active(),
              ],
            ),
            const SizedBox(height: 12),
            TautActionButton.secondary(
              label: 'Lihat Lokasi Teman',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.friendLocation),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharingCard(BuildContext context) {
    if (!_isSharing) {
      // Keadaan berhenti: kartu kembali normal (bukan merah),
      // ada riwayat terakhir + tombol mulai lagi.
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sesi berbagi kamu',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Kamu tidak sedang membagikan lokasimu saat ini.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Riwayat terakhir berbagi',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Kepada: ${AppConstants.demoFriendName}\n'
                'Lokasi terakhir: ${AppConstants.demoLastLocation}\n'
                'Berhenti pukul $_lastStopText',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TautActionButton.secondary(
                label: 'Cek Posisi Terakhir',
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.myPosition),
              ),
              const SizedBox(height: 8),
              TautActionButton(
                label: 'Berbagi Sekarang',
                onPressed: _restartSharing,
              ),
            ],
          ),
        ),
      );
    }

    // Keadaan aktif: kartu merah + tombol berhenti langsung.
    return Card(
      color: const Color(0xFFFFE9E9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: AppTheme.danger, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sesi berbagi kamu — AKTIF',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Berakhir dalam $_remainingText · '
              'Kepada: ${AppConstants.demoFriendName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TautActionButton.danger(
              label: 'Berhenti Berbagi',
              onPressed: _stopSharing,
            ),
            const SizedBox(height: 8),
            TautActionButton.secondary(
              label: 'Lihat Posisi Saya yang Dibagikan',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.myPosition),
            ),
            const SizedBox(height: 8),
            TautActionButton.secondary(
              label: 'Kelola di Lokasi',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.manageSharing),
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu tile pintasan pastel di Beranda (gaya referensi Dribbble:
/// latar pastel per fungsi + ikon dalam kotak putih).
class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: AppTheme.primary),
            ),
            const Spacer(),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
