import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

/// Screen 19: Settings & Accessibility Screen.
/// Provides accessibility-first interaction customization: font sizing, haptic feedback,
/// high contrast mode, and AI recognition sensitivity.
class SettingsAccessibilityScreen extends StatefulWidget {
  const SettingsAccessibilityScreen({super.key});

  @override
  State<SettingsAccessibilityScreen> createState() =>
      _SettingsAccessibilityScreenState();
}

class _SettingsAccessibilityScreenState
    extends State<SettingsAccessibilityScreen> {
  double _fontScale = 1.0;
  bool _highContrast = false;
  bool _hapticFeedback = true;
  bool _screenFlashAlert = true;
  double _bisindoThreshold = 0.70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan & Aksesibilitas'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        children: [
          // SECTION 1: ACCESSIBILITY & DISPLAY
          const Text(
            'Tampilan & Keterbacaan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Skala Ukuran Teks',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    Text(
                      '${(_fontScale * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _fontScale,
                  min: 0.9,
                  max: 1.4,
                  divisions: 5,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _fontScale = val),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Standar (A)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    Text('Besar (A+)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                const Divider(color: AppColors.lightGreen, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mode Kontras Maksimal',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          Text(
                            'Garis batas tegas dan warna kontras tinggi',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _highContrast,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _highContrast = val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 2: HAPTIC & SENSORY FEEDBACK
          const Text(
            'Umpan Balik Sensorik & Haptik',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Getaran Haptik Konfirmasi',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          Text(
                            'Getaran saat teks atau isyarat berhasil dikenali',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _hapticFeedback,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _hapticFeedback = val),
                    ),
                  ],
                ),
                const Divider(color: AppColors.lightGreen, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kedipan Visual Peringatan',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          Text(
                            'Flash layar saat situasi darurat atau ada notifikasi',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _screenFlashAlert,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _screenFlashAlert = val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 3: AI PARAMETERS
          const Text(
            'Kecerdasan Artifisial (AI & BISINDO)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sensitivitas BISINDO (Confidence)',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    Text(
                      '${(_bisindoThreshold * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _bisindoThreshold,
                  min: 0.50,
                  max: 0.90,
                  divisions: 8,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _bisindoThreshold = val),
                ),
                const Text(
                  'Ambang batas probabilitas klasifikasi model sebelum diucapkan via TTS.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Simpan Preferensi Aksesibilitas',
            backgroundColor: AppColors.darkGreen,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Preferensi aksesibilitas telah diterapkan.'),
                ),
              );
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
