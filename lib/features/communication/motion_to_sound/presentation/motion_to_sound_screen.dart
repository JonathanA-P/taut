import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';

class MotionToSoundScreen extends StatefulWidget {
  const MotionToSoundScreen({super.key});

  @override
  State<MotionToSoundScreen> createState() => _MotionToSoundScreenState();
}

class _MotionToSoundScreenState extends State<MotionToSoundScreen> {
  bool _isCameraActive = false;
  final String _recognizedWord = 'Halo';
  final double _confidence = 0.88;
  bool _isPlayingAudio = false;

  void _toggleCamera() {
    setState(() {
      _isCameraActive = !_isCameraActive;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isCameraActive
              ? 'Pratinjau kamera dibuka. Deteksi landmark MediaPipe aktif.'
              : 'Kamera dinonaktifkan.',
        ),
      ),
    );
  }

  void _playTts() {
    setState(() => _isPlayingAudio = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mengucapkan: "$_recognizedWord" via Text-to-Speech.'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gerakan ke Suara (BISINDO)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                StatusBadge.category(
                  _isCameraActive ? 'Kamera Aktif - Deteksi 30 FPS' : 'Kamera Siap',
                  bg: _isCameraActive ? AppColors.successBg : AppColors.lightGreen,
                  fg: _isCameraActive ? AppColors.success : AppColors.darkGreen,
                ),
                const Spacer(),
                Text(
                  'Ambang Batas: 70%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              height: 290,
              decoration: BoxDecoration(
                color: const Color(0xFF1B2820),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isCameraActive ? AppColors.primary : AppColors.outline,
                  width: 2,
                ),
                boxShadow: AppColors.cardShadow,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isCameraActive
                              ? Icons.videocam_rounded
                              : Icons.videocam_off_rounded,
                          size: 48,
                          color: _isCameraActive ? AppColors.sageGreen : Colors.white54,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isCameraActive
                              ? 'Kamera Aktif\nPosisikan tangan di dalam bingkai panduan'
                              : 'Pratinjau Kamera Belum Aktif\nTekan tombol di bawah untuk menyalakan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isCameraActive ? Colors.white : Colors.white70,
                            fontSize: 13.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_isCameraActive)
                    Center(
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.sageGreen.withValues(alpha: 0.6),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Area Isyarat Tangan',
                              style: TextStyle(
                                color: AppColors.sageGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _isCameraActive ? AppColors.success : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Target: MediaPipe Hand Landmarks',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            AppButton(
              label: _isCameraActive ? 'Matikan Kamera' : 'Buka Pratinjau Kamera',
              icon: _isCameraActive ? Icons.videocam_off_rounded : Icons.videocam_rounded,
              backgroundColor: _isCameraActive ? AppColors.error : AppColors.darkGreen,
              onPressed: _toggleCamera,
            ),
            const SizedBox(height: 20),

            AppCard(
              margin: EdgeInsets.zero,
              backgroundColor: AppColors.accentMtsBg,
              borderColor: AppColors.accentMts.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kata BISINDO Terdeteksi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accentMts.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Keyakinan: ${(_confidence * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onAccentMts,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightGreen),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isCameraActive ? _recognizedWord : 'Menunggu Isyarat...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _isCameraActive ? AppColors.darkGreen : AppColors.textMuted,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (_isCameraActive) ...[
                          const SizedBox(height: 4),
                          const Text(
                            'Klasifikasi Word-Level BISINDO Terverifikasi',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: _isPlayingAudio ? 'Sedang Memutar...' : 'Putar Audio Suara',
                    icon: Icons.volume_up_rounded,
                    backgroundColor: AppColors.primaryGreen,
                    onPressed: _isCameraActive ? _playTts : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            AppCard(
              margin: EdgeInsets.zero,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.darkGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Pastikan pencahayaan ruangan cukup terang dan latar belakang kontras agar titik sendi jari tangan terdeteksi akurat.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

