import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/taut_illustrations.dart';

/// Screen 15: Live Location Tracking Screen.
/// Renders a real-time tracking interface showing connected friend's position.
class LiveLocationScreen extends StatelessWidget {
  const LiveLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pantau Lokasi Langsung'),
        actions: [
          IconButton(
            tooltip: 'Segarkan Sinyal GPS',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menyinkronkan koordinat GPS Supabase Realtime...')),
              );
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
              StatusBadge.active(label: 'Supabase Realtime Terkoneksi'),
              const Spacer(),
              const Text(
                'Update: 3 detik lalu',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // LIVE MAP VISUAL VIEWPORT
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.sageGreen, width: 1.5),
              boxShadow: AppColors.cardShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Stylized map texture
                CustomPaint(
                  size: Size.infinite,
                  painter: _LiveMapPainter(),
                ),

                // Radar pulse on Friend's location
                Positioned(
                  top: 90,
                  left: 120,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.darkGreen,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: const Text(
                          'Adriel Christo (1.2 km)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: AppColors.heroShadow,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_pin_circle_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // My location marker
                Positioned(
                  bottom: 40,
                  right: 60,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: const Text(
                          'Posisi Anda',
                          style: TextStyle(
                            color: AppColors.darkGreen,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.darkGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // FRIEND STATUS DETAIL CARD
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TautIllustration.friendAvatar(
                      initials: 'AC',
                      radius: 24,
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adriel Christo Lumbantoruan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          Text(
                            'Jl. Soekarno Hatta No. 9, Lowokwaru, Malang',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppColors.lightGreen, height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InfoStat(label: 'Jarak Geodesik', value: '1.2 km'),
                    _InfoStat(label: 'Akurasi GPS', value: '± 4 meter'),
                    _InfoStat(label: 'Status', value: 'Bergerak'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ACTIONS
          AppButton(
            label: 'Buka Navigasi ke Teman (Google Maps)',
            icon: Icons.directions_rounded,
            backgroundColor: AppColors.darkGreen,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Membuka rute tercepat ke posisi Adriel...'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Hentikan Sesi Pemantauan',
            isOutlined: true,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  final String label;
  final String value;

  const _InfoStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _LiveMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final roadPath = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.6, size.width * 0.5, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.2);
    canvas.drawPath(roadPath, roadPaint);

    final crossRoad = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.6, size.height);
    canvas.drawPath(crossRoad, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
