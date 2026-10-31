import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/taut_illustrations.dart';

/// Communication Hub screen: Entry point for the two communication pipelines.
/// Feature Lead: Roganda Tua Tampubolon.
/// Refined with the Dribbble-inspired healthcare aesthetic:
/// Soft pastel cards, friendly communication illustration, and clear visual hierarchy.
class CommunicationHubScreen extends StatelessWidget {
  final VoidCallback? onOpenDashboard;

  const CommunicationHubScreen({super.key, this.onOpenDashboard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Komunikasi Dua Arah'),
        actions: [
          IconButton(
            tooltip: 'Dashboard Pribadi',
            icon: const Icon(Icons.dashboard_customize_outlined),
            onPressed: () {
              if (onOpenDashboard != null) {
                onOpenDashboard!();
              } else {
                Navigator.pushNamed(context, AppConstants.routeHomeDashboard);
              }
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
              StatusBadge.active(label: 'Dua Jalur Aktif'),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  if (onOpenDashboard != null) {
                    onOpenDashboard!();
                  } else {
                    Navigator.pushNamed(context, AppConstants.routeHomeDashboard);
                  }
                },
                icon: const Icon(Icons.space_dashboard_rounded, size: 16),
                label: const Text('Dashboard'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Pilih Saluran Komunikasi',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Dua alur terpisah untuk menjembatani komunikasi antara teman Tuli dan masyarakat dengar secara langsung dan ramah.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // Illustration Banner
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
                        'Interaksi Alami & Inklusif',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Didukung pengenalan ucapan native & MediaPipe TFLite.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  height: 70,
                  child: TautIllustration.communicationHero(height: 70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // CHANNEL 1: SPEECH TO TEXT
          AppCard(
            margin: EdgeInsets.zero,
            backgroundColor: AppColors.white,
            borderColor: AppColors.accentStt.withValues(alpha: 0.25),
            onTap: () {
              Navigator.pushNamed(context, AppConstants.routeSpeechToText);
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentSttBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    size: 32,
                    color: AppColors.accentStt,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Suara ke Teks',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentSttBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'STT + TTS',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentStt,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Menangkap ucapan suara lawan bicara dan menampilkan teks transkripsi besar untuk teman Tuli.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // CHANNEL 2: MOTION TO SOUND
          AppCard(
            margin: EdgeInsets.zero,
            backgroundColor: AppColors.white,
            borderColor: AppColors.accentMts.withValues(alpha: 0.25),
            onTap: () {
              Navigator.pushNamed(context, AppConstants.routeMotionToSound);
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentMtsBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.sign_language_rounded,
                    size: 32,
                    color: AppColors.accentMts,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Gerakan ke Suara',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentMtsBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'BISINDO',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentMts,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Mendeteksi isyarat tangan BISINDO melalui kamera dan membacakan kata secara lantang via suara.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
