import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';

/// Screen for Motion-to-Sound (BISINDO to Speech).
/// Captures hand signs using the camera and converts recognized words to spoken audio.
/// Feature Owner: Roganda Tua Tampubolon (Branch: feature/motion-to-sound).
class MotionToSoundScreen extends StatefulWidget {
  const MotionToSoundScreen({super.key});

  @override
  State<MotionToSoundScreen> createState() => _MotionToSoundScreenState();
}

class _MotionToSoundScreenState extends State<MotionToSoundScreen> {
  bool _isCameraActive = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerakan ke Suara (BISINDO)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: StatusBadge.development()),
            const SizedBox(height: 16),
            // Camera Viewfinder Placeholder
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
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
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isCameraActive
                              ? 'Kamera Aktif\nMenunggu integrasi MediaPipe Hand Landmarker'
                              : 'Pratinjau Kamera Belum Aktif\nTekan tombol di bawah untuk mengaktifkan',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Target: Tangan & Gerak BISINDO',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: _isCameraActive
                  ? 'Tutup Kamera'
                  : 'Buka Kamera & Mulai Deteksi',
              icon: _isCameraActive ? Icons.videocam_off : Icons.videocam,
              onPressed: _toggleCamera,
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kata Terdeteksi (Model BISINDO)',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Belum Ada Gerakan Terdeteksi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tingkat Keyakinan (Confidence): 0.0%',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Ucapkan Suara (TTS)',
                    icon: Icons.volume_up_rounded,
                    isOutlined: true,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Text-to-Speech (TTS) akan diaktifkan setelah integrasi flutter_tts.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kosakata BISINDO yang Direncanakan',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tahap awal MVP menguji model kata terisolasi (Word-Level BISINDO):',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: const [
                      Chip(label: Text('HALO')),
                      Chip(label: Text('TERIMA KASIH')),
                      Chip(label: Text('TOLONG')),
                      Chip(label: Text('SAMA-SAMA')),
                      Chip(label: Text('MAAF')),
                      Chip(label: Text('RUMAH SAKIT')),
                      Chip(label: Text('DOKTER')),
                      Chip(label: Text('DARURAT')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
